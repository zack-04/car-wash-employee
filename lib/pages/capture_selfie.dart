import 'package:camera/camera.dart';
import 'package:car_wash_employee/pages/dashboard_page.dart';
import 'package:flutter/material.dart';

class CaptureSelfiePage extends StatefulWidget {
  const CaptureSelfiePage({super.key});

  @override
  State<CaptureSelfiePage> createState() => _CaptureSelfiePageState();
}

class _CaptureSelfiePageState extends State<CaptureSelfiePage> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras.last,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller?.initialize();
    await _initializeControllerFuture;
    setState(() {});
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: Camera is not initialized.');
      return;
    }

    try {
      final image = await _controller!.takePicture();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
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
