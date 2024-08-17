import 'dart:convert';
import 'dart:io';

import 'package:car_wash_employee/cores/model/assigned_car.dart';
import 'package:car_wash_employee/cores/model/wash_response.dart';
import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/cores/widgets/button_widget.dart';
import 'package:car_wash_employee/cores/widgets/user_detail_card.dart';
import 'package:car_wash_employee/features/pages/dashboard_page.dart';
import 'package:car_wash_employee/features/pages/status_page.dart';
import 'package:car_wash_employee/features/providers/car_id_provider.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:car_wash_employee/features/washes/pressure_wash/pressure_before_wash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InteriorAfterWashPage extends ConsumerStatefulWidget {
  const InteriorAfterWashPage({
    super.key,
    required this.assignedCar,
    required this.washResponse,
  });
  final AssignedCar assignedCar;
  final WashResponse washResponse;

  @override
  ConsumerState<InteriorAfterWashPage> createState() =>
      _InteriorAfterWashPageState();
}

class _InteriorAfterWashPageState extends ConsumerState<InteriorAfterWashPage> {
  int _currentIndex = 0;
  File? _capturedImage;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  WashResponse? washResponse;
  List<Views> afterViews = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStoredResponse();
  }

  Future<void> _loadStoredResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final responseString = prefs.getString('washResponse');

    if (responseString != null) {
      final decodedJson = jsonDecode(responseString);
      final response = WashResponse.fromJson(decodedJson);

      setState(() {
        washResponse = response;
        handleResponse(washResponse!);
      });
      final storedIndex = prefs.getInt('intAftercurrentIndex') ?? 0;
      if (storedIndex < afterViews.length) {
        setState(() {
          _currentIndex = storedIndex;
        });
      } else {
        setState(() {
          _currentIndex = afterViews.length - 1;
        });
      }
    } else {
      print('No stored response found.');
    }
  }

  void handleResponse(WashResponse response) {
    Pattern pattern1 = response.data[0];
    List<Views> allViews = pattern1.views;

    setState(() {
      afterViews = allViews.skip(8).take(8).toList();
    });
  }

  Future<void> carWashPhoto(String empId, String encKey, File image) async {
    var url = Uri.parse(
        'https://wash.sortbe.com/API/Employee/Dashboard/Carwash-Photo');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url)
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId
      ..fields['car_id'] = widget.assignedCar.carId
      ..fields['view_id'] = afterViews[_currentIndex].viewId
      ..fields['last_photo'] = _currentIndex < afterViews.length - 1 ||
              widget.assignedCar.washName == pressureWashWithInterior
          ? '0'
          : '1'
      ..files.add(
        await http.MultipartFile.fromPath(
          'wash_photo',
          image.path,
          contentType: MediaType('image', 'jpg'),
        ),
      );
    print('Id = ${afterViews[_currentIndex].viewId}');
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('intAftercurrentIndex', _currentIndex + 1);
    print('index = ${_currentIndex}');

    if (_currentIndex < afterViews.length - 1) {
      setState(() {
        _currentIndex++;
        _capturedImage = null;
        isLoading = false;
      });
    } else {
      if (widget.assignedCar.washName == pressureWashWithInterior) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => PressureBeforeWashPage(
              assignedCar: widget.assignedCar,
              washResponse: widget.washResponse,
            ),
          ),
          (route) => false,
        );
      } else {
        await prefs.remove('currentIndex');
        await prefs.remove('intAftercurrentIndex');
        await prefs.remove('hasCompletedPhotos');
        await prefs.remove('washResponse');
        await prefs.remove('timerCompleted');
        await ref.read(carProvider.notifier).setCarId(widget.assignedCar.carId);
        DateTime lastCardTime = DateTime.now();
        print('Last Card Time: $lastCardTime');

        await prefs.setString('lastCardTime', lastCardTime.toIso8601String());
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
          (route) => false,
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
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
                      washResponse == null
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : GestureDetector(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/camera.png'),
                                          SizedBox(height: 15.h),
                                          Text(
                                            afterViews[_currentIndex].viewName,
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
                                  : _currentIndex < afterViews.length - 1
                                      ? 'Next View'
                                      : _capturedImage == null
                                          ? 'Next View'
                                          : 'Submit Wash',
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
      ),
    );
  }
}
