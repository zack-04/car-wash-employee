import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:car_wash_employee/features/pages/dashboard_page.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';

class CaptureSelfiePage extends ConsumerStatefulWidget {
  const CaptureSelfiePage({
    super.key,
  });

  @override
  ConsumerState<CaptureSelfiePage> createState() => _CaptureSelfiePageState();
}

class _CaptureSelfiePageState extends ConsumerState<CaptureSelfiePage> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitializeCamera();
  }

  Future<void> _checkPermissionsAndInitializeCamera() async {
    // Check for camera permissions
    if (await Permission.camera.request().isGranted) {
      await _initializeCamera();
    } else {
      // Handle permission denial
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera permission is required to capture attendance.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Future<void> _initializeCamera() async {
    try {

      // Initialize camera
      _cameras = await availableCameras();
      _controller = CameraController(
        _cameras.last,
        ResolutionPreset.medium,
        enableAudio: false,
      );
       _initializeControllerFuture = _controller?.initialize();
      print('Initial = $_initializeControllerFuture');
      await _initializeControllerFuture;
      setState(() {
        
      });
    } catch (e) {
      log('Camera initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> captureAttendance(
      String empId, String encKey, XFile image) async {
    var url = Uri.parse(
        'https://wash.sortbe.com/API/Employee/Attendance/Attendance-Capture');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url)
      ..fields['enc_key'] = 'C0oRAe1QNtn3zYNvJ8rv'
      ..fields['emp_id'] = empId
      ..files.add(
        await http.MultipartFile.fromPath(
          'attendance_photo',
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
          // (Route<dynamic> route) => false,
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

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      log('Error: Camera is not initialized.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Camera is not initialized.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final image = await _controller!.takePicture();
      final authState = ref.watch(authProvider);
      print('Employee = ${authState.employee!.id}');
      await captureAttendance(
          authState.employee!.id, 'C0oRAe1QNtn3zYNvJ8rv', image);
      ref.read(authProvider.notifier).setHasCapturedSelfie(true);
    } catch (e) {
      log('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                SizedBox(
                  height: 0.7.sh,
                  width: MediaQuery.of(context).size.width,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                            width: 4,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(7),
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    const Text(
                      'ATTENDANCE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    const Text(
                      "Capture your photo to mark\nyour today's attendance",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
