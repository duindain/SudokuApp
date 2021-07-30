import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/models/AudioType.dart';

class Achievements extends StatelessWidget
{
  var audio = GetIt.instance.get<Audio>();

  @override
  Widget build(BuildContext context)
  {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Achievements")
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
                    children: [new Text("")]
                )
            )
        )
    );
  }
}