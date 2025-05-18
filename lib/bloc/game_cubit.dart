import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState.initial());

  final _random = Random();

  void playTurn(int userSelected) {
    if (state.userOut || state.aiTurn) return;

    final aiSelected = _random.nextInt(6) + 1;
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

    final aiBat = _random.nextInt(6) + 1;
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
    emit(GameState.initial(userBatsFirst: userBatsFirst));
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

  static GameState initial({bool userBatsFirst = true}) {
    return GameState(
      userScore: 0,
      aiScore: 0,
      userChoice: null,
      aiChoice: null,
      userOut: !userBatsFirst,
      aiOut: false,
      aiTurn: !userBatsFirst,
      userBattingFirst: userBatsFirst,
    );
  }
}