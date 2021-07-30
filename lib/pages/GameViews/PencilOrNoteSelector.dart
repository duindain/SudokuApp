import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class PencilOrNoteSelector extends StatefulWidget
{
  Function _pencilOrNoteCallback;
  bool _isNote;

  PencilOrNoteSelector(this._isNote, this._pencilOrNoteCallback);

  @override
  _PencilOrNoteSelectorState createState() => _PencilOrNoteSelectorState();
}

class _PencilOrNoteSelectorState extends State<PencilOrNoteSelector>
{
  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return LiteRollingSwitch(
      value: widget._isNote,
      textOn: 'A Note',
      textOff: 'A Value',
      colorOn: Colors.deepOrange,
      colorOff: Colors.blueAccent,
      iconOn: FontAwesomeIcons.commentDots,
      iconOff: FontAwesomeIcons.pencilAlt,
      onChanged: (bool state)
      {
        if(widget._isNote != state)
        {
          setState(()
          {
            widget._isNote = state;
            widget._pencilOrNoteCallback(widget._isNote);
          });
        }
      },
    );
  }
}