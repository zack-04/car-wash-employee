import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:car_wash_employee/cores/model/assigned_car.dart';
import 'package:car_wash_employee/cores/model/wash_response.dart';
import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/cores/utils/countdown_timer.dart';
import 'package:car_wash_employee/cores/widgets/button_widget.dart';
import 'package:car_wash_employee/cores/widgets/custom_header.dart';
import 'package:car_wash_employee/cores/widgets/user_detail_card.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:car_wash_employee/features/washes/pressure_wash/pressure_after_wash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class PressureWashTimerPage extends ConsumerStatefulWidget {
  const PressureWashTimerPage({
    super.key,
    required this.assignedCar,
    required this.midViews,
    required this.timer,
    required this.afterViews,
  });
  final AssignedCar assignedCar;
  final List<Views> midViews;
  final int timer;
  final List<Views> afterViews;

  @override
  ConsumerState<PressureWashTimerPage> createState() =>
      _PressureWashTimerPageState();
}

class _PressureWashTimerPageState extends ConsumerState<PressureWashTimerPage>
    with WidgetsBindingObserver {
  late int countdownSeconds;
  late CountdownTimer countdownTimer;
  bool isTimerRunning = false;
  bool isTimerFinished = false;
  bool isLoading = false;
  bool isDisabled = false;

  @override
  void initState() {
    super.initState();
    countdownSeconds = 30;
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
          setState(() {
            isTimerFinished = true;
          });
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => PressureAfterWashPage(
          //       assignedCar: widget.assignedCar,
          //       afterViews: widget.afterViews,
          //     ),
          //   ),
          // );
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

  int _currentIndex = 0;
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  Color getButtonColor() {
    if (_currentIndex < widget.midViews.length - 1) {
      return const Color(0xFf1E3763);
    } else if (_capturedImage == null) {
      return const Color(0xFf1E3763);
    } else if (isTimerFinished) {
      return const Color(0xFf1E3763);
    } else {
      return Colors.grey.shade300;
    }
  }

  String getButtonText() {
    if (isLoading) {
      return '';
    } else if (_currentIndex < widget.midViews.length - 1) {
      return 'Next View';
    } else if (_capturedImage == null) {
      return 'Next View';
    } else {
      return 'Submit Wash';
    }
  }

  Future<void> carWashPhoto(String empId, String encKey, File image) async {
    var url = Uri.parse(
        'https://wash.sortbe.com/API/Employee/Dashboard/Carwash-Photo');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url)
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId
      ..fields['car_id'] = widget.assignedCar.carId
      ..fields['view_id'] = widget.midViews[_currentIndex].viewId
      ..fields['last_photo'] = '0'
      ..files.add(
        await http.MultipartFile.fromPath(
          'wash_photo',
          image.path,
          contentType: MediaType('image', 'jpg'),
        ),
      );
    print('Id = ${widget.midViews[_currentIndex].viewId}');
    dynamic streamedResponse;

    // Send request
    try {
      streamedResponse = await request.send();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('responseCode = ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = jsonDecode(response.body);

    if (responseData['status'] == 'Success') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['remarks']),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['remarks']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
      });
    }
  }

  void _nextView() async {
    // if (isDisabled) {
    //   return;
    // }
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
      return;
    }

    setState(() {
      isLoading = true;
    });

    final authState = ref.watch(authProvider);
    print('Employee = ${authState.employee!.id}');
    await carWashPhoto(authState.employee!.id, encKey, _capturedImage!);
    print('Captured image = $_capturedImage');

    if (_currentIndex < widget.midViews.length - 1) {
      setState(() {
        _currentIndex++;
        _capturedImage = null;
        isLoading = false;
      });
    } else {
      if (isTimerFinished) {
        setState(() {
          isDisabled = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PressureAfterWashPage(
              assignedCar: widget.assignedCar,
              afterViews: widget.afterViews,
            ),
          ),
        );
        setState(() {
          isLoading = false;
        });
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
                                    widget.midViews[_currentIndex].viewName,
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Buttonwidget(
                            width: double.infinity,
                            height: 50.h,
                            buttonClr: getButtonColor(),
                            txt: getButtonText(),
                            textClr: AppTemplate.primaryClr,
                            textSz: 18.sp,
                            onClick: _nextView,
                          ),
                          if (isLoading)
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                        ],
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
