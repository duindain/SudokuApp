import 'package:equatable/equatable.dart';

import 'PuzzleDifficulty.dart';

class Puzzle extends Equatable
{
  String puzzleId;
  String puzzle;
  String clues;
  PuzzleDifficulty difficulty;

  Puzzle(
    this.puzzleId,
    this.puzzle,
    this.clues,
    this.difficulty
  );

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return new Puzzle(
      json['PuzzleId'] as String,
      json['Puzzle'] as String,
      json['Clue'] as String,
      PuzzleDifficulty.values[json["Difficulty"] as int],
    );
  }

  @override
  // TODO: implement props
  List<Object> get props => [puzzleId];
}