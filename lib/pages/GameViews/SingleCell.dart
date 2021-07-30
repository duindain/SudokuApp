import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/CellType.dart';
import 'dart:async';
import 'package:sudokuapp/models/CellValue.dart';
import 'package:sudokuapp/models/CellValueUpdateReason.dart';

class SingleCell extends StatefulWidget
{
  CellValue _cellValue;
  BehaviorSubject _cellValueBS;

  SingleCell(this._cellValue, this._cellValueBS);

  @override
  _SingleCellState createState() => _SingleCellState();

  CellValue getCellValue() { return _cellValue;}
}

class _SingleCellState extends State<SingleCell>
{
  final log = Logger('SingleCell');
  var utilities = GetIt.instance.get<Utilities>();
  var audio = GetIt.instance.get<Audio>();

  _SingleCellState() {}

  @override
  void initState()
  {
    widget._cellValueBS.stream.listen((cellValue)
    {
      if(cellValue.cell == widget._cellValue.cell && cellValue != widget._cellValue)
      {
        setState(()
        {
          log.fine("SingleCell._cellValueBS: Changing cell value:${cellValue.value}, cellType:${cellValue.cellType}, isSelected:${cellValue.isSelected}, isHighlighted:${cellValue.isHighlighted}, isCellCorrect:${cellValue.isCellCorrect}, cellValueUpdateReason:${cellValue.cellValueUpdateReason}");
          widget._cellValue = cellValue;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    Widget cellWidget;
    var cellColor = widget._cellValue.isHighlighted ?
      utilities.getThemedColor("ThemeHighlight") : utilities.getThemedColor("ThemeBackground");

    switch(widget._cellValue.cellType)
    {
      case CellType.HINTED_CLUE:
        cellWidget = ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container
          (
            alignment: Alignment.center,
            child: Text("${widget._cellValue.value}", textAlign: TextAlign.center, style: TextStyle(color: utilities.getThemedColor("ThemeHint"), fontSize: 30)),
            color: utilities.getThemedColor("ThemeBackgroundUnEditableCell")
          ));
        break;
      case CellType.INITIAL_CLUE:
        cellWidget = ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container
          (
            alignment: Alignment.center,
            child: Text("${widget._cellValue.value}", textAlign: TextAlign.center, style: TextStyle(color: utilities.getThemedColor("ThemeClue"), fontSize: 30)),
              color: utilities.getThemedColor("ThemeBackgroundUnEditableCell")
          ));
        break;
      case CellType.USER_ENTERED:
        cellWidget = InkWell(
          onTap: () => setSelectedCell(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container
            (
              alignment: Alignment.center,
              child: Text("${widget._cellValue.value}", textAlign: TextAlign.center, style:TextStyle
              (
                  color: utilities.getPreferenceAsBool("ShowIncorrect") && widget._cellValue.isCellCorrect == false ?
                    utilities.getThemedColor("ThemeIncorrect") : utilities.getThemedColor("ThemeValue"), fontSize: 30)
              ),
              color: cellColor,
            )));
        break;
      case CellType.NOTE:
        cellWidget = InkWell(
          onTap: () => setSelectedCell(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container
            (
                alignment: Alignment.center,
                child: Text("${widget._cellValue.value}", textAlign: TextAlign.center, style: TextStyle(color: utilities.getThemedColor("ThemeNote"), fontSize: 10)),
                color: cellColor,
            )));
        break;
      default:
        cellWidget = InkWell(
          onTap: () => setSelectedCell(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container
            (
              alignment: Alignment.center,
              child: Text(" "),
              color: cellColor
            )));
        break;
    }

    return Container
    (
      child: cellWidget,
      alignment: Alignment.center,
      decoration: utilities.myBoxDecoration(cellColor, widget._cellValue.isSelected),
      height:45,
      width:40
    );
  }

  void setSelectedCell()
  {
    audio.buttonPress();
    var newCellValue = widget._cellValue.copy();
    newCellValue.isSelected = !widget._cellValue.isSelected;
    newCellValue.isHighlighted = false;
    newCellValue.cellValueUpdateReason = CellValueUpdateReason.Selection;
    widget._cellValueBS.add(newCellValue);
  }

  @override
  void dispose()
  {
    super.dispose();
  }
}