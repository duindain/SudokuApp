import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:play_games/play_games.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudokuapp/pages/Authentication.dart';
import 'Animations/AnimatedBackground.dart';
import 'Animations/Particles.dart';

class MainMenu extends StatelessWidget
{
  var audio = GetIt.instance.get<Audio>();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
          leading:Icon(Icons.grid_on),
        title:Text("Sudoku App"),
        actions:<Widget>[
          new PopupMenuButton<String>(
            itemBuilder: (BuildContext context)
            {
              return [
                PopupMenuItem(child:
                FlatButton.icon(
                  icon: Icon(Icons.settings), //`Icon` to display
                  label: Text('Settings'), //`Text` to display
                  onPressed: () {
                    audio.buttonPress();
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),),
                PopupMenuItem(child:FlatButton.icon(
                  icon: Icon(Icons.info), //`Icon` to display
                  label: Text('About the app'), //`Text` to display
                  onPressed: () {
                    audio.buttonPress();
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => AboutApp()));
                    Navigator.of(context).pushNamed('/aboutapp');
                  },
                ),)
              ];
            },
          )
        ]
      ),
      body: _buildBody(context)
    );
  }

  Widget _buildBody(BuildContext context)
  {
    return Stack(children: <Widget>[
      Positioned.fill(child: AnimatedBackground()),
      Positioned.fill(child: Particles(30)),
      Positioned.fill(child: new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FlatButton.icon(
            icon: FaIcon(FontAwesomeIcons.play), //`Icon` to display
            label: Text('Play'), //`Text` to display
            onPressed: () {
              audio.buttonPress();
              //Navigator.push(context, MaterialPageRoute(builder: (context) => PlayOrContinue()));
              Navigator.of(context).pushNamed('/playorcontinue');
            },
          ),
          FlatButton.icon(
            icon: FaIcon(FontAwesomeIcons.table), //`Icon` to display
            label: Text('Statistics'), //`Text` to display
            onPressed: () {
              audio.buttonPress();
              //Navigator.push(context, MaterialPageRoute(builder: (context) => Statistics()));
              Navigator.of(context).pushNamed('/statistics');
            },
          ),
          FlatButton.icon(
            icon: FaIcon(FontAwesomeIcons.listOl), //`Icon` to display
            label: Text('Leaderboards'), //`Text` to display
            onPressed: () {
              audio.buttonPress();
              //Navigator.push(context, MaterialPageRoute(builder: (context) => Leaderboards()));
              Navigator.of(context).pushNamed('/leaderboards');
            },
          ),
          FlatButton.icon(
            icon: FaIcon(FontAwesomeIcons.trophy), //`Icon` to display
            label: Text('Achievements'), //`Text` to display
            onPressed: () {
              audio.buttonPress();
              //Navigator.push(context, MaterialPageRoute(builder: (context) => Achievements()));
              PlayGames.showAchievements();
              //Navigator.of(context).pushNamed('/achievements');
            },
          ),
          FlatButton.icon(
            icon: FaIcon(FontAwesomeIcons.gamepad), //`Icon` to display
            label: Text('Challenges'), //`Text` to display
            onPressed: () {
              audio.buttonPress();
              //Navigator.push(context, MaterialPageRoute(builder: (context) => Challenges()));
              Navigator.of(context).pushNamed('/challenges');
            },
          ),
           Container(
              margin: EdgeInsets.only(right: 20.0),
              child: Align(
                alignment: FractionalOffset.bottomRight,
                child: Authentication()
              ),)
          ]

      )),
    ]);

  }
}