import "package:collection/collection.dart";
import 'Cell.dart';

class Cells
{
  late List<Cell> cells;

  void initilise()
  {
    cells = <Cell>[];
    for (var cellCol = 0; cellCol < 9; cellCol++)
    {
      for (var cellRow = 0; cellRow < 9; cellRow++)
      {
        cells.add(new Cell(cells.length, cellRow, cellCol));
      }
    }
  }

  Cell getCell(row, col)
  {
    return cells.firstWhere((a) => a.col == col && a.row == row);
  }
}
