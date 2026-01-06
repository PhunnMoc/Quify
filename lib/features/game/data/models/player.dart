class Player {
  String id;
  String name;
  int score;
  int selectedAnswer; // -1: not selected

  Player({
    this.id = '',
    this.name = '',
    this.score = 0,
    this.selectedAnswer = -1,
  });

  factory Player.fromMap(Map<dynamic, dynamic> map) {
    return Player(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown',
      score: int.tryParse(map['score']?.toString() ?? '0') ?? 0,
      selectedAnswer: int.tryParse(map['selectedAnswer']?.toString() ?? '-1') ?? -1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'score': score,
    'selectedAnswer': selectedAnswer,
  };
}

