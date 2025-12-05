part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class IsAuthenticatedEvent extends AuthEvent {}

class LoginGoogleEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class LoginEmailPaswdEven extends AuthEvent {
  final String email;
  final String paswd;

  const LoginEmailPaswdEven({required this.email, required this.paswd});
}

class RegisterEmailPaswdEvent extends AuthEvent {
  final String email;
  final String paswd;

  const RegisterEmailPaswdEvent({required this.email, required this.paswd});
}

class UserShoulVerifyEmailEvent extends AuthEvent {
  final int totalWaitSec;

  UserShoulVerifyEmailEvent({required this.totalWaitSec});
}

class TooManyRequestEvent extends AuthEvent {
  final int totalWaitSec;

  TooManyRequestEvent({required this.totalWaitSec});
}

// this one is
final class RemainingTimeEvent extends AuthEvent {
  final int totalSecToWait;

  RemainingTimeEvent({required this.totalSecToWait});
}

final class SendVerificationToEmailEvent implements AuthEvent {}

final class SendPaswdResetEvent implements AuthEvent {
  final String email;

  SendPaswdResetEvent({required this.email});
}

final class UpdateNameEvent implements AuthEvent {
  final String name;

  UpdateNameEvent({required this.name});
}

final class UpdatePasswdEvent implements AuthEvent {
  final String passwd;

  UpdatePasswdEvent({required this.passwd});
}

final class LoadingEvent implements AuthEvent {}
