import 'package:equatable/equatable.dart';

class Cell extends Equatable
{
  int index;
  int row;
  int col;

  Cell(
    this.index,
    this.row,
    this.col
  );

  @override
  List<Object> get props => [index, row, col];
}