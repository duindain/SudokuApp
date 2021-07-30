import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sudokuapp/db/Puzzles.dart';
import 'package:sudokuapp/db/SaveGame.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/DatabaseService.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/PuzzleDifficulty.dart';
import 'GameViews/Game.dart';

class PlayOrContinue extends StatefulWidget
{
  @override
  _PlayOrContinueState createState() => _PlayOrContinueState();
}

class _PlayOrContinueState extends State<PlayOrContinue> {

  var utilities = GetIt.instance.get<Utilities>();
  var audio = GetIt.instance.get<Audio>();
  var db = GetIt.instance.get<DatabaseService>();

  late List<SaveGame> saves;
  var _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  var saveColumns = <DataColumn>[
    DataColumn(label:Text("Difficulty"), tooltip:'', numeric:false),
    DataColumn(label:Text("Completed %"), tooltip:'', numeric:true),
    DataColumn(label:Text("Last Played"), tooltip:'', numeric:false),
    DataColumn(label:Text("Duration"), tooltip:'', numeric:true),
  ];

  @override
  void initState()
  {
    _asyncMethod();
    super.initState();
  }

  _asyncMethod() async {
    db.streamSaves$.listen((x) async {
      print("Settings: Saves stream update detected");
      saves = await db.getSaveGames();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("PlayOrContinue")
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:new Padding(
          padding:new EdgeInsets.all(16.0),
          child:
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: createOptions(context)
          )
        )
      )
    );
  }

  List<Widget> createOptions(BuildContext context) {
    var widgets = <Widget>[];

    widgets.addAll(utilities.createHeadingWithIcon(context, "Start a new game", FontAwesomeIcons.forward));
    widgets.addAll(createDifficultyRows(context));

    if(saves != null && saves.length > 0)
    {
      widgets.addAll(utilities.createHeadingWithIcon(context, "Saves", FontAwesomeIcons.save));
      var paginatedDataTable = PaginatedDataTable(
        rowsPerPage: _rowsPerPage,
        header: Text("You have ${saves.length} saves"),
        availableRowsPerPage: [5,10,25],
        onRowsPerPageChanged: (int? value) {
          setState(() {
            _rowsPerPage = value ?? 0;
          });
        },
        columns: saveColumns,
        source: DTS(context, saves)
      );
      widgets.add(paginatedDataTable);
    }
    return widgets;
  }

  List<Widget> createDifficultyRows(BuildContext context)
  {
    var rows = <Widget>[];
    var containers = List.generate(PuzzleDifficulty.values.length, (index)
    {
      var difficulty = PuzzleDifficulty.values[index];
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left:10,right:10),
        child: RaisedButton(
          onPressed: ()
          {
            audio.buttonPress();
            Navigator.push(context, MaterialPageRoute(builder: (context) => Game(puzzleDifficulty: difficulty)));
          },
          child: Text(difficulty.toStr),
        )
      );
    });

    for(var index = 0; index < containers.length; index += 2)
    {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: containers.length >= index + 2 ? containers.sublist(index, index + 2) : [containers.last],
      ));
    }
    return rows;
  }
}

class DTS extends DataTableSource {
  var puzzles = GetIt.instance.get<Puzzles>();
  late List<SaveGame> _saves;
  int _selectedCount = 0;
  var utilities = GetIt.instance.get<Utilities>();
  var audio = GetIt.instance.get<Audio>();
  late BuildContext _context;

  DTS(BuildContext context, List<SaveGame> saves)
  {
    _context = context;
    _saves = saves;

    //Should sort by difficulty then completed percent
    _saves.sort((a,b) => a.lastPlayed!.compareTo(b.lastPlayed!));
  }

  @override
  DataRow? getRow(int index) {
    if(index >= _saves.length)
      return null;
    var save = _saves[index];
    var puzzle = puzzles.getPuzzleById(save.puzzleId);
    if(puzzle != null)
    {
      return DataRow.byIndex(
        index: index,
        onSelectChanged: (isSelected)
        {
          if(isSelected != null && isSelected && save != null)
          {
            audio.buttonPress();
            Navigator.push(_context, MaterialPageRoute(builder: (context) => Game(saveGame: save)));
          }
        },
        cells: [
          DataCell(Text('${puzzle.difficulty.toStr}')),
          DataCell(Text('${utilities.getCompletedPercentage(save.inProgress.toString(), save.hints.toString(), puzzle.clues)}')),
          DataCell(Text(save.lastPlayed != null ? DateFormat('d MMMM y').format(save.lastPlayed!) : "")),
          DataCell(Text('${save.elapsedSeconds}')),
        ],
      );
    }
    return null;
  }

  @override
  int get rowCount => _saves.length; // Manipulate this to which ever value you wish

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}