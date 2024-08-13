import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:car_wash_employee/cores/model/assigned_car.dart';
import 'package:car_wash_employee/cores/model/wash_response.dart';
import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/cores/widgets/button_widget.dart';
import 'package:car_wash_employee/cores/widgets/user_detail_card.dart';
import 'package:car_wash_employee/features/pages/cancellation_page.dart';
import 'package:car_wash_employee/features/providers/car_id_provider.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:car_wash_employee/features/washes/exterior/exterior_timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ExteriorBeforeWashPage extends ConsumerStatefulWidget {
  const ExteriorBeforeWashPage({
    super.key,
    required this.assignedCar,
    required this.washResponse,
  });
  final AssignedCar assignedCar;
  final WashResponse washResponse;

  @override
  ConsumerState<ExteriorBeforeWashPage> createState() =>
      _ExteriorBeforeWashPageState();
}

class _ExteriorBeforeWashPageState
    extends ConsumerState<ExteriorBeforeWashPage> {
  int _currentIndex = 0;
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  List<Views> beforeViews = [];
  List<Views> afterViews = [];
  int timerValue = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    handleResponse(widget.washResponse);
    ref.read(carProvider.notifier).checkDateAndClearCarId();
  }

  void handleResponse(WashResponse response) {
    Pattern pattern2 = response.data[0];
    List<Views> allViews = pattern2.views;

    setState(() {
      beforeViews = allViews.take(1).toList();
      afterViews = allViews.skip(1).take(8).toList();
      timerValue = pattern2.timer;
    });
    print('Before = ${beforeViews}');
    print('Timer = $timerValue');
  }

  Future<void> distance() async {
    const url = 'https://wash.sortbe.com/API/Employee/Distance/Distance';

    final authState = ref.watch(authProvider);
    final previousCarId = ref.watch(carProvider);
    if (previousCarId.carId == null) {
      return;
    }
    print('Previous car id - ${previousCarId.carId}');
    print('current car id - ${widget.assignedCar.carId}');
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'enc_key': encKey,
          'emp_id': authState.employee!.id,
          'previous_car': previousCarId.carId,
          'current_car': widget.assignedCar.carId,
        },
      );

      final Map<String, dynamic> decodedJson = jsonDecode(response.body);
      print(" deco $decodedJson");

      print('sta -${decodedJson['status']}');

      if (decodedJson['status'] == 'Success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(decodedJson['remarks']),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (e) {
      log('Error = $e');
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
      ..fields['view_id'] = beforeViews[_currentIndex].viewId
      ..fields['last_photo'] = '0'
      ..files.add(
        await http.MultipartFile.fromPath(
          'wash_photo',
          image.path,
          contentType: MediaType('image', 'jpg'),
        ),
      );
    print('Id = ${beforeViews[_currentIndex].viewId}');
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
    if (_currentIndex == 0) {
      await distance();
    }

    if (_currentIndex < beforeViews.length - 1) {
      setState(() {
        _currentIndex++;
        _capturedImage = null;
        isLoading = false;
      });
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ExteriorTimerPage(
            assignedCar: widget.assignedCar,
            afterViews: afterViews,
            timer: timerValue,
          ),
        ),
        (Route<dynamic> route) => false,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppTemplate.primaryClr,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF021649),
                  gradient: RadialGradient(
                    colors: const [
                      Color.fromARGB(255, 0, 52, 182),
                      AppTemplate.bgClr,
                      AppTemplate.bgClr,
                      AppTemplate.bgClr,
                      AppTemplate.bgClr
                    ],
                    focal: Alignment(0.8.w, 1.h),
                    radius: 3.r,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: 5,
                    right: 20,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 40,
                          color: AppTemplate.primaryClr,
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            const AssetImage('assets/noavatar.png'),
                        child: ClipOval(
                          child: Image.network(
                            authState.employee!.profilePic,
                            fit: BoxFit.cover,
                            width: 100.r,
                            height: 100.r,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/noavatar.png',
                                fit: BoxFit.cover,
                                width: 100.r,
                                height: 100.r,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Text(
                        'Hi ${authState.employee!.empName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CancellationPage(
                                assignedCar: widget.assignedCar,
                              ),
                            ),
                          );
                        },
                        child: SvgPicture.asset('assets/icons/car_icon.svg'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    UserDetailCard(
                      assignedCar: widget.assignedCar,
                    ),
                    SizedBox(height: 30.h),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Before Wash',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    GestureDetector(
                      onTap: _captureImage,
                      child: Container(
                        height: 250.h,
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
                                    beforeViews[_currentIndex].viewName,
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
                            buttonClr: const Color(0xFf1E3763),
                            txt: isLoading
                                ? ''
                                : _capturedImage == null
                                    ? 'Next View'
                                    : 'Start Cleaning',
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
