part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthenticatedState extends AuthState {
  final AuthUserRepository authUser;
  const AuthenticatedState({required this.authUser});
}

final class UnauthenticatedState extends AuthState {}

final class AuthErrorState extends AuthState {
  final Exception error;

  const AuthErrorState({required this.error});

  @override
  String toString() {
    String err = error.toString().replaceFirst('Exception: ', '');
    return err;
  }
}

final class AuthUpdateErrorState extends AuthState {
  final Exception error;

  const AuthUpdateErrorState({required this.error});

  @override
  String toString() {
    String err = error.toString().replaceFirst('Exception: ', '');
    return err;
  }
}

final class TooManyRequestState extends AuthState {}

final class UserShouldVerifyEmailState extends AuthState {}

final class RemainingTimeState extends AuthState {
  final int remainSec;
  const RemainingTimeState({required this.remainSec});
}

final class VerificationSendedState extends AuthState {}

final class VerificationNotSendedState extends AuthState {}

final class LoadingState extends AuthState {}

final class PasswordResetSendedToEmailState extends AuthState {}

final class NameUpdatedState extends AuthState {
  final String newName;

  const NameUpdatedState({required this.newName});
}

final class PasswdUpdatedState extends AuthState {}
