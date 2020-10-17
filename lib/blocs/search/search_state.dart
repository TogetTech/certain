import 'package:certain/models/user_model.dart';
import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

class InitialSearchState extends SearchState {}

class LoadingState extends SearchState {}

class LoadUserState extends SearchState {
  final UserModel user;

  LoadUserState(this.user);
}

class LoadCurrentUserState extends SearchState {
  final UserModel currentUser;

  LoadCurrentUserState(this.currentUser);

  @override
  List<Object> get props => [currentUser];
}

class HasMatchedState extends SearchState {}
