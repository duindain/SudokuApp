import 'dart:ui';

import 'package:play_games/play_games.dart';

class GoogleAccount
{
  late Account account;

  bool isSignedIn()
  {
    return account?.id?.isNotEmpty ?? false;
  }

  loadImage() async
  {
    return await account.iconImage;
  }

  Future<String> signInWithGoogle() async
  {
    var errorMessage = "";
    var signInResult = await PlayGames.signIn();
    if (signInResult.success)
    {
      await PlayGames.setPopupOptions();
      account = signInResult.account;
      print("User Sign In");
    }
    else
    {
      errorMessage = signInResult.message;
      print("Sign In issue $errorMessage");
    }
    return errorMessage;
  }

  void signOutWithGoogle() async
  {
    if(isSignedIn())
    {
      await PlayGames.signOut();
      print("User Sign Out");
    }
  }
}