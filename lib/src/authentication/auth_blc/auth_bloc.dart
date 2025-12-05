import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/auth_exceptions.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/auth_user_repository.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/providers/email_auth_provider.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/providers/google_auth_provider.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/providers/shared_auth_providr.dart';
import 'package:firebase_bloc_auth/src/ansi_colors.dart';
import 'package:equatable/equatable.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(UnauthenticatedState()) {
    on<IsAuthenticatedEvent>(
      (event, emit) async {
        emit(LoadingState());
        AuthUserRepository? currentUser =
            await CustomSharedAuthProvider().isAuthenticated();

        if (currentUser != null && currentUser.isEmailVerified) {
          emit(AuthenticatedState(authUser: currentUser));
        } else if (currentUser != null && !currentUser.isEmailVerified) {
          emit(UserShouldVerifyEmailState());
        } else {
          emit(UnauthenticatedState());
        }
      },
    );
    on<LoginGoogleEvent>((event, emit) async {
      emit(LoadingState());
      await CustomGoogleAuthProvider().googleLogin().then((user) {
        if (user != null) {
          emit(AuthenticatedState(authUser: user));
        } else {
          emit(UnauthenticatedState());
        }
      }).catchError((error, stackTrace) {
        if (error is UserDisabledAuthException) {
          emit(AuthErrorState(error: UserDisabledAuthException()));
        } else {
          emit(AuthErrorState(error: Exception(error)));
        }
      });
    });
    on<LoginEmailPaswdEven>((event, emit) async {
      emit(LoadingState());
      if (event.email.isEmpty) {
        emit(AuthErrorState(
          error: Exception("Type your email. idk who you are"),
        ));
      } else if (event.paswd.isEmpty) {
        emit(AuthErrorState(
          error: Exception("Without password i cant sign you in. Sorry bro"),
        ));
      } else {
        await CustomEmailAuthProvider()
            .logIn(email: event.email, password: event.paswd)
            .then((user) {
          if (user != null && user.isEmailVerified) {
            emit(AuthenticatedState(authUser: user));
          } else {
            emit(
              UserShouldVerifyEmailState(),
            );
          }
        }).catchError((error, stackTrace) {
          if (error is TooManyRequestException) {
            emit(TooManyRequestState());
          } else {
            emit(AuthErrorState(
              error: error,
            ));
          }
        });
      }
    });
    on<RegisterEmailPaswdEvent>((event, emit) async {
      emit(LoadingState());

      if (event.email.isEmpty) {
        emit(AuthErrorState(
          error: Exception("Type your email. idk who you are"),
        ));
      } else if (event.paswd.isEmpty) {
        emit(AuthErrorState(
          error: Exception("Without password i cant sign you in. Sorry bro"),
        ));
      } else {
        await CustomEmailAuthProvider()
            .registerUser(email: event.email, password: event.paswd)
            .then((user) async {
          if (user != null && user.isEmailVerified) {
            emit(AuthenticatedState(authUser: user));
          } else {
            emit(UserShouldVerifyEmailState());
          }
        }).catchError((error, stackTrace) {
          if (error is TooManyRequestException) {
            emit(TooManyRequestState());
          } else {
            emit(AuthErrorState(error: error));
          }
        });
      }
    });
    on<LogoutEvent>((event, emit) async {
      emit(LoadingState());

      await CustomSharedAuthProvider().logOut().then((value) {
        emit(UnauthenticatedState());
      });
    });
    on<RemainingTimeEvent>((event, emit) async {
      int remains = event.totalSecToWait;

      await Future.forEach(
        List.generate(remains, (index) => index),
        (element) async {
          await Future.delayed(const Duration(seconds: 1));
          --remains;
          emit(RemainingTimeState(remainSec: remains));
        },
      );
    });
    on<SendVerificationToEmailEvent>((event, emit) async {
      emit(LoadingState());

      await CustomEmailAuthProvider().sendEmailVerification().then((_) {
        emit(VerificationSendedState());
      }).catchError((error, stackTrace) {
        if (error is TooManyRequestException) {
          emit(TooManyRequestState());
        } else {
          emit(AuthErrorState(error: error));
        }
      });
    });
    on<SendPaswdResetEvent>((event, emit) async {
      emit(LoadingState());

      await CustomEmailAuthProvider()
          .sendPasswordReset(toEmail: event.email)
          .then((isSended) {
        if (isSended) {
          emit(PasswordResetSendedToEmailState());
        }
      }).catchError((error, stackTrace) {
        emit(AuthErrorState(
          error: error,
        ));
      });
    });
    on<UpdateNameEvent>((event, emit) async {
      emit(LoadingState());

      if (event.name.isNotEmpty) {
        await CustomEmailAuthProvider().updateName(event.name).then((value) {
          if (value) {
            emit(NameUpdatedState(newName: event.name));
          } else {
            emit(
              AuthUpdateErrorState(
                error: Exception(
                    "Something goes wrong, when trying to update name"),
              ),
            );
          }
        }).catchError((error, stackTrace) {
          if (error is RequiresRecentLoginException) {
            emit(AuthUpdateErrorState(error: error));
          }
        });
      }
    });
    on<UpdatePasswdEvent>((event, emit) async {
      emit(LoadingState());
      if (event.passwd.isNotEmpty) {
        await CustomEmailAuthProvider().updatePaswd(event.passwd).then((value) {
          if (value) {
            emit(PasswdUpdatedState());
            add(LogoutEvent());
          } else {
            emit(AuthUpdateErrorState(
              error:
                  Exception("Something goes wrong, when trying to update name"),
            ));
          }
        }).catchError((error, stackTrace) {
          if (error is WeakPasswordAuthException) {
            emit(AuthUpdateErrorState(error: WeakPasswordAuthException()));
            // emit();
          } else if (error is RequiresRecentLoginException) {
            emit(AuthUpdateErrorState(error: RequiresRecentLoginException()));
          } else {
            emit(AuthUpdateErrorState(
                error: GenericAuthException(cause: error)));
          }
        });
      } else {
        emit(
            AuthUpdateErrorState(error: Exception("User not gived something")));
      }
    });
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    super.onTransition(transition);
    String msg = """\n
   ○ Event:${transition.event}
  ═╦═   ${transition.currentState}
   ╚══► ${transition.nextState}
    """;
    log(msg, name: "${ansiGreen}Transition$ansiReset");
  }
}
