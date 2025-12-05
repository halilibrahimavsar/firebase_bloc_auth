import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaitALittlePage extends StatefulWidget {
  const WaitALittlePage({super.key});

  @override
  WaitALittlePageState createState() => WaitALittlePageState();
}

class WaitALittlePageState extends State<WaitALittlePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(RemainingTimeEvent(totalSecToWait: 180));
  }

  String getFormattedTime(int seconds) {
    // Convert remaining seconds into mm:ss format
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    String secondsStr =
        (remainingSeconds < 10) ? '0$remainingSeconds' : '$remainingSeconds';
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    int sec = 0;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: const Text('Countdown Timer'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Time Remaining:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is RemainingTimeState) {
                    if (state.remainSec == 0) {
                      Navigator.pop(context);
                    }
                    sec = state.remainSec;
                  }
                },
                builder: (context, state) {
                  return Text(
                    getFormattedTime(sec),
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
