class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final int difficulty; // 1=easy, 2=medium, 3=hard

  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    this.difficulty = 1,
  });
}
