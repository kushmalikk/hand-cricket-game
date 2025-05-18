import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hand_cricket/bloc/game_cubit.dart';

class GameScreen extends StatefulWidget {
  final String title;
  const GameScreen({super.key, required this.title});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String tossWinner = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _showTossDialog);
  }

  void _showTossDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Toss Time!'),
        content: const Text('Choose Heads or Tails'),
        actions: [
          TextButton(
            onPressed: () => _handleToss('Heads'),
            child: const Text('Heads'),
          ),
          TextButton(
            onPressed: () => _handleToss('Tails'),
            child: const Text('Tails'),
          ),
        ],
      ),
    );
  }

  void _handleToss(String userCall) {
    Navigator.pop(context);
    final coin = Random().nextBool() ? 'Heads' : 'Tails';

    if (coin == userCall) {
      _showBatOrBowlChoice();
    } else {
      final aiBatsFirst = Random().nextBool();
      setState(() {
        tossWinner = 'AI';
      });
      context.read<GameCubit>().resetGame(userBatsFirst: !aiBatsFirst);
    }
  }

  void _showBatOrBowlChoice() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('You won the toss!'),
        content: const Text('Choose to bat or bowl'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                tossWinner = 'You';
              });
              context.read<GameCubit>().resetGame(userBatsFirst: true);
            },
            child: const Text('Bat'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                tossWinner = 'You';
              });
              context.read<GameCubit>().resetGame(userBatsFirst: false); // AI bats first
            },
            child: const Text('Bowl'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.deepPurpleAccent, // Custom color for AppBar
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<GameCubit, GameState>(
            builder: (context, state) {
              final cubit = context.read<GameCubit>();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: tossWinner.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: Text(
                      '$tossWinner won the toss!',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blue),
                    ),
                  ),
                  if ((state.userBattingFirst && state.userOut && !state.aiOut) ||
                      (!state.userBattingFirst && state.aiOut && !state.userOut))
                    Text(
                      '🎯 Target: ${state.userBattingFirst ? state.userScore + 1 : state.aiScore + 1}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.orange),
                    ),
                  if (state.userOut && state.aiOut)
                    Text(
                      '🎯 Target was: ${state.userBattingFirst ? state.userScore + 1 : state.aiScore + 1}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal),
                    ),
                  Text(
                    !state.userOut && !state.aiTurn
                        ? '🏏 You are batting'
                        : state.aiTurn && !state.aiOut
                            ? '🎯 You are bowling'
                            : '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: Text(
                      state.userOut && state.aiOut
                          ? (state.userScore > state.aiScore
                              ? '🎉 You Win!'
                              : (state.userScore < state.aiScore ? '🤖 AI Wins!' : '🤝 Draw!'))
                          : state.aiTurn
                              ? 'AI is batting...'
                              : 'Play your turn',
                      key: ValueKey<String>(
                        state.userOut && state.aiOut
                            ? (state.userScore > state.aiScore
                                ? 'You Win!'
                                : (state.userScore < state.aiScore ? 'AI Wins!' : 'Draw!'))
                            : state.aiTurn
                                ? 'AI is batting...'
                                : 'Play your turn',
                      ),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text('Your Score: ${state.userScore}',
                        key: ValueKey<int>(state.userScore),
                        style: const TextStyle(fontSize: 20, color: Colors.green)),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text('AI Score: ${state.aiScore}',
                        key: ValueKey<int>(state.aiScore),
                        style: const TextStyle(fontSize: 20, color: Colors.red)),
                  ),
                  const SizedBox(height: 20),
                  if (state.userChoice != null && state.aiChoice != null)
                    Text('You chose: ${state.userChoice} | AI chose: ${state.aiChoice}',
                        style: const TextStyle(fontSize: 18, color: Colors.blue)),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 10,
                    children: List.generate(6, (index) {
                      int number = index + 1;
                      return ElevatedButton(
                        onPressed: () {
                          if (!state.userOut && !state.aiTurn) {
                            cubit.playTurn(number);
                          } else if (state.aiTurn && !state.aiOut) {
                            cubit.bowlToAI(number);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('$number'),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        tossWinner = '';
                      });
                      context.read<GameCubit>().resetGame();
                      _showTossDialog();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), // Custom reset button color
                    child: const Text('Reset Game'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}