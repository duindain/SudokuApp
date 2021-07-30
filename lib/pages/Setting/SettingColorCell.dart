import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'ThemeType.dart';

class SettingColorCell extends StatefulWidget {
  String _settingKey;
  String _text;
  Color _color;
  ThemeType _themeType;
  Function _colorChangeCallback;

  SettingColorCell(this._settingKey, this._text, this._color, this._themeType, this._colorChangeCallback);

  @override
  _SettingColorCellState createState() => _SettingColorCellState();
}

class _SettingColorCellState extends State<SettingColorCell>
{
  var utilities = GetIt.instance.get<Utilities>();

  _SettingColorCellState();

  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return InkWell(
      onTap: ()
      {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext contextb) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(0.0),
              contentPadding: const EdgeInsets.all(0.0),
              actions: <Widget>[
                RaisedButton(
                  child: Text('Save'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget._colorChangeCallback(widget._settingKey, widget._color);
                  },
                ),
                RaisedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    setState(()
                    {
                      widget._color = utilities.getPreferenceAsColor(widget._settingKey);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: widget._color,
                  onColorChanged: (color)
                  {
                    setState(()
                    {
                      widget._color = color;
                    });
                  },
                  colorPickerWidth: 300.0,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: true,
                  displayThumbColor: true,
                  showLabel: true,
                  paletteType: PaletteType.hsv,
                  pickerAreaBorderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(2.0),
                    topRight: const Radius.circular(2.0),
                  ),
                ),
              ),
            );
          },
        );
      }, // handle your onTap here
      child:Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(widget._text),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: getColorCell(widget._themeType, widget._color)
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xff7c94b6),
          borderRadius: new BorderRadius.all(new Radius.circular(10.0))
      ),
    ));
  }

  Widget getColorCell(ThemeType themeType, Color color)
  {
    Widget cellWidget;

    var cellColor = Colors.white70;
    var isSelected = false;

    switch(themeType)
    {
      case ThemeType.HINTED_CLUE:
      case ThemeType.INITIAL_CLUE:
      case ThemeType.USER_ENTERED:
      case ThemeType.INCORRECT:
        cellWidget = Text("${utilities.random.nextInt(8) + 1}", textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 30));
        break;
      case ThemeType.NUMERIC_SELECTION_TEXT:
        cellColor = utilities.getThemedColor("ThemeNumericBackground");
        cellWidget = Text("${utilities.random.nextInt(8) + 1}", textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 30));
        break;
      case ThemeType.BUTTON_TEXT:
        cellColor = utilities.getThemedColor("ThemeButtonBackground");
        cellWidget = FaIcon(FontAwesomeIcons.questionCircle, color: color);
        break;
      case ThemeType.NOTE:
        cellWidget = Text(
            "${utilities.random.nextInt(8) + 1}       \r\n   ${utilities.random.nextInt(8) + 1}   \r\n       ${utilities.random.nextInt(8) + 1}",
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 12)
          );
        break;
      case ThemeType.HIGHLIGHT:
        cellColor = color;
        cellWidget = Text("${utilities.random.nextInt(8) + 1}", textAlign: TextAlign.center, style: TextStyle(color: utilities.getThemedColor("ThemeClue"), fontSize: 30));
        break;
      case ThemeType.UNEDITABLE_CELL_BACKGROUND:
        cellColor = color;
        cellWidget = Text("${utilities.random.nextInt(8) + 1}", textAlign: TextAlign.center, style: TextStyle(color: utilities.getThemedColor("ThemeClue"), fontSize: 30));
        break;
      case ThemeType.BACKGROUND:
      case ThemeType.NUMERIC_SELECTION_BACKGROUND:
      case ThemeType.BUTTON_BACKGROUND:
        cellColor = color;
        cellWidget = Text(" ");
        break;
      case ThemeType.SELECTED:
        isSelected = true;
        cellWidget = Text("${utilities.random.nextInt(8) + 1}", textAlign: TextAlign.center, style: TextStyle(color: utilities.getThemedColor("ThemeClue"), fontSize: 30));
        break;
    }

    return Container(
      child: cellWidget,
      alignment: Alignment.center,
      decoration: utilities.myBoxDecoration(cellColor, isSelected),
      height:45,
      width:40
    );
  }
}