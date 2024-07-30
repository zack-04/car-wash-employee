import 'dart:convert';
import 'dart:io';

import 'package:car_wash_employee/cores/model/assigned_car.dart';
import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/cores/widgets/button_widget.dart';
import 'package:car_wash_employee/cores/widgets/user_detail_card.dart';
import 'package:car_wash_employee/features/pages/dashboard_page.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

List<String> list = <String>[
  'Cars Not Available',
  'Maintenance Required',
  'Three',
  'Four'
];

class CancellationPage extends ConsumerStatefulWidget {
  const CancellationPage({super.key, required this.assignedCar});
  final AssignedCar assignedCar;

  @override
  ConsumerState<CancellationPage> createState() => _CancellationPageState();
}

class _CancellationPageState extends ConsumerState<CancellationPage> {
  String _selectedReason = '';
  String dropdownValue = list.first;
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> cancelCar(String empId, String encKey, File image) async {
    var url = Uri.parse(
        'https://wash.sortbe.com/API/Employee/Dashboard/Carwash-Cancel');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url)
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId
      ..fields['car_id'] = widget.assignedCar.carId
      ..fields['cancel_reason'] = _selectedReason
      ..files.add(
        await http.MultipartFile.fromPath(
          'car_photo',
          image.path,
          contentType: MediaType('image', 'jpg'),
        ),
      );
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
    } else {
      final authState = ref.watch(authProvider);
      print('Employee = ${authState.employee!.id}');
      await cancelCar(authState.employee!.id, encKey, _capturedImage!);
      print('Captured image = $_capturedImage');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(),
        ),
        (Route<dynamic> route) => false,
      );
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
                    focal: Alignment(0.8.w, -0.1.h),
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
                    SizedBox(height: 20.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Cancellation',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        labelStyle: const TextStyle(
                          color: Color(0xFF929292),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0xFFD4D4D4),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0xFFD4D4D4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: list.map(
                        (String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        _selectedReason = value!;
                      },
                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
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
                                  const Text(
                                    'Capture Photo',
                                    style: TextStyle(
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
                        txt: 'Submit',
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
