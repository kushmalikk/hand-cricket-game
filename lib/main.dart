import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand Cricket',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Hand Cricket Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int userScore = 0;
  int? userChoice;
  int? aiChoice;
  bool isOut = false;
  bool aiTurn = false;
  int aiScore = 0;
  bool userOut = false;
  bool aiOut = false;

  void _playTurn(int userSelected) {
    if (userOut || aiTurn) return;

    final random = Random();
    int aiSelected = random.nextInt(6) + 1;

    setState(() {
      userChoice = userSelected;
      aiChoice = aiSelected;

      if (userSelected == aiSelected) {
        userOut = true;
        aiTurn = true;
      } else {
        userScore += userSelected;
      }
    });
  }

  void _bowlToAI(int userBowled) {
    if (!aiTurn || aiOut) return;

    final random = Random();
    int aiBat = random.nextInt(6) + 1;

    setState(() {
      userChoice = userBowled;
      aiChoice = aiBat;

      if (userBowled == aiBat) {
        aiOut = true;
        aiTurn = false;
      } else {
        aiScore += aiBat;
      }
    });
  }

  void _resetGame() {
    setState(() {
      userScore = 0;
      userChoice = null;
      aiChoice = null;
      userOut = false;
      aiOut = false;
      aiTurn = false;
      aiScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userOut && aiOut
                  ? (userScore > aiScore
                      ? 'You Win!'
                      : (userScore < aiScore ? 'AI Wins!' : 'Draw!'))
                  : aiTurn
                      ? 'AI is batting...'
                      : 'Play your turn',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Your Score: $userScore', style: const TextStyle(fontSize: 20)),
            Text('AI Score: $aiScore', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            if (userChoice != null && aiChoice != null)
              Text('You chose: $userChoice | AI chose: $aiChoice',
                  style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              children: List.generate(6, (index) {
                int number = index + 1;
                return ElevatedButton(
                  onPressed: () {
                    if (!userOut && !aiTurn) {
                      _playTurn(number);
                    } else if (aiTurn && !aiOut) {
                      _bowlToAI(number);
                    }
                  },
                  child: Text('$number'),
                );
              }),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reset Game'),
            ),
          ],
        ),
      ),
    );
  }
}
