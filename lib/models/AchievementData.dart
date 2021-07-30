import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:play_games/play_games.dart';
import "package:collection/collection.dart";
import 'package:sudokuapp/db/Score.dart';
import 'package:sudokuapp/helpers/DatabaseService.dart';
import 'package:sudokuapp/helpers/Utilities.dart';
import 'package:sudokuapp/models/PuzzleDifficulty.dart';
import 'Achievement.dart';
import 'Puzzle.dart';

class AchievementData
{
  final log = Logger('AchievementData');
  var db = GetIt.instance.get<DatabaseService>();
  var utilities = GetIt.instance.get<Utilities>();

  var _easyStart = Achievement("CgkI6sCAqJkCEAIQBA", "Easy Start" );
  var _novicePuzzler = Achievement("CgkI6sCAqJkCEAIQAg", "Novice Puzzler");
  var _adeptPuzzler = Achievement("CgkI6sCAqJkCEAIQAw", "Adept Puzzler");
  var _mediumMaster = Achievement("CgkI6sCAqJkCEAIQBQ", "Medium Master");
  var _masterPuzzler = Achievement("CgkI6sCAqJkCEAIQBw", "Master Puzzler");
  var _divinePuzzler = Achievement("CgkI6sCAqJkCEAIQCQ", "Divine Puzzler");
  var _quickLearner = Achievement("CgkI6sCAqJkCEAIQBg", "Quick Learner");
  var _extremeSkills = Achievement("CgkI6sCAqJkCEAIQDA", "Extreme skills");
  var _insanity = Achievement("CgkI6sCAqJkCEAIQDQ", "Insanity");
  var _challenged = Achievement("CgkI6sCAqJkCEAIQGg", "Challenged");
  var _experiencedPuzzler = Achievement("CgkI6sCAqJkCEAIQGw", "Experienced Puzzler");
  var _hardMaster = Achievement("CgkI6sCAqJkCEAIQHA", "Hard Master");
  var _bunnyBrain = Achievement("CgkI6sCAqJkCEAIQCg", "Bunny Brain");
  var _clueless = Achievement("CgkI6sCAqJkCEAIQCw", "Clueless");
  var _leet = Achievement("CgkI6sCAqJkCEAIQIA", "Leet");
  var _humble = Achievement("CgkI6sCAqJkCEAIQIQ", "Humble");
  var _prime = Achievement("CgkI6sCAqJkCEAIQIg", "Prime");
  var _teachersPet = Achievement("CgkI6sCAqJkCEAIQCA", "Teachers Pet");
  var _teachersAssistant = Achievement("CgkI6sCAqJkCEAIQJA", "Teachers Assistant");
  var _teacher = Achievement("CgkI6sCAqJkCEAIQJQ", "Teacher");

  void submitVote()
  {
    PlayGames.incrementAchievementById(_teachersPet.id);
    PlayGames.incrementAchievementById(_teachersAssistant.id);
    PlayGames.incrementAchievementById(_teacher.id);
    log.fine("incrementAchievementById for ${_teachersPet.name}");
    log.fine("incrementAchievementById for ${_teachersAssistant.name}");
    log.fine("incrementAchievementById for ${_teacher.name}");
  }
  
  void submitScore(Puzzle puzzle, Score score) async
  {
    //Process Google Play Achievements
    if (score.isCorrect)
    {
      if (score.hintsUsed <= 3)
      {
        switch (puzzle.difficulty)
        {
          case PuzzleDifficulty.Easy:
            PlayGames.unlockAchievementById(_easyStart.id);
            PlayGames.incrementAchievementById(_novicePuzzler.id);
            log.fine("unlockAchievementById for ${_easyStart.name}");
            log.fine("incrementAchievementById for ${_novicePuzzler.name}");
            break;
          case PuzzleDifficulty.Medium:
            PlayGames.incrementAchievementById(_mediumMaster.id);
            log.fine("incrementAchievementById for ${_mediumMaster.name}");
            break;
          case PuzzleDifficulty.Hard:
            PlayGames.incrementAchievementById(_hardMaster.id);
            log.fine("incrementAchievementById for ${_hardMaster.name}");
            break;
          case PuzzleDifficulty.Extreme:
            PlayGames.incrementAchievementById(_extremeSkills.id);
            log.fine("incrementAchievementById for ${_extremeSkills.name}");
            break;
          case PuzzleDifficulty.Insane:
            PlayGames.incrementAchievementById(_insanity.id);
            log.fine("incrementAchievementById for ${_insanity.name}");
            break;
        }
        PlayGames.incrementAchievementById(_adeptPuzzler.id);
        PlayGames.incrementAchievementById(_experiencedPuzzler.id);
        PlayGames.incrementAchievementById(_masterPuzzler.id);
        PlayGames.incrementAchievementById(_divinePuzzler.id);

        log.fine("incrementAchievementById for ${_adeptPuzzler.name}");
        log.fine("incrementAchievementById for ${_experiencedPuzzler.name}");
        log.fine("incrementAchievementById for ${_masterPuzzler.name}");
        log.fine("incrementAchievementById for ${_divinePuzzler.name}");

        if (score.combinedScore == 0)
        {
          PlayGames.unlockAchievementById(_humble.id);
          log.fine("unlockAchievementById for ${_humble.name}");
        }
        else if (score.combinedScore == 1337)
        {
          PlayGames.unlockAchievementById(_leet.id);
          log.fine("unlockAchievementById for ${_leet.name}");
        }
        else if (utilities.isPrime(score.combinedScore))
        {
          PlayGames.unlockAchievementById(_prime.id);
          log.fine("unlockAchievementById for ${_prime.name}");
        }
      }
    }
    else
    {
      PlayGames.incrementAchievementById(_challenged.id);
      PlayGames.incrementAchievementById(_bunnyBrain.id);
      log.fine("incrementAchievementById for ${_challenged.name}");
      log.fine("incrementAchievementById for ${_bunnyBrain.name}");
    }

    if (score.hintsUsed >= 25)
    {
      PlayGames.unlockAchievementById(_clueless.id);
      log.fine("unlockAchievementById for ${_clueless.name}");
    }

    var scores = await db.getScores();
    if (scores.any((a) => a.puzzleId == puzzle.puzzleId && a.combinedScore < score.combinedScore))
    {
      PlayGames.unlockAchievementById(_quickLearner.id);
      log.fine("unlockAchievementById for ${_quickLearner.name}");
    }
  }
}