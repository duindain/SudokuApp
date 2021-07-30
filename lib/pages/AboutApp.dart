import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'dart:async';

class AboutApp extends StatelessWidget
{
  final String htmlData = """<p>
      This game is an effort to make learning and improving at Sudoku easier.
    </p>
    <p>
      This is accomplished by setting a limit on how many puzzles are available in each difficulty and allowing you to continue retraining on the same puzzles.
    </p>
    <p>
      The concept is that given a limit high enough to forget the steps involving in solving an individual puzzle while still being frequent enough to get repeatable statistics on each puzzle.
    </p>
    <p>
      With those results we can track our progression over time. These results can be shared and compared with friends and the Sudoku community to foster a sense of competition where appropriate hopefully allowing people to enjoy the game more while increasing our overall skillset.
    </p>
    <p>
    Sharing results is of course optional.
    <br/>
    This app uses Google Play Services for the following
    <ul>
      <li>Leaderboards for average scores</li>
      <li>Achievements for various stages of progression</li>
      <li>Events and Quests when possible</li>
      <li>Challenges where you can challenge a friend to beat your time in a specific puzzle</li>
      <li>Updates puzzle difficulty ratings via crowd sourced voting</li>
    </ul>
    <p>
      Google play services can be disabled through the Options menu if required.
    </p>
    <p>
      The program has employs battery saving techniques;
    </p>
    <ul>
      <li>Gyroscope is disabled on Android devices while in game</li>
      <li>Compass is disabled on Android devices while in game</li>
      <li>In most screens they are only refreshed when a UI event occurs (Unless the time is displayed then once per second)</li>
    </ul>
    <p>
      Updating of puzzle difficulties are based on votes recieved from community submissions. This will only happen when enough votes have been recieved to indicate a puzzle is incorrectly catagorized.
    </p>
    <p>
      Please send comments and suggestions to <a href="mailto:lazinatorapps@gmail.com" id="emailMe">lazinatorapps@gmail.com</a> or leave a review on the appstore
    </p>
    <br/>
    <br/>
      """;

  var audio = GetIt.instance.get<Audio>();
  final log = Logger('AboutApp');

  @override
  Widget build(BuildContext context)
  {
    return new Scaffold(
      appBar: AppBar(
        title: Text("About Sudoku App"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
      child: Html(
      data: htmlData,
      //Optional parameters:
      //backgroundColor: Colors.white70,
      onLinkTap: (url, _, __, ___) {
        if(url != null)
        {
          log.fine("Navigate to $url");
          audio.buttonPress();
          if(url.startsWith("mailto:"))
          {
            var email = Email(
              body: '',
              subject: 'Sudoku app',
              recipients: ['lazinatorapps@gmail.com'],
              isHTML: false,
            );
            FlutterEmailSender.send(email);
          }
        }
      },
      /*
      style: {
        "div": Style(
          block: Block(
            margin: EdgeInsets.all(16),
            border: Border.all(width: 6),
            backgroundColor: Colors.grey,
          ),
          textStyle: TextStyle(
            color: Colors.red,
          ),
        ),
      },*/
      onImageTap: (src, _, __, ___) {
        // Display the image in large form.
      },
    )));
  }
}