import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sudokuapp/db/Puzzles.dart';
import 'package:sudokuapp/models/ActivePuzzle.dart';
import 'package:sudokuapp/db/SaveGame.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/DatabaseService.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/CellValue.dart';
import 'package:sudokuapp/models/CellValueUpdateReason.dart';
import 'package:sudokuapp/models/Puzzle.dart';
import 'package:sudokuapp/models/PuzzleDifficulty.dart';
import 'package:sudokuapp/pages/GameViews/GameTimer.dart';
import 'package:sudokuapp/pages/GameViews/NumberSelector.dart';
import 'package:sudokuapp/pages/GameViews/SudokuGrid.dart';
import 'GameScore.dart';

class Game extends StatefulWidget
{
  late PuzzleDifficulty _puzzleDifficulty;
  late SaveGame _saveGame;

  Game({PuzzleDifficulty? puzzleDifficulty, SaveGame? saveGame})
  {
    _puzzleDifficulty = puzzleDifficulty!;
    _saveGame = saveGame!;
  }

  @override
  _GameFormState createState() => _GameFormState();
}

class _GameFormState extends State<Game>
{
  final log = Logger('Game');
  var utilities = GetIt.instance.get<Utilities>();
  var audio = GetIt.instance.get<Audio>();
  var db = GetIt.instance.get<DatabaseService>();
  var puzzles = GetIt.instance.get<Puzzles>();
  DateTime _nextSaveAt = DateTime.now();

  late ActivePuzzle _activePuzzle;

  bool _isComplete = false;
  bool _loading = true;
  CellValue? _selectedCellValue;
  var _activePuzzleBS = BehaviorSubject<ActivePuzzle>();
  var _cellValueBS = BehaviorSubject<CellValue>();

  @override
  void initState()
  {
    _asyncMethod();
    super.initState();
  }

  _asyncMethod() async {

    //Load the save game or create a new game based on the passed difficulty setting
    Puzzle puzzle;
    if(widget._saveGame != null)
    {
      puzzle = puzzles.getPuzzleById(widget._saveGame.puzzleId)!;
    }
    else
    {
      puzzle = puzzles.getPuzzleOfDifficulty(widget._puzzleDifficulty)!;
      widget._saveGame = new SaveGame(puzzle.puzzleId);
    }

    //Load the activepuzzle from the saveGame
    _activePuzzle = new ActivePuzzle(puzzle, widget._saveGame);
    await db.insertOrUpdateSaveGame(widget._saveGame);

    //Listen for puzzle completion
    _activePuzzleBS.listen((activePuzzle)
    {
      _activePuzzle.copyFrom(activePuzzle);
      checkForPuzzleCompletion();
    });

    //Listen for cell selection and deselection events
    _cellValueBS.listen((cellValue)
    {
      if(cellValue != null && cellValue.cellValueUpdateReason == CellValueUpdateReason.Selection && cellValue.isSelected)
      {
        _selectedCellValue = cellValue;
      }
    });

    setState(() {_loading = false;});
  }

  @override
  Widget build(BuildContext context)
  {
    if(_loading)
    {
      return SpinKitWave(color: Colors.orange, type: SpinKitWaveType.center);
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("${_activePuzzle.puzzle.difficulty.toStr} puzzle")
      ),
      body:
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Padding(
          padding: new EdgeInsets.all(8.0),
          child: GameWindow()
        )
      ));
  }

  Widget GameWindow()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new GameTimer(_activePuzzle.saveGame.elapsedSeconds!, onTick),
        new SudokuGrid(_activePuzzle, _cellValueBS),
        Container
        (
          child: Text(""),
          height: 8,
          width: MediaQuery.of(context).size.width,
        ),
        new NumberSelector(numberEntered, provideHint)
      ],
    );
  }

  void saveProgress()
  {
    db.insertOrUpdateSaveGame(_activePuzzle.saveGame);
  }

  void onTick(int elapsed)
  {
    if(_isComplete == false)
    {
      //log.fine("Game.onTick: game timer at $elapsed");
      _activePuzzle.saveGame.elapsedSeconds = elapsed;
      var now = DateTime.now();
      if(_nextSaveAt.isBefore(now))
      {
        log.fine("Game.onTick: Save Frequency reached triggering save now");
        _nextSaveAt = now.add(Duration(seconds: utilities.getPreferenceAsInt("SaveFrequency")));
        db.insertOrUpdateSaveGame(_activePuzzle.saveGame);
      }
    }
  }

  void provideHint()
  {
    var cellValue = _activePuzzle.provideHint();
    if(cellValue != null)
    {
      cellValue.cellValueUpdateReason = CellValueUpdateReason.Hint;
      _cellValueBS.add(cellValue);

      checkForPuzzleCompletion();
    }
  }

  void numberEntered(String value, bool isNote)
  {
    if(_selectedCellValue?.cell != null)
    {
      if(isNote)
      {
        _activePuzzle.setNoteByCell(_selectedCellValue!.cell, value);
      }
      else
      {
        _activePuzzle.setValueByCell(_selectedCellValue!.cell, value);
      }

      var cellValue = _activePuzzle.getCellValueByCell(_selectedCellValue!.cell);
      if(utilities.getPreferenceAsBool("ShowIncorrect"))
      {
        cellValue.isCellCorrect = _activePuzzle.isCellCorrect(_selectedCellValue!.cell.row, _selectedCellValue!.cell.col);
      }
      cellValue.isSelected = true;
      cellValue.cellValueUpdateReason = CellValueUpdateReason.ValueChanged;

      _cellValueBS.add(cellValue);

      checkForPuzzleCompletion();
    }
  }

  void checkForPuzzleCompletion()
  {
    _isComplete = _activePuzzle.isPuzzleComplete();
    if(_isComplete)
    {
      log.fine("Puzzle is complete");
      _activePuzzle.clearListeners();
      var score = _activePuzzle.calculateScore();
      db.insertOrUpdateScore(score);
      db.deleteSaveGame(_activePuzzle.saveGame.id!);

      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => GameScore(_activePuzzle.puzzle, score)));
    }
  }

  @override
  void dispose() {
    saveProgress();
    super.dispose();
  }
}