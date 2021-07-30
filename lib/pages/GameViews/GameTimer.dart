import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'dart:async';

class GameTimer extends StatefulWidget
{
  int _elapsedSeconds;
  ValueChanged<int> _listener;

  GameTimer(this._elapsedSeconds, this._listener);

  @override
  _GameTimerState createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer>
{
  var utilities = GetIt.instance.get<Utilities>();
  Timer? _timer;

  @override
  void initState()
  {
    _timer = Timer.periodic(Duration(seconds: 1), (timer)
    {
      if(widget._elapsedSeconds != null)
      {
        setState(()
        {
          widget._elapsedSeconds++;
          widget._listener(widget._elapsedSeconds);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    if(widget._elapsedSeconds != null && utilities.getPreferenceAsBool("ShowElapsedTimer"))
    {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding
            (
              padding: new EdgeInsets.all(8.0),
              child:Text("${utilities.formatDuration(Duration(seconds: widget._elapsedSeconds))}")
          )
        ],
      );
    }
    else
    {
      return Container();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}