import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/ActivePuzzle.dart';
import 'package:sudokuapp/models/Boundary.dart';
import 'package:sudokuapp/models/CellValueUpdateReason.dart';
import 'dart:async';
import 'SingleCell.dart';

class SudokuGrid extends StatefulWidget
{
  ActivePuzzle _activePuzzle;
  BehaviorSubject _cellValueBS;

  SudokuGrid(this._activePuzzle, this._cellValueBS);

  @override
  _SudokuGridState createState() => _SudokuGridState();
}

class _SudokuGridState extends State<SudokuGrid>
{
  var utilities = GetIt.instance.get<Utilities>();
  var audio = GetIt.instance.get<Audio>();

  List<SingleCell> _singleCells = <SingleCell>[];

  _SudokuGridState() {}

  @override
  void initState()
  {
    widget._cellValueBS.listen((cellValue)
    {
      if(cellValue.cellValueUpdateReason == CellValueUpdateReason.Selection)
      {
        //Highlight or unhighlight the row and column around our selected cell
        for(var r = 0; r < 9; r++)
        {
          for (var c = 0; c < 9; c++)
          {
            var cell = widget._activePuzzle.cells.getCell(r, c);
            if(cell != cellValue.cell)
            {
              var singleCell = _singleCells.singleWhere((element) => element.getCellValue().cell == cell);
              var singleCellValue = singleCell.getCellValue().copy();

              var isRowOrColumn = utilities.getPreferenceAsBool("ShowSelectedRowAndColumn") &&
                  cellValue.isSelected && (cell.col == cellValue.cell.col || cell.row == cellValue.cell.row);

              singleCellValue.isHighlighted = isRowOrColumn;
              singleCellValue.isSelected = false;
              singleCellValue.cellValueUpdateReason = CellValueUpdateReason.Highlight;

              widget._cellValueBS.add(singleCellValue);
            }
          }
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    var mainAlignment = Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:[]);
    Boundary? lastBoundary;
    var cellColor = Colors.white70;
    _singleCells.clear();

    for(var r = 0; r < 9; r++)
    {
      var row = Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:[]);
      for(var c = 0; c < 9; c++)
      {
        var currentBoundary = widget._activePuzzle.getBoundary(widget._activePuzzle.cells.getCell(r, c));
        if(lastBoundary != currentBoundary)
        {
          lastBoundary = currentBoundary;
          cellColor = cellColor == Colors.white70 ? Colors.grey : Colors.white70;
        }
        var cellValue = widget._activePuzzle.getCellValue(r, c);

        var singleCell = new SingleCell(cellValue, widget._cellValueBS);
        _singleCells.add(singleCell);
        row.children.add(singleCell);

        //Add a space between cell groupings
        if(c == 2 || c == 5)
        {
          row.children.add(Container
          (
            child:Text(""),
            height: 45,
            width: 1,
            decoration: utilities.myBoxDecoration(Colors.black, false)
          ));
        }
      }
      mainAlignment.children.add(row);
      //Add a space under cell groupings
      if(r == 2 || r == 5)
      {
        mainAlignment.children.add(Container
        (
          child:Text(""),
          height: 5,
          width: MediaQuery.of(context).size.width,
          decoration: utilities.myBoxDecoration(Colors.black, false)
        ));
      }
    }
    return mainAlignment;
  }

  @override
  void dispose()
  {
    widget._cellValueBS.close();
    super.dispose();
  }
}