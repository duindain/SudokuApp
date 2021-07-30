import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/Puzzle.dart';
import 'package:sudokuapp/models/PuzzleDifficulty.dart';
import 'package:flutter/services.dart' show rootBundle;

class Puzzles
{
  final log = Logger('Puzzles');
  var utilities = GetIt.instance.get<Utilities>();
  late List<Puzzle> puzzles;

  Future initilise() async {
    puzzles = await rootBundle.loadString('assets/puzzles/20kpuzzles.dat').then((jsonStr) => parseJson(jsonStr));
    log.fine("Puzzles: loadPuzzles - Completed pre-loading ${puzzles.length} puzzles.");
  }

  Puzzle? getPuzzleById(puzzleId)
  {
    //log.fine("Puzzles: getPuzzle looking for puzzle with id $puzzleId");
    if(puzzles == null)
      return null;
    return puzzles.firstWhere((element) => element.puzzleId == puzzleId);
  }

  Puzzle? getPuzzleOfDifficulty(PuzzleDifficulty difficulty)
  {
    if(puzzles == null)
      return null;
    var itemsOfDifficulty = puzzles.where((a) => a.difficulty == difficulty);
    return itemsOfDifficulty.elementAt(utilities.random.nextInt(itemsOfDifficulty.length));
  }

  List<Puzzle> parseJson(String response)
  {
    if(response == null)
    {
      return [];
    }
    return (json.decode(response) as List).map((i) => Puzzle.fromJson(i)).toList();
  }
}