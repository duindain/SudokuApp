import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/DatabaseService.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/pages/Setting/SettingColorCell.dart';
import 'dart:math';

import 'ThemeType.dart';

class Settings extends StatefulWidget
{
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class ListViewModel{
  final String title;
  final String key;
  final CategoryModel category;
  final Color? color;
  final ThemeType? themeType;

  ListViewModel(
    this.title,
    this.key,
    this.category,
  {
    this.color,
    this.themeType
  });
}

class CategoryModel{
  final String name;
  final IconData icon;

  CategoryModel(
    this.name,
    this.icon
  );
}

class _SettingsFormState extends State<Settings> {

  var utilities = GetIt.instance.get<Utilities>();
  var audio = GetIt.instance.get<Audio>();
  var db = GetIt.instance.get<DatabaseService>();

  var _audioCategory = CategoryModel("Audio", FontAwesomeIcons.music);
  var _onlineCategory = CategoryModel("Online", FontAwesomeIcons.signal);
  var _generalCategory = CategoryModel("General", FontAwesomeIcons.cogs);
  var _themeCategory = CategoryModel("Theme", FontAwesomeIcons.paintBrush);

  late List listViewData;
  late List themeColors;

  @override
  void initState() {
    super.initState();

    listViewData = [
      ListViewModel("AudioMusic", "Enable Ambient sound", _audioCategory),
      ListViewModel("AudioEffects", "Enable Sound effects", _audioCategory),
      ListViewModel("ShowElapsedTimer", "Show Elapsed time", _generalCategory),
      ListViewModel("ShowHints", "Show Hint Option", _generalCategory),
      ListViewModel("ShowIncorrect", "Show Incorrect Entries", _generalCategory),
      ListViewModel("ShowSelectedRowAndColumn", "Show selected Row and Column", _generalCategory),
      ListViewModel("NumericDialog", "Use Numeric dialog", _generalCategory),
      ListViewModel("UseGoogleServices", "Enable Google Play", _onlineCategory),
      ListViewModel("AutoLogin", "Auto login to Google Play", _onlineCategory),
      ListViewModel("UploadGames", "Upload results to Google+", _onlineCategory),
      //ListViewModel("OffsiteBackup", "", "Online"),
    ];

    assignColors();
  }

  List<Widget> _buildOptions(BuildContext context)
  {
    listViewData.sort((a, b) => a.category.name.compareTo(b.category.name));
    var lastCategoryName = "";

    var widgets = <Widget>[];

    for(var item in listViewData)
    {
      if(lastCategoryName != item.category.name)
      {
        lastCategoryName = item.category.name;
        widgets.addAll(getCategory(context, item.category));
      }
      widgets.add(getBooleanSetting(context, item.key, item.title));
    }

    widgets.addAll(getCategory(context, _themeCategory));

    for(var i = 0; i < themeColors.length; i += 4)
    {
      var subList = themeColors.sublist(i, min(i + 4, themeColors.length));
      widgets.add(getColorSettings(context, subList));
    }
    return widgets;
  }

  Widget getColorSettings(BuildContext context, List colors)
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for(var item in colors)
          Expanded(
            child: Padding(
            padding: EdgeInsets.all(6.0),
              child: getColorSetting(context, item.key, item.title, item.themeType)))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
           title:new Text("Settings")
        ),
        body:
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child:
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildOptions(context)
            )
          )
        )
    );
  }

  List<Widget> getCategory(BuildContext context, CategoryModel category)
  {
    return [
      new Row(crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FaIcon(category.icon),
          Padding(padding: new EdgeInsets.only(left:16.0),
              child:Text(category.name))
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[Expanded(child: Divider())],
    )];
  }

  Widget getBooleanSetting(BuildContext context, String key, String text)
  {
    return new Row(crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(child:Text(text)),
        Align(
          alignment: Alignment.centerRight,
          child:Switch(
            value: utilities.getPreferenceAsBool(key, emptyValue: true),
            onChanged: (value)
            {
              audio.buttonPress();
              utilities.sharedPreferences.setBool(key, value);
              setState(() {});
            }
          )
        )
      ],
    );
  }

  Widget getColorSetting(BuildContext context, String key, String text, ThemeType themeType)
  {
    var themedKey = "${utilities.getPreferenceAsBool("DarkTheme") ? "Dark" : ""}$key";
    return SettingColorCell(themedKey, text, utilities.getPreferenceAsColor(themedKey), themeType, colorChanged);
  }

  colorChanged(String key, Color color)
  {
    setState(() {
      utilities.sharedPreferences.setString(key, color.toString());
      assignColors();
    });
  }

  assignColors()
  {
    themeColors = [
      ListViewModel("ThemeNote", "Notes", _themeCategory, themeType: ThemeType.NOTE),
      ListViewModel("ThemeHint", "Hints", _themeCategory, themeType: ThemeType.HINTED_CLUE),
      ListViewModel("ThemeValue", "Values", _themeCategory, themeType: ThemeType.USER_ENTERED),
      ListViewModel("ThemeClue", "Clues", _themeCategory, themeType: ThemeType.INITIAL_CLUE),
      ListViewModel("ThemeHighlight", "Highlight", _themeCategory, themeType: ThemeType.HIGHLIGHT),
      ListViewModel("ThemeIncorrect", "Incorrect", _themeCategory, themeType: ThemeType.INCORRECT),
      ListViewModel("ThemeBackground", "Background", _themeCategory, themeType: ThemeType.BACKGROUND),
      ListViewModel("ThemeSelected", "Selected", _themeCategory, themeType: ThemeType.SELECTED),
      ListViewModel("ThemeNumericBackground", "Numeric cell", _themeCategory, themeType: ThemeType.NUMERIC_SELECTION_BACKGROUND),
      ListViewModel("ThemeNumericText", "Numeric text", _themeCategory, themeType: ThemeType.NUMERIC_SELECTION_TEXT),
      ListViewModel("ThemeButtonBackground", "Button cell", _themeCategory, themeType: ThemeType.BUTTON_BACKGROUND),
      ListViewModel("ThemeButtonText", "Button text", _themeCategory, themeType: ThemeType.BUTTON_TEXT),
      ListViewModel("ThemeBackgroundUnEditableCell", "Uneditable cell background", _themeCategory, themeType: ThemeType.UNEDITABLE_CELL_BACKGROUND),
    ];
  }
}