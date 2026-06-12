import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../data/questions.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<Question> _gameQuestions;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _usedFiftyFifty = false;
  bool _usedAudience = false;
  bool _usedPhone = false;
  List<int> _hiddenOptions = [];
  int _timeLeft = 30;
  Timer? _timer;

  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  static const List<String> prizes = [
    '1,000', '2,000', '3,000', '5,000', '7,500',
    '10,000', '15,000', '20,000', '30,000', '50,000',
    '75,000', '125,000', '250,000', '500,000', '1,000,000',
  ];

  static const List<int> safePoints = [4, 9];

  @override
  void initState() {
    super.initState();
    _prepareQuestions();
    _startTimer();
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(_glowController);
  }

  void _prepareQuestions() {
    final easy = (easyQuestions.where((q) => q.difficulty == 1).toList()..shuffle()).take(5).toList();
    final medium = (easyQuestions.where((q) => q.difficulty == 2).toList()..shuffle()).take(5).toList();
    final hard = (easyQuestions.where((q) => q.difficulty == 3).toList()..shuffle()).take(5).toList();
    _gameQuestions = [...easy, ...medium, ...hard];
  }

  void _startTimer() {
    _timeLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _timer?.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    setState(() => _answered = true);
    Future.delayed(const Duration(seconds: 2), () => _goToResult(won: false));
  }

  Question get _currentQuestion => _gameQuestions[_currentIndex];

  void _selectAnswer(int index) {
    if (_answered || _hiddenOptions.contains(index)) return;
    _timer?.cancel();
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (_selectedAnswer == _currentQuestion.correctIndex) {
        if (_currentIndex == 14) {
          _goToResult(won: true);
        } else {
          setState(() {
            _currentIndex++;
            _selectedAnswer = null;
            _answered = false;
            _hiddenOptions = [];
          });
          _startTimer();
        }
      } else {
        _goToResult(won: false);
      }
    });
  }

  void _goToResult({required bool won}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(
        won: won,
        questionReached: _currentIndex,
        prizes: prizes,
        safePoints: safePoints,
      )),
    );
  }

  void _useFiftyFifty() {
    if (_usedFiftyFifty || _answered) return;
    final correct = _currentQuestion.correctIndex;
    final wrong = List.generate(4, (i) => i).where((i) => i != correct).toList()..shuffle();
    setState(() {
      _usedFiftyFifty = true;
      _hiddenOptions = wrong.take(2).toList();
    });
  }

  void _useAudience() {
    if (_usedAudience || _answered) return;
    setState(() => _usedAudience = true);
    final rng = Random();
    final correct = _currentQuestion.correctIndex;
    final correctPct = 50 + rng.nextInt(35);
    final remaining = 100 - correctPct;
    final wrongPcts = List.generate(3, (_) => 0);
    int leftover = remaining;
    for (int i = 0; i < 2; i++) {
      wrongPcts[i] = rng.nextInt(leftover);
      leftover -= wrongPcts[i];
    }
    wrongPcts[2] = leftover;
    wrongPcts.shuffle();

    final List<int> pcts = List.generate(4, (i) {
      if (i == correct) return correctPct;
      final wrongIdx = [0, 1, 2, 3].where((x) => x != correct).toList().indexOf(i);
      return wrongPcts[wrongIdx < 0 ? 0 : wrongIdx];
    });

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A5E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('رأي الجمهور', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (i) {
              if (_hiddenOptions.contains(i)) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text('${_optionLabel(i)} ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: pcts[i] / 100,
                        backgroundColor: Colors.white12,
                        color: const Color(0xFFFFD700),
                        minHeight: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${pcts[i]}%', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              );
            }),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً', style: TextStyle(color: Color(0xFFFFD700))))],
        ),
      ),
    );
  }

  void _usePhone() {
    if (_usedPhone || _answered) return;
    setState(() => _usedPhone = true);
    final correct = _currentQuestion.correctIndex;
    final option = _currentQuestion.options[correct];
    final hints = [
      'أعتقد أن الإجابة هي "$option"، لكن لست متأكداً تماماً!',
      'في رأيي أن الجواب الصحيح هو "$option"',
      'أتذكر أن الإجابة تبدأ بـ "${option[0]}"... وأظنها "$option"',
    ];
    final hint = hints[Random().nextInt(hints.length)];
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A5E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('الاتصال بصديق', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
          content: Row(
            children: [
              const Icon(Icons.phone, color: Color(0xFF00E676), size: 30),
              const SizedBox(width: 12),
              Expanded(child: Text(hint, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5))),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('شكراً!', style: TextStyle(color: Color(0xFF00E676))))],
        ),
      ),
    );
  }

  String _optionLabel(int i) => ['أ', 'ب', 'ج', 'د'][i];

  Color _optionColor(int i) {
    if (!_answered) return const Color(0xFF1E2D6B);
    if (i == _currentQuestion.correctIndex) return const Color(0xFF1B5E20);
    if (i == _selectedAnswer) return const Color(0xFFB71C1C);
    return const Color(0xFF1E2D6B);
  }

  Color _optionBorder(int i) {
    if (!_answered) return const Color(0xFF3949AB);
    if (i == _currentQuestion.correctIndex) return Colors.greenAccent;
    if (i == _selectedAnswer) return Colors.redAccent;
    return const Color(0xFF3949AB);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0A2E), Color(0xFF1A1A5E), Color(0xFF0D0D3B)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildQuestionCard(),
                const SizedBox(height: 8),
                _buildOptions(),
                const SizedBox(height: 12),
                _buildLifelines(),
                const SizedBox(height: 8),
                _buildPrizeLadder(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              const Icon(Icons.timer, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Text(
                  '$_timeLeft',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _timeLeft <= 10 ? Colors.red : const Color(0xFFFFD700),
                    shadows: [Shadow(color: (_timeLeft <= 10 ? Colors.red : Colors.amber).withOpacity(_glowAnim.value), blurRadius: 12)],
                  ),
                ),
              ),
            ],
          ),
          Text(
            'سؤال ${_currentIndex + 1}/15',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E2D6B), Color(0xFF283593)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.15), blurRadius: 20)],
      ),
      child: Text(
        _currentQuestion.text,
        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(4, (i) {
          if (_hiddenOptions.contains(i)) {
            return const SizedBox(height: 52);
          }
          return GestureDetector(
            onTap: () => _selectAnswer(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: _optionColor(i),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _optionBorder(i), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.6)),
                    ),
                    child: Center(
                      child: Text(_optionLabel(i), style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_currentQuestion.options[i], style: const TextStyle(color: Colors.white, fontSize: 15))),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLifelines() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _lifelineBtn('50:50', Icons.filter_2, const Color(0xFF1565C0), _usedFiftyFifty, _useFiftyFifty),
        const SizedBox(width: 16),
        _lifelineBtn('الجمهور', Icons.people, const Color(0xFFF57F17), _usedAudience, _useAudience),
        const SizedBox(width: 16),
        _lifelineBtn('اتصال', Icons.phone, const Color(0xFF2E7D32), _usedPhone, _usePhone),
      ],
    );
  }

  Widget _lifelineBtn(String label, IconData icon, Color color, bool used, VoidCallback onTap) {
    return GestureDetector(
      onTap: used ? null : onTap,
      child: Opacity(
        opacity: used ? 0.35 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrizeLadder() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: prizes.length,
        itemBuilder: (_, i) {
          final isCurrent = i == _currentIndex;
          final isPassed = i < _currentIndex;
          final isSafe = safePoints.contains(i);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFFFFD700)
                  : isPassed
                      ? Colors.white12
                      : isSafe
                          ? const Color(0xFF1B5E20).withOpacity(0.5)
                          : const Color(0xFF1A1A5E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent ? Colors.amber : isSafe ? Colors.greenAccent : Colors.white24,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Text(
              prizes[i],
              style: TextStyle(
                fontSize: 11,
                color: isCurrent ? Colors.black : Colors.white70,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}
