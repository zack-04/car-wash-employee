import 'dart:io';

import 'package:car_wash_employee/cores/constants/constants.dart';
import 'package:car_wash_employee/cores/widgets/button_widget.dart';
import 'package:car_wash_employee/cores/widgets/user_detail_card.dart';
import 'package:car_wash_employee/pages/dashboard_page.dart';
import 'package:car_wash_employee/pages/status_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class InteriorAfterWashPage extends StatefulWidget {
  const InteriorAfterWashPage({super.key});

  @override
  State<InteriorAfterWashPage> createState() => _InteriorAfterWashPageState();
}

class _InteriorAfterWashPageState extends State<InteriorAfterWashPage> {
  final List<String> _views = [
    'Front View',
    'Left Side View',
    'Right Side View',
    'Back Side View',
    'Front Left Wheel',
    'Front Right Wheel',
    'Rear Left Wheel',
    'Rear Right Wheel',
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const StatusPage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
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
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardPage(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(
                            Icons.chevron_left,
                            size: 40,
                            color: AppTemplate.primaryClr,
                          ),
                        ),
                        const CircleAvatar(
                          radius: 22,
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
                    children: [
                      const UserDetailCard(),
                      SizedBox(height: 30.h),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'After Wash',
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
                          buttonClr: const Color(0xFf1E3763),
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
      ),
    );
  }
}
