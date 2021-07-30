import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sudokuapp/helpers/Audio.dart';
import 'package:sudokuapp/helpers/Utilities.dart';

class Challenges extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    var utilities = GetIt.instance.get<Utilities>();
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Challenges")
        ),
        body:
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child:
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

            ]
          )
        )
    );
  }
}