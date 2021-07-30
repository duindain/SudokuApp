/// Simple pie chart with outside labels example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sudokuapp/db/Puzzles.dart';
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/PuzzleDifficulty.dart';
import 'dart:collection';

//Shows Number of puzzles of difficulty completed successfully
//
class DifficultyChart extends StatelessWidget {

  List<Score> _scores;
  bool animate = true;

  var puzzles = GetIt.instance.get<Puzzles>();
  var utilities = GetIt.instance.get<Utilities>();

  DifficultyChart(this._scores);

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(createChartData(_scores?.isNotEmpty ?? false ? _createRealData() : _createSampleData()),
      animate: animate,
      defaultRenderer: new charts.ArcRendererConfig(
        //arcWidth: 60,
        arcRendererDecorators: [new charts.ArcLabelDecorator()]));
  }

  List<LinearDifficulty> _createRealData()
  {
    var data = <LinearDifficulty>[];
    for(var index = 0; index < PuzzleDifficulty.values.length; index++)
    {
      var count = 0;
      for(var score in _scores)
      {
        var puzzle = puzzles.getPuzzleById(score.puzzleId);
        if(puzzle!.difficulty.index == index)
        {
          count++;
        }
      }
      if(count > 0)
      {
        data.add(LinearDifficulty(index, count));
      }
    }
    return data;
  }

  /// Create one series with sample hard coded data.
  List<LinearDifficulty> _createSampleData() {
    var data = <LinearDifficulty>[];
    for(var index = 0; index < PuzzleDifficulty.values.length; index++)
    {
      data.add(LinearDifficulty(index, utilities.random.nextInt(100)));
    }
    return data;
  }

  List<charts.Series<LinearDifficulty, int>> createChartData(List<LinearDifficulty> data)
  {
    return [
      new charts.Series<LinearDifficulty, int>(
        id: 'Difficulty',
        domainFn: (LinearDifficulty difficulty, _) => difficulty.difficulty,
        measureFn: (LinearDifficulty difficulty, _) => difficulty.completed,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearDifficulty row, _) => '${PuzzleDifficulty.values[row.difficulty].toStr}: ${row.completed}',
      )
    ];
  }
}

/// Sample linear data type.
class LinearDifficulty {
  final int difficulty;
  final int completed;

  LinearDifficulty(this.difficulty, this.completed);
}