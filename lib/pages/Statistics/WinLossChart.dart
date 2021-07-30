import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import "package:collection/collection.dart";
import 'package:sudokuapp/db/Puzzles.dart';
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class WinLossChart extends StatelessWidget {

  List<Score> _scores;
  bool animate = true;

  var puzzles = GetIt.instance.get<Puzzles>();
  var utilities = GetIt.instance.get<Utilities>();

  WinLossChart(this._scores);

  @override
  Widget build(BuildContext context) {
    return new Semantics(
      // Describe your chart
        label: 'Wins and losses over month',
        // Optionally provide a hint for the user to know how to trigger
        // explore mode.
        hint: 'Press and hold to enable explore',
        child: new charts.BarChart(
          createChartData(_scores?.isNotEmpty ?? false ? _createRealData() : _createSampleData()),
          animate: animate,
          // To prevent conflict with the select nearest behavior that uses the
          // tap gesture, turn off default interactions when the user is using
          // an accessibility service like TalkBack or VoiceOver to interact
          // with the application.
          defaultInteractions: !MediaQuery.of(context).accessibleNavigation,
          behaviors: [
            new charts.DomainA11yExploreBehavior(
              // Callback for generating the message that is vocalized.
              // An example of how to use is in [vocalizeDomainAndMeasures].
              // If none is set, the default only vocalizes the domain value.
              vocalizationCallback: vocalizeDomainAndMeasures,
              // The following settings are optional, but shown here for
              // demonstration purchases.
              // [exploreModeTrigger] Default is press and hold, can be
              // changed to tap.
              exploreModeTrigger: charts.ExploreModeTrigger.pressHold,
              // [exploreModeEnabledAnnouncement] Optionally notify the OS
              // when explore mode is enabled.
              exploreModeEnabledAnnouncement: 'Explore mode enabled',
              // [exploreModeDisabledAnnouncement] Optionally notify the OS
              // when explore mode is disabled.
              exploreModeDisabledAnnouncement: 'Explore mode disabled',
              // [minimumWidth] Default and minimum is 1.0. This is the
              // minimum width of the screen reader bounding box. The bounding
              // box width is calculated based on the domain axis step size.
              // Minimum width will be used if the step size is smaller.
              minimumWidth: 1.0,
            ),
            // Optionally include domain highlighter as a behavior.
            // This behavior is included in this example to show that when an
            // a11y node has focus, the chart's internal selection model is
            // also updated.
            new charts.DomainHighlighter(charts.SelectionModelType.info),
          ],
        ));
  }

  /// An example of how to generate a customized vocalization for
  /// [DomainA11yExploreBehavior] from a list of [SeriesDatum]s.
  ///
  /// The list of series datums is for one domain.
  ///
  /// This example vocalizes the domain, then for each series that has that
  /// domain, it vocalizes the series display name and the measure and a
  /// description of that measure.
  String vocalizeDomainAndMeasures(List<charts.SeriesDatum> seriesDatums) {
    final buffer = new StringBuffer();

    // The datum's type in this case is [OrdinalSales].
    // So we can access year and sales information here.
    buffer.write(seriesDatums.first.datum.year);

    for (charts.SeriesDatum seriesDatum in seriesDatums) {
      final series = seriesDatum.series;
      final datum = seriesDatum.datum;

      buffer.write(' ${series.displayName} ''${datum.count}');
    }

    return buffer.toString();
  }

  List<List<MonthlyData>> _createRealData()
  {
    var wins = <MonthlyData>[];
    var losses = <MonthlyData>[];

    var query = groupBy(_scores, (a) => "$a.completed.month-$a.completed.year");

    query.forEach((key, value)
    {
      if(value.isNotEmpty)
      {
        var date = value.firstWhere((a) => a.completed.isAfter(utilities.minDateTime)).completed;
        wins.add(MonthlyData(date!, value.where((a) => a.isCorrect).length));
        losses.add(MonthlyData(date, value.where((a) => a.isCorrect == false).length));
      }
    });

    wins.sort((a,b)
    {
      if(a.year != b.year)
        return a.year.compareTo(b.year);
      return a.month.compareTo(b.month);
    });
    losses.sort((a,b)
    {
      if(a.year != b.year)
        return a.year.compareTo(b.year);
      return a.month.compareTo(b.month);
    });
    return [      
      wins.take(12).toList(),
      losses.take(12).toList()
    ];
  }

  /// Create one series with sample hard coded data.
  List<List<MonthlyData>> _createSampleData() {
    var wins = [
      MonthlyData(DateTime(2017, 1, 25), 87),
      MonthlyData(DateTime(2017, 2, 26), 65),
      MonthlyData(DateTime(2017, 3, 27), 87),
      MonthlyData(DateTime(2017, 4, 28), 112),
      MonthlyData(DateTime(2017, 5, 29), 44),
      MonthlyData(DateTime(2017, 6, 30), 33),
      MonthlyData(DateTime(2017, 8, 01), 113),
      MonthlyData(DateTime(2017, 10, 02), 127),
      MonthlyData(DateTime(2017, 11, 03), 167),
      MonthlyData(DateTime(2018, 2, 04), 211),
      MonthlyData(DateTime(2018, 3, 05), 40)
    ];
    var losses = [
      MonthlyData(DateTime(2017, 1, 25), 106),
      MonthlyData(DateTime(2017, 2, 26), 108),
      MonthlyData(DateTime(2017, 3, 27), 106),
      MonthlyData(DateTime(2017, 4, 28), 109),
      MonthlyData(DateTime(2017, 5, 29), 22),
      MonthlyData(DateTime(2017, 6, 30), 44),
      MonthlyData(DateTime(2017, 8, 01), 125),
      MonthlyData(DateTime(2017, 11, 02), 133),
      MonthlyData(DateTime(2018, 3, 05), 123)
    ];

    return [wins, losses];
  }

  List<charts.Series<MonthlyData, String>> createChartData(List<List<MonthlyData>> winsAndLosses)
  {
    return [
      new charts.Series<MonthlyData, String>(
        id: 'Wins',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (MonthlyData monthyData, _) => monthyData.dateFormatted,
        measureFn: (MonthlyData monthyData, _) => monthyData.count,
        data: winsAndLosses[0],
      ),
      new charts.Series<MonthlyData, String>(
        id: 'Losses',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (MonthlyData monthyData, _) => monthyData.dateFormatted,
        measureFn: (MonthlyData monthyData, _) => monthyData.count,
        data: winsAndLosses[1],
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
  final int count;

  MonthlyData(this.dateTime, this.count)
  {
    dateFormatted = DateFormat('MMMM y').format(dateTime);
    month = dateTime.month;
    year = dateTime.year;
  }
}