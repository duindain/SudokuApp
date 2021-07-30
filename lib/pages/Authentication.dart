import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:play_games/play_games.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/GoogleAccount.dart';

class Authentication extends StatefulWidget
{
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication>
{
  var utilities = GetIt.instance.get<Utilities>();
  var audio = GetIt.instance.get<Audio>();
  var googleAccount = GetIt.instance.get<GoogleAccount>();

  @override
  void initState()
  {
    _asyncMethod();
    super.initState();
  }

  _asyncMethod()  async
  {
    if(utilities.getPreferenceAsBool("AutoLogin", emptyValue: true) && googleAccount.isSignedIn() == false)
    {
      signInWithGoogle(silentRunning: true);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    if (googleAccount.isSignedIn())
    {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          googleUserCircleAvatar(context),
          FlatButton.icon(
            icon: FaIcon(FontAwesomeIcons.googlePlay), //`Icon` to display
            label: Text('Sign out'), //`Text` to display
            onPressed: () {
              audio.buttonPress();
              signOutGoogle();
            },
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton.icon(
            icon: FaIcon(FontAwesomeIcons.googlePlay), //`Icon` to display
            label: Text('Sign in'), //`Text` to display
            onPressed: () {
              audio.buttonPress();
              signInWithGoogle();
            },
          ),
        ],
      );
    }
  }

  /*
  CircleAvatar(
        backgroundImage: AssetImage('images/pic.jpg'),
        radius: 100,
      )
  */
  Widget googleUserCircleAvatar(BuildContext context)
  {
    return FutureBuilder(
      future: googleAccount.loadImage(),
      builder: (BuildContext context, AsyncSnapshot<Image> image)
      {
        if (image.hasData)
        {
          return ListTile(
            leading: image.data,
            title: Text(googleAccount.account.displayName ?? ''),
            onTap: signOutGoogle,
          );  // image is ready
        }
        else
        {
          return Container();  // placeholder
        }
      },
    );
  }

  void signInWithGoogle({bool silentRunning = false}) async
  {
    var message = await googleAccount.signInWithGoogle();
    if(message.isNotEmpty && silentRunning == false)
    {
      //utilities.showToast(buildContext, signInResult.message);
    }
    setState(() { });
  }

  void signOutGoogle() async
  {
    googleAccount.signOutWithGoogle();
    setState(() { });
  }
}