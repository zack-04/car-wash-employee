import 'dart:async';
import 'dart:io';

import 'package:car_wash_employee/cores/constants/constants.dart';
import 'package:car_wash_employee/cores/utils/countdown_timer.dart';
import 'package:car_wash_employee/cores/widgets/button_widget.dart';
import 'package:car_wash_employee/cores/widgets/user_detail_card.dart';
import 'package:car_wash_employee/washes/pressure_wash/pressure_after_wash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class PressureWashTimerPage extends StatefulWidget {
  const PressureWashTimerPage({super.key});

  @override
  State<PressureWashTimerPage> createState() => _PressureWashTimerPageState();
}

class _PressureWashTimerPageState extends State<PressureWashTimerPage>
    with WidgetsBindingObserver {
  int countdownSeconds = 30;
  late CountdownTimer countdownTimer;
  bool isTimerRunning = false;
  bool isTimerFinished = false;

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
          setState(() {
            isTimerFinished = true;
          });
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
    countdownTimer.stop();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$remainingSeconds';
  }

  final List<String> _views = [
    'Foam View',
    'Sprayed Water Front View',
  ];

  int _currentIndex = 0;
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
      });
    }
  }

  void _nextView() {
    if (_capturedImage == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Image Captured'),
            content: const Text('Please capture an image before proceeding.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (_currentIndex < _views.length - 1) {
      setState(() {
        _currentIndex++;
        _capturedImage = null;
      });
    } else {
      if (isTimerFinished) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PressureAfterWashPage(),
          ),
        );
      }
    }
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
                    SizedBox(height: 20.h),
                    Text(
                      _formatTime(countdownSeconds),
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001C63),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: _captureImage,
                      child: Container(
                        height: 220.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFCCC3E5),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              offset: Offset(2, 4),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                          image: _capturedImage != null
                              ? DecorationImage(
                                  image: FileImage(_capturedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _capturedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/camera.png'),
                                  SizedBox(height: 15.h),
                                  Text(
                                    _views[_currentIndex],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6750A4),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Buttonwidget(
                        width: double.infinity,
                        height: 50.h,
                        buttonClr: _currentIndex < _views.length - 1
                            ? const Color(0xFf1E3763)
                            : _capturedImage == null
                                ? const Color(0xFf1E3763)
                                : isTimerFinished
                                    ? const Color(0xFf1E3763)
                                    : Colors.grey,
                        txt: _currentIndex < _views.length - 1
                            ? 'Next View'
                            : _capturedImage == null
                                ? 'Next View'
                                : 'Submit Wash',
                        textClr: AppTemplate.primaryClr,
                        textSz: 18.sp,
                        onClick: _nextView,
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
