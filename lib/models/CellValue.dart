import 'package:equatable/equatable.dart';
import 'Cell.dart';
import 'CellType.dart';
import 'CellValueUpdateReason.dart';

class CellValue extends Equatable
{
  Cell cell;
  CellType cellType;
  String value;
  bool isSelected = false;
  bool isHighlighted = false;
  bool isCellCorrect = true;
  CellValueUpdateReason cellValueUpdateReason =  CellValueUpdateReason.NA;

  CellValue(
      this.cell,
      this.cellType,
      this.value,
      this.isCellCorrect
      );

  CellValue copy()
  {
    var cellValue = new CellValue(this.cell, this.cellType, this.value, this.isCellCorrect);
    cellValue.isSelected = this.isSelected;
    cellValue.isHighlighted = this.isHighlighted;
    cellValue.cellValueUpdateReason = this.cellValueUpdateReason;
    return cellValue;
  }

  @override
  // TODO: implement props
  List<Object> get props => [cell, cellType, value, isSelected, isHighlighted, isCellCorrect];
}