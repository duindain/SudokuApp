import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/helpers/StringExtensions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sudokuapp/models/PuzzleDifficulty.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:ninja_prime/ninja_prime.dart';

typedef FancyButtonCallback = void Function();

class Utilities
{
  final log = Logger('Utilities');
  var uuid = new Uuid(options: {
    'grng': UuidUtil.cryptoRNG
  });
  late SharedPreferences sharedPreferences;
  DateFormat formatter = new DateFormat('yyyy-MM-dd H:m:s');
  String baseUrl = "https://rmu.no-ip.com/sudoku/";
  String featuresUrl = "https://refuelio-d8091.web.app/features.json";
  Random random = new Random.secure();
  DateTime minDateTime = DateTime.utc(-271821,04,20);

  Future initilise() async {
    sharedPreferences = await SharedPreferences.getInstance();
    initiliseSharedPreferences(sharedPreferences);
    //sharedPreferences.setString('UpdateFeatures', null);
    var featuresUpdated = getPreferenceAsString("UpdateFeatures");
    if(featuresUpdated.isEmpty || formatter.parse(featuresUpdated).isBefore(DateTime.now()))
    {
      print("Utilities.initilise: Feature check duration elapsed, retrieving features");
      await fetchFeatures();
    }
    var appLaunches = getPreferenceAsInt("AppLaunches") + 1;
    print("Utilities.initilise: AppLaunches set to $appLaunches");
    sharedPreferences.setInt("AppLaunches", appLaunches);
  }

  double getDifference(double a, double b)
  {
    var difference = a - b;
    if(difference < 0)
      difference = difference * -1;
    return difference;
  }

  Color getPreferenceAsColor(String key, {Color emptyValue = Colors.transparent})
  {
    return sharedPreferences.containsKey(key) ? fromString(sharedPreferences.getString(key) ?? emptyValue.toString()) : emptyValue;
  }

  String getPreferenceAsString(String key, {String emptyValue = ""})
  {
    return (sharedPreferences.containsKey(key) ? sharedPreferences.getString(key) : emptyValue) ?? emptyValue;
  }

  int getPreferenceAsInt(String key, {int emptyValue = 0})
  {
    return (sharedPreferences.containsKey(key) ? sharedPreferences.getInt(key) : emptyValue) ?? emptyValue;
  }

  bool getPreferenceAsBool(String key, {bool emptyValue = false})
  {
    return (sharedPreferences.containsKey(key) ? sharedPreferences.getBool(key) : emptyValue) ?? emptyValue;
  }

  Color fromString(String colorString)
  {
    var valueString = colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    var value = int.parse(valueString, radix: 16);
    return new Color(value);
  }

  Future voteOnPuzzleDifficulty(String puzzleId, PuzzleDifficulty puzzleDifficulty) async
  {
    try
    {
      await http.post(Uri.parse(baseUrl), body: jsonEncode({puzzleId: puzzleId, puzzleDifficulty: puzzleDifficulty}));
    } on Exception catch (exception, stackTrace) {
      FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    } catch (error) {
      FirebaseCrashlytics.instance.log(error.toString());
    }
  }

  Future sendScore(Score score) async
  {
    try
    {
      await http.post(Uri.parse(baseUrl), body: jsonEncode({score: score.toJson()}));
    } on Exception catch (exception, stackTrace) {
      FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    } catch (error) {
      FirebaseCrashlytics.instance.log(error.toString());
    }
  }
  
  Future fetchFeatures() async {
    var succeeded = false;
    try
    {
      var response = await http.get(Uri.parse(featuresUrl));
      if(response.statusCode == 200)
      {
        var features = json.decode(response.body);
        print("Utilities.fetchFeatures: Downloaded features : $features");
        sharedPreferences.setBool("AudioMusic", features["audioMusic"].toLowerCase() == 'true');
        sharedPreferences.setBool("AudioEffects", features["audioEffects"].toLowerCase() == 'true');
        sharedPreferences.setBool("ShowElapsedTimer", features["showElapsedTimer"].toLowerCase() == 'true');
        sharedPreferences.setBool("ShowHints", features["showHints"].toLowerCase() == 'true');
        sharedPreferences.setBool("ShowIncorrect", features["showIncorrect"].toLowerCase() == 'true');
        sharedPreferences.setBool("ShowSelectedRowAndColumn", features["showSelectedRowAndColumn"].toLowerCase() == 'true');
        sharedPreferences.setBool("NumericDialog", features["numericDialog"].toLowerCase() == 'true');
        sharedPreferences.setBool("UseGoogleServices", features["useGoogleServices"].toLowerCase() == 'true');
        sharedPreferences.setBool("AutoLogin", features["autoLogin"].toLowerCase() == 'true');
        sharedPreferences.setBool("UploadGames", features["uploadGames"].toLowerCase() == 'true');
        sharedPreferences.setInt("SaveFrequency", features["saveFrequency"].toInt());
        sharedPreferences.setBool("OffsiteBackup", features["offsiteBackup"].toLowerCase() == 'true');

        sharedPreferences.setString("DarkThemeNote", features["darkThemeNote"]);
        sharedPreferences.setString("DarkThemeHint", features["darkThemeHint"]);
        sharedPreferences.setString("DarkThemeValue", features["darkThemeValue"]);
        sharedPreferences.setString("DarkThemeClue", features["darkThemeClue"]);
        sharedPreferences.setString("DarkThemeHighlight", features["darkThemeHighlight"]);
        sharedPreferences.setString("DarkThemeIncorrect", features["darkThemeIncorrect"]);
        sharedPreferences.setString("DarkThemeBackground", features["darkThemeBackground"]);
        sharedPreferences.setString("DarkThemeSelected", features["darkThemeSelected"]);
        sharedPreferences.setString("DarkThemeNumericBackground", features["darkThemeNumericBackground"]);
        sharedPreferences.setString("DarkThemeNumericText", features["darkThemeNumericText"]);
        sharedPreferences.setString("DarkThemeButtonBackground", features["darkThemeButtonBackground"]);
        sharedPreferences.setString("DarkThemeButtonText", features["darkThemeButtonText"]);
        sharedPreferences.setString("DarkThemeBackgroundUnEditableCell", features["darkThemeBackgroundUnEditableCell"]);

        sharedPreferences.setString("ThemeNote", features["themeNote"]);
        sharedPreferences.setString("ThemeHint", features["themeHint"]);
        sharedPreferences.setString("ThemeValue", features["themeValue"]);
        sharedPreferences.setString("ThemeClue", features["themeClue"]);
        sharedPreferences.setString("ThemeHighlight", features["themeHighlight"]);
        sharedPreferences.setString("ThemeIncorrect", features["themeIncorrect"]);
        sharedPreferences.setString("ThemeBackground", features["themeBackground"]);
        sharedPreferences.setString("ThemeSelected", features["themeSelected"]);
        sharedPreferences.setString("ThemeNumericBackground", features["themeNumericBackground"]);
        sharedPreferences.setString("ThemeNumericText", features["themeNumericText"]);
        sharedPreferences.setString("ThemeButtonBackground", features["themeButtonBackground"]);
        sharedPreferences.setString("ThemeButtonText", features["themeButtonText"]);
        sharedPreferences.setString("ThemeBackgroundUnEditableCell", features["themeBackgroundUnEditableCell"]);

        //Dont update again until tomorrow
        sharedPreferences.setString('UpdateFeatures', formatter.format(DateTime.now().add(new Duration(days : 1))));
        succeeded = true;
      }
    } on Exception catch (exception, stackTrace) {
      FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    } catch (error) {
      FirebaseCrashlytics.instance.log(error.toString());
    }
    finally
    {
      if(succeeded == false)
      {
        initiliseSharedPreferences(sharedPreferences, reInitilise:true);
        //Dont update again until tomorrow
        sharedPreferences.setString('UpdateFeatures', formatter.format(DateTime.now().add(new Duration(days : 1))));
      }
    }
  }

  void initiliseSharedPreferences(SharedPreferences sharedPreferences, { bool reInitilise = false})
  {
    if (sharedPreferences.containsKey("AudioMusic") == false)
    {
      print("Utilities.initiliseSharedPreferences: Setting default shared preferences");
      sharedPreferences.setBool("OffsiteBackup", false);
      sharedPreferences.setString("ClientId", uuid.v4());
      sharedPreferences.setString('UpdateFeatures', formatter.format(DateTime.now().add(new Duration(seconds:-1))));
      sharedPreferences.setBool("DarkTheme", true);

      sharedPreferences.setInt("AppLaunches", 0);

      reInitilise = true;
    }

    if(reInitilise)
    {
      sharedPreferences.setBool("AudioMusic", true);
      sharedPreferences.setBool("AudioEffects", true);
      sharedPreferences.setBool("ShowElapsedTimer", true);
      sharedPreferences.setBool("ShowHints", true);
      sharedPreferences.setBool("ShowIncorrect", false);
      sharedPreferences.setBool("ShowSelectedRowAndColumn", true);
      sharedPreferences.setBool("NumericDialog", false);
      sharedPreferences.setBool("UseGoogleServices", true);
      sharedPreferences.setBool("AutoLogin", false);
      sharedPreferences.setBool("UploadGames", false);
      sharedPreferences.setInt("SaveFrequency", 30);
      sharedPreferences.setBool("OffsiteBackup", false);

      sharedPreferences.setString("DarkThemeNote", Colors.black.toString());
      sharedPreferences.setString("DarkThemeHint", Colors.brown.toString());
      sharedPreferences.setString("DarkThemeValue", Colors.green.toString());
      sharedPreferences.setString("DarkThemeClue", Colors.yellow.toString());
      sharedPreferences.setString("DarkThemeSelected", Colors.lightBlue.toString());
      sharedPreferences.setString("DarkThemeHighlight", Colors.lightBlue.toString());
      sharedPreferences.setString("DarkThemeIncorrect", Colors.red.toString());
      sharedPreferences.setString("DarkThemeBackground", Colors.white70.toString());
      sharedPreferences.setString("DarkThemeSelected", Colors.green.toString());
      sharedPreferences.setString("DarkThemeNumericBackground", Colors.amber.toString());
      sharedPreferences.setString("DarkThemeNumericText", Colors.black.toString());
      sharedPreferences.setString("DarkThemeButtonBackground", Colors.blueGrey.toString());
      sharedPreferences.setString("DarkThemeButtonText", Colors.white.toString());
      sharedPreferences.setString("DarkThemeBackgroundUnEditableCell", Colors.white54.toString());

      sharedPreferences.setString("ThemeNote", Colors.black.toString());
      sharedPreferences.setString("ThemeHint", Colors.brown.toString());
      sharedPreferences.setString("ThemeValue", Colors.green.toString());
      sharedPreferences.setString("ThemeClue", Colors.yellow.toString());
      sharedPreferences.setString("ThemeSelected", Colors.lightBlue.toString());
      sharedPreferences.setString("ThemeHighlight", Colors.lightBlue.toString());
      sharedPreferences.setString("ThemeIncorrect", Colors.red.toString());
      sharedPreferences.setString("ThemeBackground", Colors.grey.toString());
      sharedPreferences.setString("ThemeSelected", Colors.green.toString());
      sharedPreferences.setString("ThemeNumericBackground", Colors.amber.toString());
      sharedPreferences.setString("ThemeNumericText", Colors.black.toString());
      sharedPreferences.setString("ThemeButtonBackground", Colors.blueGrey.toString());
      sharedPreferences.setString("ThemeButtonText", Colors.white60.toString());
      sharedPreferences.setString("ThemeBackgroundUnEditableCell", Colors.white30.toString());
    }
  }

  String truncate(int cutoff, String myString, {String concatText = ''}) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}${concatText != null ? concatText : ''}';
  }

  bool isJson(String text)
  {
    return text.startsWith("{");
  }

  bool isPrime(double number)
  {
    return BigInt.from(number).isPrime();
  }

  double getCompletedPercentage(String inProgress, String hints, String clues)
  {
    return round((((inProgress.getDigitCount() + hints.getDigitCount()) / (81.0 - clues.getDigitCount())).toDouble() * 100.0), 2);
  }

  double round(double val, int places)
  {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  double sumList(List values, Function calcMethod)
  {
    double value = 0;
    if(values.length > 0)
    {
      values.forEach((element) {
        value += calcMethod(element);
      });
    }
    return value;
  }

  String formatDuration(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds~/Duration.secondsPerDay;
    seconds -= days*Duration.secondsPerDay;
    final hours = seconds~/Duration.secondsPerHour;
    seconds -= hours*Duration.secondsPerHour;
    final minutes = seconds~/Duration.secondsPerMinute;
    seconds -= minutes*Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0)
    {
      tokens.add('$days days');
    }
    if (tokens.isNotEmpty || hours != 0)
    {
      tokens.add('$hours hours');
    }
    if (tokens.isNotEmpty || minutes != 0)
    {
      tokens.add('$minutes mins');
    }
    tokens.add('$seconds secs');

    return tokens.join(', ');
  }

  BoxDecoration myBoxDecoration(Color color, bool showThickBorder) {
    return BoxDecoration(
      color: color,
      border: showThickBorder ? Border.all(color: getPreferenceAsColor("ThemeSelected", emptyValue: Colors.green), width: 5.0, style: BorderStyle.solid) : Border.all(),
      borderRadius: new BorderRadius.all(new Radius.circular(10.0))
    );
  }

  Color getThemedColor(String key)
  {
    var themedKey = "${getPreferenceAsBool("DarkTheme") ? "Dark" : ""}$key";
    return getPreferenceAsColor(themedKey);
  }

  void showToast(BuildContext buildContext, String message)
  {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(message),
        ],
      ),
    );
    FToast flutterToast = FToast();
    flutterToast.init(buildContext);
    flutterToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  List<Widget> createHeadingWithIcon(BuildContext context, String heading, IconData iconData)
  {
    return [
      new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FaIcon(iconData),
            Padding(padding: new EdgeInsets.only(left:16.0),
                child:Text(heading))
          ]),
      Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[Expanded(child: Divider())]
      )
    ];
  }
}