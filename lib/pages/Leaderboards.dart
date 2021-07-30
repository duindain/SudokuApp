import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:play_games/play_games.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/models/GoogleAccount.dart';
import 'package:sudokuapp/models/LeaderboardData.dart';

class Leaderboards extends StatelessWidget
{
  var googleAccount = GetIt.instance.get<GoogleAccount>();
  var audio = GetIt.instance.get<Audio>();
  var leaderboardData = GetIt.instance.get<LeaderboardData>();

  @override
  Widget build(BuildContext context)
  {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Leaderboards")
      ),
      body:
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: createLeaderboardRows(context)
          )
        )
    );
  }

  List<Widget> createLoginBlurb(BuildContext context)
  {
    var widgets = <Widget>[];

    return widgets;
  }

  List<Widget> createLeaderboardRows(BuildContext context)
  {
    var widgets = <Widget>[];

    for(var index = 0; index < leaderboardData.leaderboards.length; index++)
    {
      var leaderboard = leaderboardData.leaderboards[index];
      widgets.add(Container(
        margin: EdgeInsets.only(left:75, top:10, bottom:10),
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
          icon: Image(image:AssetImage(leaderboard.iconResource), width: 50, height: 50), //`Icon` to display
          label: Text(leaderboard.name), //`Text` to display
          onPressed: () {
            audio.buttonPress();
            PlayGames.showLeaderboard(leaderboard.id);
          },
        ),
      ));
    }
    return widgets;
  }
}