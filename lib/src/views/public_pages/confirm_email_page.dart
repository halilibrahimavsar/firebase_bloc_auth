// import 'dart:async';
// import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ConfirmEmailPage extends StatefulWidget {
//   const ConfirmEmailPage({super.key});

//   @override
//   State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
// }

// class _ConfirmEmailPageState extends State<ConfirmEmailPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   late Timer _timer;
//   int _timerDuration = 20; // Timer duration in seconds
//   bool _isTimerRunning = false;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//     _controller.forward();

//     // Start the timer when the widget is initialized
//     startTimer();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _timer.cancel(); // Cancel the timer to prevent memory leaks
//     super.dispose();
//   }

//   // Method to start the timer
//   void startTimer() {
//     context.read<AuthBloc>().add(SendVerificationToEmailEvent());

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_timerDuration > 0) {
//           _timerDuration--;
//         } else {
//           _isTimerRunning = false;
//           _timer.cancel();
//         }
//       });
//     });
//     _isTimerRunning = true;
//   }

//   // Method to handle resend button press
//   void handleResend() {
//     if (!_isTimerRunning) {
//       // Reset the timer duration and start the timer again
//       _timerDuration = 20;
//       startTimer();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Confirm Email"),
//       ),
//       body: FadeTransition(
//         opacity: _animation,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               "To confirm your email address, a verification link has been sent to your email.",
//               style: TextStyle(
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: _isTimerRunning ? null : handleResend,
//               child: Text(_isTimerRunning
//                   ? "Resend in $_timerDuration seconds"
//                   : "Resend Verification Email"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
