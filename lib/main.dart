import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class GameCubit extends Cubit<GameState> {
  GameCubit()
      : super(GameState(
          userScore: 0,
          aiScore: 0,
          userChoice: null,
          aiChoice: null,
          userOut: false,
          aiOut: false,
          aiTurn: false,
          userBattingFirst: true,
        ));

  final _random = Random();

  void playTurn(int userSelected) {
    if (state.userOut || state.aiTurn) return;

    int aiSelected = _random.nextInt(6) + 1;

    final isOut = userSelected == aiSelected;
    final userScore = isOut ? state.userScore : state.userScore + userSelected;

    if (!state.userBattingFirst && state.aiOut && userScore > state.aiScore) {
      emit(state.copyWith(
        userScore: userScore,
        userChoice: userSelected,
        aiChoice: aiSelected,
        aiOut: true,
        aiTurn: false,
      ));
      return;
    }

    emit(state.copyWith(
      userChoice: userSelected,
      aiChoice: aiSelected,
      userScore: userScore,
      userOut: isOut,
      aiTurn: isOut || state.aiTurn,
    ));
  }

  void bowlToAI(int userBowled) {
    if (!state.aiTurn || state.aiOut) return;

    int aiBat = _random.nextInt(6) + 1;
    final isOut = userBowled == aiBat;
    final aiScore = isOut ? state.aiScore : state.aiScore + aiBat;

    if (state.userBattingFirst && state.userOut && aiScore > state.userScore) {
      emit(state.copyWith(
        aiScore: aiScore,
        userChoice: userBowled,
        aiChoice: aiBat,
        userOut: true,
        aiTurn: false,
        aiOut: true,
      ));
      return;
    }

    emit(state.copyWith(
      userChoice: userBowled,
      aiChoice: aiBat,
      aiScore: aiScore,
      aiOut: isOut,
      aiTurn: !isOut,
    ));
  }

  void resetGame({bool userBatsFirst = true}) {
    emit(GameState.initial().copyWith(userBattingFirst: userBatsFirst));
  }
}

class GameState {
  final int userScore;
  final int aiScore;
  final int? userChoice;
  final int? aiChoice;
  final bool userOut;
  final bool aiOut;
  final bool aiTurn;
  final bool userBattingFirst;

  GameState({
    required this.userScore,
    required this.aiScore,
    required this.userChoice,
    required this.aiChoice,
    required this.userOut,
    required this.aiOut,
    required this.aiTurn,
    required this.userBattingFirst,
  });

  GameState copyWith({
    int? userScore,
    int? aiScore,
    int? userChoice,
    int? aiChoice,
    bool? userOut,
    bool? aiOut,
    bool? aiTurn,
    bool? userBattingFirst,
  }) {
    return GameState(
      userScore: userScore ?? this.userScore,
      aiScore: aiScore ?? this.aiScore,
      userChoice: userChoice ?? this.userChoice,
      aiChoice: aiChoice ?? this.aiChoice,
      userOut: userOut ?? this.userOut,
      aiOut: aiOut ?? this.aiOut,
      aiTurn: aiTurn ?? this.aiTurn,
      userBattingFirst: userBattingFirst ?? this.userBattingFirst,
    );
  }

  static GameState initial() {
    return GameState(
      userScore: 0,
      aiScore: 0,
      userChoice: null,
      aiChoice: null,
      userOut: false,
      aiOut: false,
      aiTurn: false,
      userBattingFirst: true,
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<GameCubit, GameState>(
            builder: (context, state) {
              final cubit = context.read<GameCubit>();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.userOut && state.aiOut
                        ? (state.userScore > state.aiScore
                            ? 'You Win!'
                            : (state.userScore < state.aiScore ? 'AI Wins!' : 'Draw!'))
                        : state.aiTurn
                            ? 'AI is batting...'
                            : 'Play your turn',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text('Your Score: ${state.userScore}', style: const TextStyle(fontSize: 20)),
                  Text('AI Score: ${state.aiScore}', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  if (state.userChoice != null && state.aiChoice != null)
                    Text('You chose: ${state.userChoice} | AI chose: ${state.aiChoice}',
                        style: const TextStyle(fontSize: 18)),
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
                        child: Text('$number'),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: cubit.resetGame,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
