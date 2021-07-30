import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sudokuapp/db/Puzzles.dart';
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/DatabaseService.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/PuzzleDifficulty.dart';
import 'Charts.dart';
import 'DifficultyChart.dart';
import 'SolveRatioChart.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Statistics extends StatefulWidget
{
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {

  var audio = GetIt.instance.get<Audio>();
  var utilities = GetIt.instance.get<Utilities>();
  var db = GetIt.instance.get<DatabaseService>();
  var puzzles = GetIt.instance.get<Puzzles>();
  bool sortOrder = true;
  int sortColumn = 0;
  var _loading = false;

  late List<Score> scores;
  var _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState()
  {
    _asyncMethod();
    super.initState();
  }

  _asyncMethod() async {
    _loading = true;
    scores = await db.getScores();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context)
  {
    if(_loading)
    {
      return SpinKitWave(color: Colors.orange, type: SpinKitWaveType.center);
    }

    var widgets = <Widget>[];
    widgets.add(Charts(scores));
    widgets.addAll(getScores(context));

    /*
    played for hours
    won x games
    lost x games
    */

    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Statistics")
        ),
        body:
        SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:new Padding(
                padding:new EdgeInsets.all(16.0),
                child:
                Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widgets
                )
            )
        )
    );
  }

  List<Widget> getScores(BuildContext context)
  {
    var widgets = <Widget>[];
    if(scores != null && scores.length > 0)
    {
      widgets.addAll(utilities.createHeadingWithIcon(context, "Scores", FontAwesomeIcons.chartBar));
      var paginatedDataTable = PaginatedDataTable(
          rowsPerPage: _rowsPerPage,
          header: Text("You have ${scores.length} scores"),
          availableRowsPerPage: [5,10,25],
          sortColumnIndex: sortColumn,
          sortAscending: sortOrder,
          onRowsPerPageChanged: (int? value) {
            setState(() {
              _rowsPerPage = value ?? 0;
            });
          },
          columns: <DataColumn>[
            DataColumn(label:Text("Difficulty"), tooltip:'', numeric:false, onSort: (columnIndex, ascending) {
              setState(() {
                sortColumn = columnIndex;
                sortOrder = !sortOrder;
              });
              onSortColumn(scores, columnIndex, ascending);
            }),
            DataColumn(label:Text("Score"), tooltip:'', numeric:true, onSort: (columnIndex, ascending) {
              setState(() {
                sortColumn = columnIndex;
                sortOrder = !sortOrder;
              });
              onSortColumn(scores, columnIndex, ascending);
            }),
            DataColumn(label:Text("Solve rate"), tooltip:'', numeric:true, onSort: (columnIndex, ascending) {
              setState(() {
                sortColumn = columnIndex;
                sortOrder = !sortOrder;
              });
              onSortColumn(scores, columnIndex, ascending);
            }),
            DataColumn(label:Text("Hints used"), tooltip:'', numeric:true, onSort: (columnIndex, ascending) {
              setState(() {
                sortColumn = columnIndex;
                sortOrder = !sortOrder;
              });
              onSortColumn(scores, columnIndex, ascending);
            }),
            DataColumn(label:Text("Duration"), tooltip:'', numeric:true, onSort: (columnIndex, ascending) {
              setState(() {
                sortColumn = columnIndex;
                sortOrder = !sortOrder;
              });
              onSortColumn(scores, columnIndex, ascending);
            }),
            DataColumn(label:Text("Completed on"), tooltip:'', numeric:false, onSort: (columnIndex, ascending) {
            setState(() {
              sortColumn = columnIndex;
              sortOrder = !sortOrder;
            });
            onSortColumn(scores, columnIndex, ascending);
          })],
          source: DTS(context, scores)
      );
      widgets.add(paginatedDataTable);
    }
    return widgets;
  }

  onSortColumn(List<Score> scores, int columnIndex, bool ascending) {
    switch(columnIndex)
    {
      case 0:
        scores.sort((a, b)
        {
          var puzzleA = puzzles.getPuzzleById(a.puzzleId);
          var puzzleB = puzzles.getPuzzleById(b.puzzleId);
          return ascending ? puzzleA!.difficulty.toStr.compareTo(puzzleB!.difficulty.toStr) : puzzleB!.difficulty.toStr.compareTo(puzzleA!.difficulty.toStr);
        });
        break;
      case 1:
        scores.sort((a, b) => ascending ? a.combinedScore.compareTo(b.combinedScore) : b.combinedScore.compareTo(a.combinedScore));
        break;
      case 2:
        scores.sort((a, b) => ascending ? a.puzzleSolveRate.compareTo(b.puzzleSolveRate) : b.puzzleSolveRate.compareTo(a.puzzleSolveRate));
        break;
      case 3:
        scores.sort((a, b) => ascending ? a.hintsUsed.compareTo(b.hintsUsed) : b.hintsUsed.compareTo(a.hintsUsed));
        break;
      case 4:
        scores.sort((a, b) => ascending ? a.elapsedSeconds.compareTo(b.elapsedSeconds) : b.elapsedSeconds.compareTo(a.elapsedSeconds));
        break;
      case 5:
        scores.sort((a, b) => ascending ? a.completed.compareTo(b.completed) : b.completed.compareTo(a.completed));
        break;
      default:
        print("Unknown column index in sort "+columnIndex.toString());
        break;
    }
  }
}

class DTS extends DataTableSource {
  var puzzles = GetIt.instance.get<Puzzles>();
  var utilities = GetIt.instance.get<Utilities>();
  var audio = GetIt.instance.get<Audio>();
  List<Score> _scores;
  int _selectedCount = 0;
  BuildContext _context;

  DTS(this._context, this._scores);

  @override
  DataRow? getRow(int index) {
    if(index >= _scores.length)
      return null;
    var score = _scores[index];
    var puzzle = puzzles.getPuzzleById(score.puzzleId);
    if(puzzle != null)
    {
      return DataRow.byIndex(
        index: index,
        onSelectChanged: (isSelected)
        {
          if(isSelected == true && score != null)
          {
            audio.buttonPress();
            //Navigator.push(_context, MaterialPageRoute(builder: (context) => Game(saveGame: save)));
          }
        },
        cells: [
          DataCell(Text('${puzzle.difficulty.toStr}')),
          DataCell(Text('${score.combinedScore}')),//${utilities.getCompletedPercentage(score.inProgress, score.hints, puzzle.clues)}')),
          DataCell(Text('${score.puzzleSolveRate}')),
          DataCell(Text('${score.hintsUsed}')),
          DataCell(Text('${utilities.formatDuration(Duration(seconds: score.elapsedSeconds))}')),
          DataCell(Text(DateFormat('d MMMM y').format(score.completed)))
        ],
      );
    }
    return null;
  }

  @override
  int get rowCount => _scores.length; // Manipulate this to which ever value you wish

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}