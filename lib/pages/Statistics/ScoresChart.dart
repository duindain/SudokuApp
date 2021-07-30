import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import "package:collection/collection.dart";
import 'package:sudokuapp/db/Puzzles.dart';
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ScoresChart extends StatelessWidget {

  List<Score> _scores;
  bool animate = true;

  var puzzles = GetIt.instance.get<Puzzles>();
  var utilities = GetIt.instance.get<Utilities>();

  ScoresChart(this._scores);

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(createChartData(_scores?.isNotEmpty ?? false ? _createRealData() : _createSampleData()),
        animate: animate,
      /// Customize the primary measure axis using a small tick renderer.
      /// Use String instead of num for ordinal domain axis
      /// (typically bar charts).
      primaryMeasureAxis: new charts.NumericAxisSpec(
      renderSpec: new charts.GridlineRendererSpec(
      // Display the measure axis labels below the gridline.
      //
      // 'Before' & 'after' follow the axis value direction.
      // Vertical axes draw 'before' below & 'after' above the tick.
      // Horizontal axes draw 'before' left & 'after' right the tick.
      labelAnchor: charts.TickLabelAnchor.before,

      // Left justify the text in the axis.
      //
      // Note: outside means that the secondary measure axis would right
      // justify.
      labelJustification: charts.TickLabelJustification.outside,
    )),
    );
  }

  List<MonthlyData> _createRealData()
  {
    var temp = <MonthlyData>[];

    var query = groupBy(_scores, (a) => "$a.completed.month-$a.completed.year");

    query.forEach((key, value)
    {
      var firstRefill = value.firstWhere((a) => a.id! > 0);
      if(firstRefill.puzzleId.isNotEmpty)
      {
        temp.add(MonthlyData(firstRefill.completed, utilities.sumList(value, (Score x) => x.combinedScore).toInt()));
      }
    });

    var data = <MonthlyData>[];

    temp.sort((MonthlyData a,MonthlyData b)
    {
      if(a.year != b.year)
      {
        return a.year.compareTo(b.year);
      }
      return a.month.compareTo(b.year);
    });

    temp.take(12).forEach((item) {
      data.add(MonthlyData(item.dateTime, item.score));
    });
    return data;
  }

  /// Create one series with sample hard coded data.
  List<MonthlyData> _createSampleData() {
    return [
      MonthlyData(DateTime(2017, 1, 25), 106),
      MonthlyData(DateTime(2017, 2, 26), 108),
      MonthlyData(DateTime(2017, 3, 27), 106),
      MonthlyData(DateTime(2017, 4, 28), 109),
      MonthlyData(DateTime(2017, 5, 29), 22),
      MonthlyData(DateTime(2017, 6, 30), 44),
      MonthlyData(DateTime(2017, 8, 01), 125),
      MonthlyData(DateTime(2017, 10, 02), 133),
      MonthlyData(DateTime(2017, 11, 03), 127),
      MonthlyData(DateTime(2018, 2, 04), 215),
      MonthlyData(DateTime(2018, 3, 05), 123),
    ];
  }

  List<charts.Series<MonthlyData, String>> createChartData(List<MonthlyData> data)
  {
    return [
      new charts.Series<MonthlyData, String>(
        id: 'Difficulty',
        domainFn: (MonthlyData difficulty, _) => difficulty.dateFormatted,
        measureFn: (MonthlyData difficulty, _) => difficulty.score,
        data: data,
        // Set a label accessor to control the text of the arc label.
        //labelAccessorFn: (OrdinalScores row, _) => '${PuzzleDifficulty.values[row.difficulty].toStr}: ${row.completed}',
      )
    ];
  }
}

//Temporary model to store data needed to sort and order data into the correct format
class MonthlyData {
  late int month;
  late int year;
  late String dateFormatted;
  final DateTime dateTime;
  final int score;

  MonthlyData(this.dateTime, this.score)
  {
    dateFormatted = DateFormat('MMMM y').format(dateTime);
    month = dateTime.month;
    year = dateTime.year;
  }
}