class Score
{
  int? id;
  String puzzleId;
  int elapsedSeconds;
  double puzzleSolveRate;
  int hintsUsed;
  double combinedScore;
  bool isCorrect;
  bool submitted;
  DateTime completed;

  Score(
    this.puzzleId,
    this.elapsedSeconds,
    this.puzzleSolveRate,
    this.hintsUsed,
    this.combinedScore,
    this.isCorrect,
    this.submitted,
    this.completed,
    { this.id }
  );

  factory Score.fromJson(Map<String, dynamic> json) => Score(
    json["puzzleId"],
    json["elapsedSeconds"].toInt(),
    json["puzzleSolveRate"].toDouble(),
    json["hintsUsed"].toInt(),
    json["combinedScore"].toDouble(),
    json["isCorrect"],
    json["submitted"],
    DateTime.parse(json["completed"]),
    id: json["id"].toInt(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "puzzleId": puzzleId,
    "elapsedSeconds": elapsedSeconds,
    "puzzleSolveRate": puzzleSolveRate,
    "hintsUsed": hintsUsed,
    "combinedScore": combinedScore,
    "isCorrect": isCorrect,
    "submitted": submitted,
    "completed": "${completed.year.toString().padLeft(4, '0')}-${completed.month.toString().padLeft(2, '0')}-${completed.day.toString().padLeft(2, '0')}",
  };
}