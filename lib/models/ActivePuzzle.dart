import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import "package:collection/collection.dart";
import 'package:sudokuapp/db/SaveGame.dart';
import 'package:sudokuapp/helpers/DatabaseService.dart';
import 'package:sudokuapp/helpers/StringExtensions.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/Boundary.dart';
import 'package:sudokuapp/models/Cell.dart';
import 'package:sudokuapp/models/CellType.dart';
import 'package:sudokuapp/models/CellValue.dart';
import 'Cells.dart';
import '../db/Score.dart';
import 'Puzzle.dart';
import 'dart:math';

class ActivePuzzle {
  late SaveGame saveGame;
  late Puzzle puzzle;

  var cells = new Cells();
  final log = Logger('ActivePuzzle');
  var utilities = GetIt.instance.get<Utilities>();
  var db = GetIt.instance.get<DatabaseService>();

  ActivePuzzle(
    this.puzzle,
    this.saveGame
  )
  {
   cells.initilise();
   if(saveGame.inProgress == null || saveGame.inProgress!.isEmpty)
   {
    reset();
   }
   db.streamSaves$.listen((x) async
   {
     log.fine("ActivePuzzle: Saves stream update detected");
     var updatedSaveGame = await db.getLatestSaveGame(puzzle.puzzleId);
     if(updatedSaveGame != null)
     {
       saveGame = updatedSaveGame;
      log.fine("ActivePuzzle updated ${saveGame.id}, secs ${saveGame.elapsedSeconds}");
     }
   });
  }

  void clearListeners() async
  {
    db.streamSaves$.take(await db.streamSaves$.length);
  }

  void reset()
  {
    saveGame.puzzleId = puzzle.puzzleId;
    saveGame.inProgress = getBlankData();
    saveGame.hints = getBlankData();
    saveGame.elapsedSeconds = 0;
    saveGame.lastPlayed = DateTime.now();
    if(saveGame.notes == null)
    {
      saveGame.notes = <String>[];
      for(var i = 0; i < 81; i++)
      {
        saveGame.notes.add("");
      }
    }
  }

  void copyFrom(ActivePuzzle activePuzzle)
  {
    saveGame.inProgress = activePuzzle.saveGame.inProgress;
    saveGame.hints = activePuzzle.saveGame.inProgress;
    saveGame.notes = activePuzzle.saveGame.notes;
  }

  String getBlankData()
  {
    var data = "";
    for(var i = 0; i < 81; i++)
    {
      data += ".";
    }
    return data;
  }

  bool isPuzzleComplete()
  {
    var userEntered = saveGame.inProgress?.getDigitCount() ?? 0;
    var hintsUsed = saveGame.hints?.getDigitCount() ?? 0;
    var cluesPresent = puzzle.clues.getDigitCount();
    var check = (userEntered + hintsUsed + cluesPresent) == 81;
    log.fine("Puzzle: IsPuzzleComplete - UserEntered $userEntered, hints $hintsUsed, initial clues $cluesPresent, Total is ${(userEntered + hintsUsed + cluesPresent)}, IsComplete $check");
    return check;
  }

  bool isPuzzleCorrect()
  {
    var isCorrect = false;
    if(isPuzzleComplete())
    {
      isCorrect = true;
      for(var i = 0; i < 81; i++)
      {
        if(saveGame.inProgress![i] != puzzle.puzzle[i] && saveGame.hints![i] == "." && puzzle.clues[i] != puzzle.puzzle[i])
        {
          isCorrect = false;
          break;
        }
      }
    }
    log.fine("Puzzle: IsPuzzleCorrect isCorrect:$isCorrect");
    return isCorrect;
  }

  bool isCellCorrect(row, col)
  {
    log.fine("Puzzle: IsCellCorrect - Row $row Col $col Attempting to provide a hint");
    var cell = cells.getCell(row, col);
    if(saveGame.inProgress![cell.index] != ".")
    {
      return saveGame.inProgress![cell.index] == puzzle.puzzle[cell.index];
    }
    if(saveGame.notes[cell.index] != "undefined")
    {
      return false;
    }
    return true;
  }

  CellValue? provideHint()
  {
    log.fine("Puzzle: provideHint - Attempting to provide a hint");
    var unusedIndecies = [];
    for (var index = 0; index < 81; index++)
    {
      if(saveGame.inProgress![index] == "." &&
          puzzle.clues[index] == "." &&
          saveGame.hints![index] == ".")
      {
        unusedIndecies.add(index);
      }
    }
    if(unusedIndecies.length > 0)
    {
      log.fine("Puzzle: provideHint - There are ${unusedIndecies.length} possible hint values to choose from");

      var cell = cells.cells[unusedIndecies[utilities.random.nextInt(unusedIndecies.length)]];
      var value = puzzle.puzzle[cell.index];
      log.fine("Puzzle: provideHint - Picked index ${cell.index} value of $value with row ${cell.row} col ${cell.col}");
      saveGame.hints = saveGame.hints!.replaceChar(cell.index, value);
      updateNotes(cell, value);
      db.insertOrUpdateSaveGame(saveGame);
      return new CellValue(cell, CellType.HINTED_CLUE, value, true);
    }
    else
    {
      log.fine("Puzzle: provideHint - No unused indecies");
      return null;
    }
  }

  //This is called when a normal number is entered
  //It needs to remove the cells note if there is one then update cells on the same
  //row or column if they have corresponding note values
  void updateNotes(cell, value)
  {
    log.fine("Puzzle: UpdateNotes - Row ${cell.row} Col ${cell.col} val $value");
    //When someone enters a number or a hint it can change the filled in notes on the puzzle
    if(saveGame.notes[cell.index].isNotEmpty)
    {
      saveGame.notes[cell.index] = "";
    }
    if(saveGame.notes.length > 0)
    {
      //Check the entire row for this cell for notes containing the same number
      for(var c = 0; c < 9; c++)
      {
        var innerIndex = cells.getCell(cell.row, c);
        if(saveGame.notes[innerIndex.index].isNotEmpty)
        {
          //This should be safe to call even if the value doesnt exist in the array
          saveGame.notes[innerIndex.index] = "";
        }
      }
      //Check the entire column for this cell for notes containing the same number
      for(var r = 0; r < 9; r++)
      {
        var innerIndex = cells.getCell(r, cell.col);
        if(saveGame.notes[innerIndex.index].isNotEmpty)
        {
          //This should be safe to call even if the value doesnt exist in the array
          saveGame.notes[innerIndex.index] = "";
        }
      }
      //Check the grid that the cell comes from and remove the number from any notes there
      var boundary = getBoundary(cell);

      for (var r = boundary.startRow; r < boundary.endRow; r++)
      {
        for (var c = boundary.startCol; c < boundary.endCol; c++)
        {
          var innerIndex = cells.getCell(r, c);
          if(saveGame.notes[innerIndex.index].isNotEmpty)
          {
            saveGame.notes[innerIndex.index] = "";
          }
        }
      }
    }
  }

  void setNoteByCell(Cell cell, value)
  {
    setNote(cell.row, cell.col, value);
  }

  void setNote(row, col, value)
  {
    var cell = cells.getCell(row, col);
    log.fine("aPuzzle: setNote - Setting/adding a note to cell index ${cell.index} value $value");
    //If this was previously a entered value replace it with the note
    if(saveGame.inProgress![cell.index] != ".")
    {
      log.fine("aPuzzle: setNote - Had previous non note value, clearing the entry");
      saveGame.inProgress = saveGame.inProgress!.replaceChar(cell.index, ".");
    }
    if(saveGame.notes[cell.index].isEmpty)
    {
      log.fine("aPuzzle: setNote - There were no previous notes in this cell, creating one");
      saveGame.notes[cell.index] = value;
    }
    else
    {
      //If this already had the same note in the cell
      if(saveGame.notes[cell.index] == value)
      {
        log.fine("aPuzzle: setNote - This value already was a note, removing");
        saveGame.notes[cell.index] = saveGame.notes[cell.index] = "";
      }
      else
      {
        log.fine("aPuzzle: setNote - Adding note to existing note array for this cell");

        if(saveGame.notes[cell.index].contains(value))
        {
          saveGame.notes[cell.index] = saveGame.notes[cell.index].replaceAll(value, "");
        }
        else
        {
          saveGame.notes[cell.index] = saveGame.notes[cell.index] + value;
        }
      }
    }
    db.insertOrUpdateSaveGame(saveGame);
  }

  void setValueByCell(Cell cell, value)
  {
    setValue(cell.row, cell.col, value);
  }

  void setValue(row, col, value)
  {
    var cell = cells.getCell(row, col);
    //If the value already exists then remove it
    if(saveGame.inProgress![cell.index] == value)
    {
      saveGame.inProgress = saveGame.inProgress!.replaceChar(cell.index, ".");
    }
    else
    {
      saveGame.inProgress = saveGame.inProgress!.replaceChar(cell.index, value);
      updateNotes(cell, value);
    }
    db.insertOrUpdateSaveGame(saveGame);
  }

  CellValue getCellValueByCell(Cell cell)
  {
    return getCellValue(cell.row, cell.col);
  }

  CellValue getCellValue(row, col)
  {
    var cell = cells.getCell(row, col);

    if(puzzle.clues[cell.index] != ".")
      return CellValue(cell, CellType.INITIAL_CLUE, puzzle.clues[cell.index], true);
    if(saveGame.inProgress![cell.index] != ".")
      return CellValue(cell, CellType.USER_ENTERED, saveGame.inProgress![cell.index], utilities.getPreferenceAsBool("ShowIncorrect") ? isCellCorrect(row, col) : true);
    if(saveGame.hints![cell.index] != ".")
      return CellValue(cell, CellType.HINTED_CLUE, saveGame.hints![cell.index], true);
    if(saveGame.notes.length > 0 && saveGame.notes[cell.index].isNotEmpty)
    {
      var noteText = "";
      for(var i = 0; i < 9; i++)
      {
        var iAsString = (i + 1).toString();
        noteText += "${saveGame.notes[cell.index].contains(iAsString) ? iAsString : " "}";
        if(i == 2 || i == 5)
        {
          noteText += "\r\n";
        }
        else
        {
          noteText += " ";
        }
      }
      return CellValue(cell, CellType.NOTE, noteText.trimRight(), true);
    }
    return CellValue(cell, CellType.BLANK, " ", true);
  }

  Boundary getBoundary(Cell cell)
  {
    var boundary = Boundary(0, 3, 0, 3);
    if(cell.col <= 2)
    {
      boundary.startCol = 0;
      boundary.endCol = 3;
    }
    else if(cell.col <= 5)
    {
      boundary.startCol = 3;
      boundary.endCol = 6;
    }
    else
    {
      boundary.startCol = 6;
      boundary.endCol = 9;
    }

    if(cell.row <= 2)
    {
      boundary.startRow = 0;
      boundary.endRow = 3;
    }
    else if(cell.row <= 5)
    {
      boundary.startRow = 3;
      boundary.endRow = 6;
    }
    else
    {
      boundary.startRow = 6;
      boundary.endRow = 9;
    }
    return boundary;
  }

  Score calculateScore()
  {
    var isCorrect = isPuzzleCorrect();
    var hintsUsed = saveGame.hints!.getDigitCount();
    var hintsUsedAsDouble = hintsUsed.toDouble();
    var hintScore = 0.0;
    if(hintsUsedAsDouble > 0)
      hintScore = hintsUsedAsDouble * (2.5 + (hintsUsedAsDouble * 2.5)) * 7.0;
    var timeScore = ((20000000 - (saveGame.elapsedSeconds! * 1200)) /1000) * 2;
    var combined = (timeScore * puzzle.difficulty.index * (isCorrect ? 2.5 : -8.0)) - hintScore;

    var solveRate = (saveGame.inProgress!.getDigitCount() / saveGame.elapsedSeconds!) / 60;


    var score = new Score(
      saveGame.puzzleId,
      saveGame.elapsedSeconds!,
      solveRate,
      hintsUsed,
      max((combined + (solveRate * 500)) + 0.5, 0),
      isCorrect,
      false,
      DateTime.now(),
    );

    log.fine("aPuzzle: calculateScore - Completed puzzle ${score.puzzleId} on ${score.completed}, Scored ${score.combinedScore} used ${score.hintsUsed} hints, took ${score.elapsedSeconds}sec to complete with a solveRate of $solveRate p/min");
    return score;
  }

  @override
  String toString() {
    var output = "Puzzle: ${saveGame.puzzleId} has taken ${saveGame.elapsedSeconds} seconds";//, has been completed ${this.attempts} times";
    for (var row = 0; row < 9; row++)
    {
      output += "\n";
      for (var col = 0; col < 9; col++)
      {
        var cell = cells.getCell(row, col);
        output += " ${puzzle.puzzle[cell.index]}";
      }
    }
    output += "\n";
    output += "\nThere are ${saveGame.inProgress!.getDigitCount()} user entered values";
    output += "\nThere are ${saveGame.hints!.getDigitCount()} hints";
    output += "\nThere are ${saveGame.notes.length} notes";
    output += "\nThe puzzle contains ${puzzle.clues.getDigitCount()} initial clues";

    return output;
  }

  @override
  bool operator ==(o) => o is Puzzle && o.puzzleId == puzzle.puzzleId;

  @override
  int get hashCode => super.hashCode;
}