import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'game_screen.dart';

class ResultScreen extends StatelessWidget {
  final bool won;
  final int questionReached;
  final List<String> prizes;
  final List<int> safePoints;

  const ResultScreen({
    super.key,
    required this.won,
    required this.questionReached,
    required this.prizes,
    required this.safePoints,
  });

  String get _wonPrize {
    if (won) return prizes[14];
    // اربح آخر محطة أمان وصلها
    int safe = -1;
    for (final s in safePoints) {
      if (questionReached > s) safe = s;
    }
    return safe >= 0 ? prizes[safe] : '0';
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: won
                              ? [const Color(0xFFFFD700), const Color(0xFFFF8C00)]
                              : [const Color(0xFFB71C1C), const Color(0xFF4A0000)],
                        ),
                        boxShadow: [BoxShadow(
                          color: (won ? Colors.amber : Colors.red).withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )],
                      ),
                      child: Icon(
                        won ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      won ? 'مبروك! فزت!' : 'انتهت اللعبة',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: won ? const Color(0xFFFFD700) : Colors.redAccent,
                        shadows: [Shadow(color: (won ? Colors.amber : Colors.red).withOpacity(0.5), blurRadius: 15)],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (!won)
                      Text(
                        'وصلت إلى السؤال ${questionReached + 1}',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    const SizedBox(height: 20),

                    // Prize box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: won
                              ? [const Color(0xFFFFD700), const Color(0xFFFF8C00)]
                              : [const Color(0xFF1E2D6B), const Color(0xFF283593)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: won ? Colors.amber : Colors.white24, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            won ? 'جائزتك' : 'مبلغك المضمون',
                            style: TextStyle(
                              fontSize: 14,
                              color: won ? Colors.black87 : Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_wonPrize ريال',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: won ? Colors.black : const Color(0xFFFFD700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Buttons
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameScreen())),
                      child: Container(
                        width: 240,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 15)],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.replay, color: Colors.black),
                            SizedBox(width: 8),
                            Text('العب مجدداً', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
                      child: Container(
                        width: 240,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, color: Colors.white70),
                            SizedBox(width: 8),
                            Text('الصفحة الرئيسية', style: TextStyle(fontSize: 16, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
