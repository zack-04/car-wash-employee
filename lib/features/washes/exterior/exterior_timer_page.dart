import 'dart:async';

import 'package:car_wash_employee/cores/model/assigned_car.dart';
import 'package:car_wash_employee/cores/model/wash_response.dart';
import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/cores/utils/countdown_timer.dart';
import 'package:car_wash_employee/cores/widgets/custom_header.dart';
import 'package:car_wash_employee/cores/widgets/user_detail_card.dart';
import 'package:car_wash_employee/features/washes/exterior/exterior_after_wash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExteriorTimerPage extends StatefulWidget {
  const ExteriorTimerPage({
    super.key,
    required this.assignedCar,
    required this.timer,
    required this.afterViews,
  });
  final AssignedCar assignedCar;
  final int timer;
  final List<Views> afterViews;

  @override
  State<ExteriorTimerPage> createState() => _ExteriorTimerPageState();
}

class _ExteriorTimerPageState extends State<ExteriorTimerPage>
    with WidgetsBindingObserver {
  late int countdownSeconds;
  late CountdownTimer countdownTimer;
  bool isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    countdownSeconds = widget.timer * 60;
    print('count = $countdownSeconds');
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
              builder: (context) => ExteriorAfterWashPage(
                assignedCar: widget.assignedCar,
                afterViews: widget.afterViews,
              ),
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
              const CustomHeader(),
              SizedBox(height: 30.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserDetailCard(
                      assignedCar: widget.assignedCar,
                    ),
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
