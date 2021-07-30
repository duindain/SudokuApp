import 'dart:convert';

class SaveGame
{
  int? id;
  String puzzleId;
  int? elapsedSeconds;
  String? inProgress;
  String? hints;
  List<String> notes = new List.empty(growable: true);
  DateTime? lastPlayed;

  SaveGame(this.puzzleId, {this.id, this.elapsedSeconds, this.inProgress, this.hints, List<String>? optionalNotes, this.lastPlayed})
  {
    if(optionalNotes != null)
    {
      this.notes = optionalNotes;
    }
  }

  factory SaveGame.fromJson(Map<String, dynamic> json) => SaveGame(
    json["puzzleId"],
    id: json["id"],
    elapsedSeconds: json["elapsedSeconds"].toInt(),
    inProgress: json["inProgress"],
    hints: json["hints"],
    optionalNotes: (jsonDecode(json["notes"]) as List<dynamic>).cast<String>(),
    lastPlayed: DateTime.parse(json["lastPlayed"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "puzzleId": puzzleId,
    "elapsedSeconds": elapsedSeconds,
    "inProgress": inProgress,
    "hints": hints,
    "notes": jsonEncode(notes),
    "lastPlayed": lastPlayed != null ? "${lastPlayed?.year.toString().padLeft(4, '0')}-${lastPlayed?.month.toString().padLeft(2, '0')}-${lastPlayed?.day.toString().padLeft(2, '0')}" : "",
  };
}