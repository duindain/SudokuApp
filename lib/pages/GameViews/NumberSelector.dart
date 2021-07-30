import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/pages/GameViews/PencilOrNoteSelector.dart';

class NumberSelector extends StatefulWidget
{
  Function _numberEnteredCallback;
  Function _provideHintCallback;

  NumberSelector(this._numberEnteredCallback, this._provideHintCallback);

  @override
  _NumberSelectorState createState() => _NumberSelectorState();
}

class _NumberSelectorState extends State<NumberSelector>
{
  final log = Logger('NumberSelector');
  var utilities = GetIt.instance.get<Utilities>();
  var audio = GetIt.instance.get<Audio>();
  bool _isNote = false;

  @override
  Widget build(BuildContext context)
  {
    var row = Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:[]);
    for(var c = 0; c < 9; c++)
    {
      row.children.add(Container
      (
        height: 45,
        width: 40,
        decoration: utilities.myBoxDecoration(utilities.getThemedColor("ThemeNumericBackground"), false),
        child: InkWell(
            onTap: () => selectedNumber(c + 1),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Text("${c + 1}", textAlign: TextAlign.center, style: TextStyle(color: utilities.getThemedColor("ThemeNumericText"), fontSize: 32))
            )),
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:[
        row,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            //Clear cell
            Container
            (
              height: 45,
              width: 40,
              decoration: utilities.myBoxDecoration(utilities.getThemedColor("ThemeButtonBackground"), false),
              child: InkWell(
                  onTap: () => selectedNumber(-1),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container
                        (
                          alignment: Alignment.center,
                          child: FaIcon(FontAwesomeIcons.eraser, color: utilities.getThemedColor("ThemeButtonText")),
                      ))),
            ),
            if(utilities.getPreferenceAsBool("ShowHints"))
              Container
              (
                height: 45,
                width: 40,
                decoration: utilities.myBoxDecoration(utilities.getThemedColor("ThemeButtonBackground"), false),
                child: InkWell(
                  onTap: () => getHint(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container
                    (
                      alignment: Alignment.center,
                      child: FaIcon(FontAwesomeIcons.questionCircle, color: utilities.getThemedColor("ThemeButtonText")),
                    ))),
              ),
            PencilOrNoteSelector(_isNote, updatePencilOrNote)
            //toggle notes or value
            //Change keyboard mode
        ])
      ]);
  }

  void selectedNumber(int selectedNumber)
  {
    audio.buttonPress();
    widget._numberEnteredCallback(selectedNumber == -1 ? "." : "$selectedNumber", _isNote);
    log.fine("selectedNumber callback for $selectedNumber");
  }

  void getHint()
  {
    audio.buttonPress();
    widget._provideHintCallback();
    log.fine("getHint callback");
  }

  void updatePencilOrNote(bool isNote)
  {
    audio.buttonPress();
    _isNote = isNote;
    log.fine("updatePencilOrNote callback isNote= $isNote");
  }

  @override
  void dispose()
  {
    super.dispose();
  }
}