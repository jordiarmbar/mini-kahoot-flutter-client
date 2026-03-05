import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

const kKahootPurple = Color(0xFF46178F);

// ─────────────────────────────────────────────
//  PANTALLA DE UNIRSE
// ─────────────────────────────────────────────
class ClientJoinScreen extends StatefulWidget {
  const ClientJoinScreen({super.key});

  @override
  State<ClientJoinScreen> createState() => _ClientJoinScreenState();
}

class _ClientJoinScreenState extends State<ClientJoinScreen> {
  final _pinCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  void _join() async {
    if (_pinCtrl.text.isEmpty || _nameCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    bool ok = await FirebaseService().joinSession(
      _pinCtrl.text,
      _nameCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ClientGameScreen(pin: _pinCtrl.text, playerName: _nameCtrl.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN incorrecto o sesión no existe')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kKahootPurple,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_android_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Kahoot!',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'App Cliente',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white60,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _pinCtrl,
                        decoration: InputDecoration(
                          labelText: 'PIN del juego',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Tu Nombre',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _join,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          backgroundColor: Colors.white,
                          foregroundColor: kKahootPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Unirse',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────
//  PANTALLA DE JUEGO DEL CLIENTE
// ─────────────────────────────────────────────
class ClientGameScreen extends StatefulWidget {
  final String pin;
  final String playerName;

  const ClientGameScreen({
    super.key,
    required this.pin,
    required this.playerName,
  });

  @override
  State<ClientGameScreen> createState() => _ClientGameScreenState();
}

class _ClientGameScreenState extends State<ClientGameScreen> {
  bool _submitted = false;
  bool _wasCorrect = false;
  int _lastSeenQIndex = -1;
  int _scoreEarned = 0;

  static const List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.green,
  ];

  Widget _buildAnswerCell(
    int i,
    Set<int> selected,
    List<dynamic> correctAnswers,
  ) {
    bool isSel = selected.contains(i);
    return GestureDetector(
      onTap: () {
        selected.clear();
        selected.add(i);
        _submit(correctAnswers, selected, false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _colors[i % _colors.length],
          borderRadius: BorderRadius.circular(14),
          border: isSel ? Border.all(color: Colors.white, width: 4) : null,
          boxShadow: [
            BoxShadow(
              color: _colors[i % _colors.length].withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isSel
              ? const Icon(Icons.check, size: 64, color: Colors.white)
              : _buildShape(i),
        ),
      ),
    );
  }

  Widget _buildShape(int i) {
    switch (i % 4) {
      case 0:
        return Transform.rotate(
          angle: -1.5708,
          child: const Icon(Icons.play_arrow, size: 60, color: Colors.white),
        );
      case 1:
        return Transform.rotate(
          angle: 0.7854,
          child: const Icon(Icons.square, size: 45, color: Colors.white),
        );
      case 2:
        return const Icon(Icons.circle, size: 60, color: Colors.white);
      case 3:
      default:
        return const Icon(Icons.square, size: 60, color: Colors.white);
    }
  }

  void _submit(List<dynamic> correctAnswers, Set<int> selected, bool timedOut) {
    if (_submitted) return;

    int score = 0;
    bool isCorrect = false;

    if (!timedOut && selected.isNotEmpty) {
      final bool anyCorrect = selected.any((s) => correctAnswers.contains(s));
      if (anyCorrect) {
        score = 100;
        isCorrect = true;
      }
    }

    FirebaseService().submitAnswer(widget.pin, widget.playerName, score);
    setState(() {
      _submitted = true;
      _wasCorrect = isCorrect;
      _scoreEarned = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kKahootPurple,
      appBar: AppBar(
        title: Text(
          widget.playerName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kKahootPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService().sessionStream(widget.pin),
        builder: (context, sessionSnap) {
          if (!sessionSnap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!sessionSnap.data!.exists) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ClientJoinScreen()),
                  (route) => false,
                );
              }
            });
            return const SizedBox.shrink();
          }

          var data = sessionSnap.data!.data() as Map<String, dynamic>;
          String status = data['status'];

          if (status == 'closed') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ClientJoinScreen()),
                  (route) => false,
                );
              }
            });
            return const SizedBox.shrink();
          }
          var qs = data['questions'] as List<dynamic>;
          int qIndex = data['currentQuestionIndex'];

          if (status == 'waiting') {
            return _buildWaitingScreen('Esperando a que empiece\nel host...');
          }

          if (status == 'finished') {
            return _buildWaitingScreen(
              '¡Partida finalizada!\nMira el servidor\npara ver el podium 🏆',
            );
          }

          if (qIndex != _lastSeenQIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _submitted = false;
                  _wasCorrect = false;
                  _scoreEarned = 0;
                  _lastSeenQIndex = qIndex;
                });
              }
            });
          }

          var currentQ = qs[qIndex];
          List<dynamic> answers = currentQ['answers'];
          List<dynamic> correctAnswers = currentQ['correctAnswers'];
          final int timeLimit = (currentQ['timeLimit'] as int?) ?? 30;

          if (_submitted) {
            return _buildResultScreen(_wasCorrect, _scoreEarned);
          }

          final Set<int> selected = {};

          return StatefulBuilder(
            builder: (context, setLocalState) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Timer invisible para disparar el evento de tiempo agotado
                    TweenAnimationBuilder<double>(
                      key: ValueKey('$qIndex-$timeLimit'),
                      tween: Tween(begin: timeLimit.toDouble(), end: 0.0),
                      duration: Duration(seconds: timeLimit),
                      onEnd: () => _submit(correctAnswers, selected, true),
                      builder: (context, value, child) =>
                          const SizedBox.shrink(),
                    ),
                    // Grid de respuestas (2x2 o span ancho total)
                    Expanded(
                      child: Column(
                        children: List.generate((answers.length / 2).ceil(), (
                          row,
                        ) {
                          final int a = row * 2;
                          final int b = a + 1;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: row < (answers.length / 2).ceil() - 1
                                    ? 10
                                    : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _buildAnswerCell(
                                      a,
                                      selected,
                                      correctAnswers,
                                    ),
                                  ),
                                  if (b < answers.length) ...[
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildAnswerCell(
                                        b,
                                        selected,
                                        correctAnswers,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildResultScreen(bool correct, int score) {
    return Container(
      color: kKahootPurple,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              correct ? '¡Correcto!' : 'Incorrecto',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: correct ? Colors.green : Colors.red,
                border: Border.all(color: Colors.white, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: (correct ? Colors.green : Colors.red).withOpacity(
                      0.5,
                    ),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                correct ? Icons.check : Icons.close,
                size: 72,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            if (correct) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 32,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E0E6A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '+$score puntos',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Bien jugado! 🎉',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            ] else ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 32,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E0E6A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  '¡Sigue intentándolo!',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'La próxima pregunta será tuya 💪',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
            const SizedBox(height: 40),
            const Text(
              'Esperando la siguiente pregunta...',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingScreen(String message) {
    return Container(
      color: kKahootPurple,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 32),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
