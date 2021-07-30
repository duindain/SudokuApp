import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:sudokuapp/db/SaveGame.dart';
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/AchievementData.dart';
import 'package:sudokuapp/models/AudioType.dart';
import 'package:sudokuapp/models/GoogleAccount.dart';
import 'package:sudokuapp/models/LeaderboardData.dart';
import 'package:sudokuapp/models/Puzzle.dart';
import 'package:sudokuapp/models/PuzzleDifficulty.dart';
import 'package:sudokuapp/pages/Animations/Text/FireworksText.dart';
import 'package:sudokuapp/pages/Animations/Text/TextModel.dart';
import 'Game.dart';
import 'package:sudokuapp/helpers/StringExtensions.dart';

class GameScore extends StatelessWidget
{
  var audio = GetIt.instance.get<Audio>();
  var utilities = GetIt.instance.get<Utilities>();
  var googleAccount = GetIt.instance.get<GoogleAccount>();
  var leaderboardData = GetIt.instance.get<LeaderboardData>();
  var achievementData = GetIt.instance.get<AchievementData>();

  Puzzle _puzzle;
  Score _score;

  GameScore(this._puzzle, this._score);

  @override
  Widget build(BuildContext context)
  {
    audio.playRandomByName(_score.isCorrect ? "Win" : "Fail", AudioType.Effect);

    //If logged in

    //utilities.sendScore(_score);
    if(utilities.getPreferenceAsBool("UploadGames"))
    {
      if(googleAccount.isSignedIn() == false)
      {
        googleAccount.signInWithGoogle();
      }

      if(googleAccount.isSignedIn())
      {
        if(_score.isCorrect)
        {
          leaderboardData.submitScore(_score);
        }
        achievementData.submitScore(_puzzle, _score);
      }
    }
    var widgets = <Widget>[];

    widgets.add(graphicWindow(context));
    widgets.addAll(getStatistics(context));
    widgets.addAll(createDifficultyVotingRows(context));
    widgets.add(replayOptions(context));

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Puzzle ${_score.isCorrect ? "solved" : "incorrect"}")
      ),
      body:
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Padding(
          padding: new EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widgets,
          )
        )
      ));
  }

  List<Widget> getStatistics(BuildContext buildContext)
  {
    return [
    Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(text: _score.isCorrect ? '\n\n Victory \n\n' : '\n\n Oh biscuits \n\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          if(_score.isCorrect)
            TextSpan(text: 'You solved the puzzle correctly\n\n'
              'This puzzle was completed in ${utilities.formatDuration(Duration(seconds: _score.elapsedSeconds))}\n'
              'Solution solve ratio ${_score.puzzleSolveRate} per second\n'
              'You used ${_score.hintsUsed > 0 ? "${_score.hintsUsed} out of a possible ${81 - _puzzle.clues.getDigitCount()}" : "no"} hints\n\n'
              '${(_score.combinedScore > 0 ? 'You scored ${_score.combinedScore} points' : 'No score for this one, try using less hints next time to get a higher score')}\n\n'
              'Score is based on how quickly the puzzle was solved, how few if any hints were used and the difficulty rating of the puzzle.\n\n', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))
          else
            TextSpan(text: 'Unfortunately the solution given doesn\'t solve the puzzle\n\n'
                'If you have trouble solving puzzles turning on the\n'
                '\'Show Incorrect Entries\' option in settings may be helpful\n'
                'This puzzle was completed in ${utilities.formatDuration(Duration(seconds: _score.elapsedSeconds))}\n\n'
                'Unfortunately no score is kept for puzzles that aren\'t correct but we will track improvement ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14))
          ],
      ),
    textAlign: TextAlign.center,)];
  }

  Widget graphicWindow(BuildContext buildContext)
  {
    return SizedBox(
      height: 125.0,
      child: FireworksText(new TextModel(_score.isCorrect)),
    );
  }

  List<Widget> createDifficultyVotingRows(BuildContext buildContext)
  {
    var rows = <Widget>[];

    rows.add(Text("What difficulty rating do you think this puzzle was?"));
    var containers = List.generate(PuzzleDifficulty.values.length, (index)
    {
      var difficulty = PuzzleDifficulty.values[index];
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left:10,right:10),
          child: RaisedButton(
            onPressed: ()
            {
              audio.buttonPress();
              if(utilities.getPreferenceAsBool("UploadGames"))
              {
                if(googleAccount.isSignedIn() == false)
                {
                  googleAccount.signInWithGoogle();
                }

                if(googleAccount.isSignedIn())
                {
                  achievementData.submitVote();
                }
              }
              utilities.voteOnPuzzleDifficulty(_puzzle.puzzleId, difficulty);
              utilities.showToast(buildContext, "Thanks for voting.");
            },
            child: Text(difficulty.toStr),
            color: difficulty == _puzzle.difficulty ? Colors.green : Colors.blueGrey
          )
      );
    });

    var columns = 3;
    for(var index = 0; index < containers.length; index += columns)
    {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: containers.length >= index + columns ? containers.sublist(index, index + columns) : [containers.last],
      ));
    }
    return rows;
  }

  //Not sure how this will work the library doesnt support searching for friends yet
  //might need to use email addresses or something and handle it on own server?
  Widget replayOptions(BuildContext buildContext)
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        FlatButton.icon(
          icon: FaIcon(FontAwesomeIcons.playCircle), //`Icon` to display
          label: Text('New game'), //`Text` to display
          onPressed: () {
            audio.buttonPress();
            var saveGame = new SaveGame(_score.puzzleId);
            Navigator.pushNamedAndRemoveUntil(buildContext, "/playorcontinue", ModalRoute.withName('/mainmenu'));
          },
        ),
        FlatButton.icon(
          icon: FaIcon(FontAwesomeIcons.stop), //`Icon` to display
          label: Text('Done'), //`Text` to display
          onPressed: () {
            audio.buttonPress();
            Navigator.of(buildContext).popUntil((route) => route.isFirst);
          },
        ),
        FlatButton.icon(
          icon: FaIcon(FontAwesomeIcons.syncAlt), //`Icon` to display
          label: Text('Replay'), //`Text` to display
          onPressed: () {
            audio.buttonPress();
            var saveGame = new SaveGame(_score.puzzleId);
            Navigator.popUntil(buildContext, ModalRoute.withName('/playorcontinue'));
            Navigator.push(buildContext, MaterialPageRoute(builder: (context) => Game(saveGame: saveGame)));
          },
        ),
      ]
    );
  }

  Widget challengeOptions(BuildContext buildContext)
  {
    if(utilities.getPreferenceAsBool("UseGoogleServices"))
    {
      if(googleAccount.isSignedIn() == false)
      {
        googleAccount.signInWithGoogle();
      }

      if(googleAccount.isSignedIn())
      {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              FlatButton.icon(
                icon: FaIcon(FontAwesomeIcons.handSpock), //`Icon` to display
                label: Text('Challenge a frienemy to beat your score'), //`Text` to display
                onPressed: () {
                  audio.buttonPress();
                },
              ),
            ]
        );
      }
      else
      {
        utilities.showToast(buildContext, "Couldn't sign in right now, please try again later");
      }
    }
    return Container();
  }
}