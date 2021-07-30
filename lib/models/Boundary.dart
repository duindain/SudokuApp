import 'package:equatable/equatable.dart';

import 'Cell.dart';

class Boundary extends Equatable
{
  int startRow;
  int endRow;
  int startCol;
  int endCol;

  Boundary(
    this.startRow,
    this.endRow,
    this.startCol,
    this.endCol
  );

  bool isCellInBoundary(Cell cell)
  {
    return cell.row >= startRow && cell.row <= endRow && cell.col >= startCol && cell.col <= endCol;
  }

  @override
  List<Object> get props => [startRow, endRow, startCol, endCol];
}