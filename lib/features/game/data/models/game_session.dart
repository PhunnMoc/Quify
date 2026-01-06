class GameSession {
  String id;
  String hostId;
  String quizId; // Added to link to the quiz
  String pinCode;
  String state; // 'WAITING', 'PLAYING', 'FINISHED'
  int currentQuestionIndex;
  int questionStartTime; // Timestamp (ms)

  GameSession({
    this.id = '',
    this.hostId = '',
    this.quizId = '',
    this.pinCode = '',
    this.state = 'WAITING',
    this.currentQuestionIndex = 0,
    this.questionStartTime = 0,
  });

  factory GameSession.fromMap(Map<dynamic, dynamic> map) {
    return GameSession(
      id: map['id']?.toString() ?? '',
      hostId: map['hostId']?.toString() ?? '',
      quizId: map['quizId']?.toString() ?? '',
      pinCode: map['pinCode']?.toString() ?? '',
      state: map['state']?.toString() ?? 'WAITING',
      currentQuestionIndex:
          int.tryParse(map['currentQuestionIndex']?.toString() ?? '0') ?? 0,
      questionStartTime:
          int.tryParse(map['questionStartTime']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hostId': hostId,
    'quizId': quizId,
    'pinCode': pinCode,
    'state': state,
    'currentQuestionIndex': currentQuestionIndex,
    'questionStartTime': questionStartTime,
  };
}
