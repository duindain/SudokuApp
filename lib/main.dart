import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:sudokuapp/pages/AboutApp.dart';
import 'package:sudokuapp/pages/Achievements.dart';
import 'package:sudokuapp/pages/Challenges.dart';
import 'package:sudokuapp/pages/GameViews/Game.dart';
import 'package:sudokuapp/pages/GameViews/GameScore.dart';
import 'package:sudokuapp/pages/Leaderboards.dart';
import 'package:sudokuapp/pages/MainMenu.dart';
import 'package:sudokuapp/pages/PlayOrContinue.dart';
import 'package:sudokuapp/pages/Setting/Settings.dart';
import 'package:sudokuapp/pages/Statistics/Statistics.dart';
import 'package:sudokuapp/theme_blue.dart';
import 'package:sudokuapp/theme_dark.dart';
import 'db/Puzzles.dart';
import 'helpers/Audio.dart';
import 'helpers/DatabaseService.dart';
import 'helpers/Utilities.dart';
import 'models/AchievementData.dart';
import 'models/AudioType.dart';
import 'models/GoogleAccount.dart';
import 'package:sudokuapp/models/LeaderboardData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final getIt = GetIt.instance;

  getIt.registerSingleton(Utilities());
  getIt.registerSingleton(DatabaseService());
  getIt.registerSingleton(Audio());
  getIt.registerSingleton(Puzzles());
  getIt.registerSingleton(GoogleAccount());
  getIt.registerSingleton(LeaderboardData());
  getIt.registerSingleton(AchievementData());

  bool isInDebugMode = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (isInDebugMode) {
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
  };

  await Firebase.initializeApp();

  var utilities = GetIt.instance.get<Utilities>();
  await utilities.initilise();

  var db = GetIt.instance.get<DatabaseService>();
  await db.initilise();

  var audio = GetIt.instance.get<Audio>();
  await audio.initilise();

  var puzzles = GetIt.instance.get<Puzzles>();
  await puzzles.initilise();

  runZoned<Future<Null>>(() async {
    runApp(new MaterialApp(
      theme: theme_blue,
      darkTheme: theme_dark,
      themeMode: utilities.getPreferenceAsBool("DarkTheme") ? ThemeMode.dark : ThemeMode.light,
      home: new MainMenu(),
      routes: <String, WidgetBuilder> {
        '/mainmenu': (BuildContext context) => new MainMenu(),
        '/playorcontinue' : (BuildContext context) => new PlayOrContinue(),
        '/game' : (BuildContext context) => new Game(),
        //'/gamescore' : (BuildContext context) => new GameScore(),
        '/settings' : (BuildContext context) => new Settings(),
        '/aboutapp' : (BuildContext context) => new AboutApp(),
        '/leaderboards' : (BuildContext context) => new Leaderboards(),
        '/challenges' : (BuildContext context) => new Challenges(),
        '/achievements' : (BuildContext context) => new Achievements(),
        '/statistics' : (BuildContext context) => new Statistics(),
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    ));
  });

  audio.playByName("Startup", AudioType.Effect);
}
