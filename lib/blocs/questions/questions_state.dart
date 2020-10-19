import 'package:certain/models/question_model.dart';
import 'package:flutter/cupertino.dart';

@immutable
class QuestionsState {
  final bool isSuccess;
  final bool isSubmitting;
  final bool isFailure;

  QuestionsState(
      {this.isSuccess = false,
      this.isFailure = false,
      this.isSubmitting = false});

  factory QuestionsState.success() {
    return QuestionsState(
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  factory QuestionsState.failure() {
    return QuestionsState(
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory QuestionsState.loading() {
    return QuestionsState(
      isFailure: false,
      isSuccess: false,
      isSubmitting: true,
    );
  }
}

class QuestionsInitialState extends QuestionsState {}

class LoadingState extends QuestionsState {}

class LoadQuestionsState extends QuestionsState {
  final List<QuestionModel> questionList;

  LoadQuestionsState(this.questionList);
}

class LoadQuestionState extends QuestionsState {}
