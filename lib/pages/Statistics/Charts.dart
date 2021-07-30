import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/pages/Statistics/ScoresChart.dart';
import 'DifficultyChart.dart';
import 'SolveRatioChart.dart';
import 'WinLossChart.dart';

class Charts extends StatelessWidget
{
  List<Score> _scores;

  Charts(this._scores);

  @override
  Widget build(BuildContext context)
  {
    return CarouselSlider(
      options: CarouselOptions(height: 400.0),
        items: [
          ChartItem(DifficultyChart(_scores), "Completed by difficulty", "Shows yearly average refill costs grouped by servo, limited to the latest five years of data per servo"),
          ChartItem(SolveRatioChart(_scores), "Solve ratio", "Shows fuel cost per over time"),
          ChartItem(ScoresChart(_scores), "Monthly average scores", "Shows fuel cost per over time"),
          ChartItem(WinLossChart(_scores), "Twelve months of wins vs losses", "")
        ].map((chartItem) {
          return Container(
            child: Center(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                        color: Colors.transparent
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child:chartItem.chart),
                        Text(chartItem.chartName)
                      ],
                    ))
            ),
          );
        }).toList(),
    );
  }
}

class ChartItem
{
  final Widget chart;
  final String chartName;
  final String chartInfo;
  ChartItem(this.chart, this.chartName, this.chartInfo);
}