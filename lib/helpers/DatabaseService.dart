import 'dart:async';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert' as convert;
import 'package:intl/intl.dart';
import 'package:sudokuapp/models/ActivePuzzle.dart';
import 'package:sudokuapp/db/SaveGame.dart';
import 'package:sudokuapp/db/Score.dart';
import 'Utilities.dart';

class DatabaseService
{
  final log = Logger('DB');

  DateFormat dbDateTimeFormat = DateFormat("EEE, MMM d, yyyy HH:mm aaa"); //database datetime format
  late Future<Database> database;

  BehaviorSubject _dbSavesItemsCount = BehaviorSubject.seeded(0);
  BehaviorSubject _dbScoresItemsCount = BehaviorSubject.seeded(0);

  Stream get streamSaves$ => _dbSavesItemsCount.stream;
  Stream get streamScores$ => _dbScoresItemsCount.stream;

  var utilities = GetIt.instance.get<Utilities>();

  Future<Database> initilise() async {
    const initScript = [
      '''CREATE TABLE if not exists 
            SaveGames(
              id INTEGER PRIMARY KEY autoincrement, 
              puzzleId TEXT not null,
              elapsedSeconds INTEGER,
              inProgress TEXT,
              hints TEXT,
              notes TEXT,
              lastPlayed TEXT)''',
      '''CREATE TABLE if not exists 
            Scores(
              id INTEGER PRIMARY KEY autoincrement, 
              puzzleId TEXT not null,
              elapsedSeconds INTEGER,
              puzzleSolveRate REAL,
              hintsUsed INTEGER,
              combinedScore REAL,
              isCorrect bool,
              submitted bool,
              completed TEXT)''',
    ];
    const migrationScripts = [];
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'sudoku.db'),
      // When the database is first created, create a table to store Refills and Vehicles.
      onCreate: (db, version)
      {
        initScript.forEach((script) async => await db.execute(script));
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async
      {
        for (var i = oldVersion - 1; i <= newVersion - 1; i++)
        {
          await db.execute(migrationScripts[i]);
        }
      },
      version: migrationScripts.length + 1,
    );
    return database;
  }

  Future<int> insertOrUpdateSaveGame(SaveGame saveGame) async {
    if(saveGame == null)
      return -1;

    // Get a reference to the database.
    final Database db = await database;

    var isUpdate = false;
    var changed = 0;
    if(saveGame.id != null && saveGame.id! > 0)
    {
      changed = await db.update(
        'SaveGames',
        saveGame.toJson(),
        // Ensure that the Refill has a matching id.
        where: "id = ?",
        // Pass the Refill's id as a whereArg to prevent SQL injection.
        whereArgs: [saveGame.id],
      );
      isUpdate = true;
    }
    else
    {
      changed = await db.insert(
        'SaveGames',
        saveGame.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    if(changed > 0)
    {
      _dbScoresItemsCount.add(changed);
      log.fine("DatabaseService.insertOrUpdateSaveGame: ${isUpdate ? "updated" : "inserted"} save game");
    }
    return changed;
  }

  Future<int> insertOrUpdateScore(Score score) async {
    if(score == null)
      return -1;

    // Get a reference to the database.
    final Database db = await database;

    var isUpdate = false;
    var changed = 0;
    if(score.id != null && score.id! > 0)
    {
      changed = await db.update(
        'Scores',
        score.toJson(),
        // Ensure that the Refill has a matching id.
        where: "id = ?",
        // Pass the Refill's id as a whereArg to prevent SQL injection.
        whereArgs: [score.id],
      );
      isUpdate = true;
    }
    else
    {
      changed = await db.insert(
        'Scores',
        score.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    if(changed > 0)
    {
      _dbScoresItemsCount.add(changed);
      log.fine("DatabaseService.insertOrUpdateScore: ${isUpdate ? "updated" : "inserted"} score");
    }
    return changed;
  }

  Future<SaveGame?> getLatestSaveGame(String puzzleId) async {
    // Get a reference to the database.
    final Database db = await database;
    // Query the table for all The Refills.
    final List<Map<String, dynamic>> maps = await db.query('SaveGames', where: 'puzzleId=?', whereArgs: [puzzleId], orderBy: 'lastPlayed DESC');

    if (maps.length > 0)
    {
      return SaveGame.fromJson(maps.first);
    }
    return null;
  }

  Future<List<SaveGame>> getSaveGames() async {
    // Get a reference to the database.
    final Database db = await database;
    // Query the table for all The Refills.
    final List<Map<String, dynamic>> maps = await db.query('SaveGames');

    return List.generate(maps.length, (i) {
      return SaveGame.fromJson(maps[i]);
    });
  }

  Future<List<Score>> getScores() async {
    // Get a reference to the database.
    final Database db = await database;
    // Query the table for all The Refills.
    final List<Map<String, dynamic>> maps = await db.query('Scores');

    return List.generate(maps.length, (i) {
      return Score.fromJson(maps[i]);
    });
  }

  Future<int> deleteSaveGame(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Refill from the database.
    var changed = await db.delete(
      'SaveGames',
      // Use a `where` clause to delete a specific Refill.
      where: "id = ?",
      // Pass the Refill's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    if(changed > 0)
    {
      _dbScoresItemsCount.add(changed);
      log.fine("DatabaseService.deleteSaveGame: deleted saveGame");
    }
    return changed;
  }

  Future<int> deleteScore(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Refill from the database.
    var changed = await db.delete(
      'Scores',
      // Use a `where` clause to delete a specific Refill.
      where: "id = ?",
      // Pass the Refill's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    if(changed > 0)
    {
      _dbScoresItemsCount.add(changed);
      log.fine("DatabaseService.deleteSaveGame: deleted score");
    }
    return changed;
  }

  void dispose(filename) {
    _dbSavesItemsCount.close();
    _dbScoresItemsCount.close();
  }
}