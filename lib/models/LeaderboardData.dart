import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:play_games/play_games.dart';
import "package:collection/collection.dart";
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/helpers/DatabaseService.dart';
import 'Leaderboard.dart';

class LeaderboardData
{
  final log = Logger('LeaderboardData');
  var db = GetIt.instance.get<DatabaseService>();

  var leaderboards = [
    Leaderboard("CgkI6sCAqJkCEAIQDw", "Average Time", "assets/images/Leaderboard-AverageTime.png" ),
    Leaderboard("CgkI6sCAqJkCEAIQEQ", "Average Solution Rate", "assets/images/Leaderboard-AverageSolutionRate.png"),
    Leaderboard("CgkI6sCAqJkCEAIQEw", "Puzzles completed", "assets/images/Leaderboard-PuzzlesCompleted.png"),
    Leaderboard("CgkI6sCAqJkCEAIQFQ", "Average Hints", "assets/images/Leaderboard-AverageHints.png"),
    Leaderboard("CgkI6sCAqJkCEAIQFg", "Average Combined Score", "assets/images/Leaderboard-AverageCombined.png"),
  ];

  Leaderboard getLeaderboardById(String id)
  {
    return leaderboards.firstWhere((element) => element.id.contains(id));
  }

  void submitScore(Score score) async
  {
    for(var index = 0; index < leaderboards.length; index++)
    {
      var leaderboard = leaderboards[index];
      var value = -1;
      switch(leaderboard.name)
      {
        case "Average Time":
          value = score.elapsedSeconds;
          break;
        case "Average Solution Rate":
          value = score.puzzleSolveRate.toInt();
          break;
        case "Puzzles completed":
          var scores = await db.getScores();
          value = scores.where((element) => element.isCorrect).length;
          break;
        case "Average Hints":
          value = score.hintsUsed;
          break;
        case "Average Combined Score":
          value = score.combinedScore.toInt();
          break;
      }
      if(value != -1)
      {
        PlayGames.submitScoreById(leaderboard.id, score.combinedScore.toInt());
        log.fine("submitScoreById for ${leaderboard.name} scoring $value");
      }
    }
  }
}