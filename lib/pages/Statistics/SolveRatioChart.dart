/// Example of timeseries chart that has a measure axis that does NOT include
/// zero. It starts at 100 and goes to 140.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sudokuapp/db/Puzzles.dart';
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/PuzzleDifficulty.dart';
import "package:collection/collection.dart";

class SolveRatioChart extends StatelessWidget  {

  List<Score> _scores;
  bool animate = true;

  var puzzles = GetIt.instance.get<Puzzles>();
  var utilities = GetIt.instance.get<Utilities>();

  SolveRatioChart(this._scores);

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(createChartData(_scores.isNotEmpty ? _createRealData() : _createSampleData()),
        animate: animate,
        // Provide a tickProviderSpec which does NOT require that zero is
        // included.
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
            new charts.BasicNumericTickProviderSpec(zeroBound: false)));
  }

  List<MyRow> _createRealData()
  {
    var data = <MyRow>[];
    for(var score in _scores)
    {
      data.add(MyRow(score.completed, score.puzzleSolveRate.toInt()));
    }
    return data;
  }

  /// Create one series with sample hard coded data.
  List<MyRow> _createSampleData() {
    return [
      new MyRow(new DateTime(2017, 9, 25), 106),
      new MyRow(new DateTime(2017, 9, 26), 108),
      new MyRow(new DateTime(2017, 9, 27), 106),
      new MyRow(new DateTime(2017, 9, 28), 109),
      new MyRow(new DateTime(2017, 9, 29), 111),
      new MyRow(new DateTime(2017, 9, 30), 115),
      new MyRow(new DateTime(2017, 10, 01), 125),
      new MyRow(new DateTime(2017, 10, 02), 133),
      new MyRow(new DateTime(2017, 10, 03), 127),
      new MyRow(new DateTime(2017, 10, 04), 131),
      new MyRow(new DateTime(2017, 10, 05), 123),
    ];
  }

  List<charts.Series<MyRow, DateTime>> createChartData(List<MyRow> data)
  {
    return [
      new charts.Series<MyRow, DateTime>(
        id: 'Headcount',
        domainFn: (MyRow row, _) => row.timeStamp,
        measureFn: (MyRow row, _) => row.headcount,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class MyRow {
  final DateTime timeStamp;
  final int headcount;
  MyRow(this.timeStamp, this.headcount);
}