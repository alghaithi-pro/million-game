import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                    boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: const Icon(Icons.emoji_events, size: 64, color: Colors.white),
                ),
                const SizedBox(height: 30),
                const Text(
                  'من سيربح المليون',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                    fontFamily: 'Cairo',
                    shadows: [Shadow(color: Colors.amber, blurRadius: 10)],
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                const Text(
                  'أسئلة متنوعة من جميع أنحاء العالم',
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 60),
                _buildButton(
                  context,
                  label: 'ابدأ اللعب',
                  icon: Icons.play_arrow_rounded,
                  color: const Color(0xFFFFD700),
                  textColor: Colors.black,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())),
                ),
                const SizedBox(height: 20),
                _buildButton(
                  context,
                  label: 'كيف تلعب؟',
                  icon: Icons.help_outline,
                  color: Colors.white12,
                  textColor: Colors.white,
                  onTap: () => _showRules(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext ctx, {
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A5E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('كيف تلعب؟', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          content: const Text(
            '• يوجد 15 سؤالاً بصعوبة متزايدة\n'
            '• 4 خيارات لكل سؤال — اختر الصحيح\n'
            '• لديك 3 مساعدات:\n'
            '  🔵 50:50 — يحذف خيارين خاطئين\n'
            '  🟡 الجمهور — يعطيك إحصاء رأي الجمهور\n'
            '  🟢 الاتصال — يعطيك تلميحاً\n'
            '• توجد محطتا أمان عند السؤال 5 و10\n'
            '• الجائزة الكبرى: 1,000,000 ريال!',
            style: TextStyle(color: Colors.white, height: 1.8, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً', style: TextStyle(color: Color(0xFFFFD700), fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
