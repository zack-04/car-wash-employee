import 'dart:async';

import 'package:car_wash_employee/cores/constants/constants.dart';
import 'package:car_wash_employee/cores/utils/countdown_timer.dart';
import 'package:car_wash_employee/cores/widgets/user_detail_card.dart';
import 'package:car_wash_employee/washes/interior/interior_after_wash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InteriorTimerPage extends StatefulWidget {
  const InteriorTimerPage({super.key});

  @override
  State<InteriorTimerPage> createState() => _InteriorTimerPageState();
}

class _InteriorTimerPageState extends State<InteriorTimerPage>
    with WidgetsBindingObserver {
  int countdownSeconds = 600;
  late CountdownTimer countdownTimer;
  bool isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    initTimerOperation();
  }

  void initTimerOperation() {
    //timer callbacks
    countdownTimer = CountdownTimer(
      seconds: countdownSeconds,
      onTick: (seconds) {
        if (mounted) {
          setState(() {
            countdownSeconds = seconds;
            isTimerRunning = true;
          });
        }
      },
      onFinished: () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InteriorAfterWashPage(),
            ),
          );
        }
      },
    );

    //native app life cycle
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (!mounted) return Future.value(null);

      if (msg == AppLifecycleState.paused.toString()) {
        if (isTimerRunning) {
          countdownTimer.pause(countdownSeconds);
        }
      } else if (msg == AppLifecycleState.resumed.toString()) {
        if (isTimerRunning) {
          countdownTimer.resume();
        }
      }

      return Future.value(null);
    });
    isTimerRunning = true;
    countdownTimer.start();
  }

  @override
  void dispose() {
    countdownTimer.stop(); // Ensure to dispose of the timer
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTemplate.primaryClr,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                color: const Color(0xFF021649),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
                      SizedBox(width: 15.w),
                      const Text(
                        'Hi Moideen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const UserDetailCard(),
                    SizedBox(height: 150.h),
                    Text(
                      _formatTime(countdownSeconds),
                      style: TextStyle(
                        fontSize: 80.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001C63),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
