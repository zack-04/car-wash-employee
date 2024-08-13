import 'dart:convert';
import 'dart:developer';

import 'package:car_wash_employee/cores/model/assigned_car.dart';
import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/cores/widgets/custom_header.dart';
import 'package:car_wash_employee/cores/widgets/status_widget.dart';
import 'package:car_wash_employee/cores/widgets/today_detail_card.dart';
import 'package:car_wash_employee/features/pages/capture_selfie.dart';
import 'package:car_wash_employee/features/pages/login_page.dart';
import 'package:car_wash_employee/features/providers/car_id_provider.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool isLoading = true;
  List<AssignedCar> assignedCars = [];
  int firstPendingIndex = 0;
  String noOfCars = '';
  String startKm = '';
  String endKm = '';
  DateTime? firstCardTime;
  DateTime? lastCardTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(carProvider.notifier).checkDateAndClearCarId();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchAssignedCars();
    attendanceCheck();
  }

  Future<void> fetchAssignedCars() async {
    const url = 'https://wash.sortbe.com/API/Employee/Dashboard/Dashboard';

    final authState = ref.watch(authProvider);
    print('Employ - ${authState.employee!.id}');
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'enc_key': encKey,
          'emp_id': authState.employee!.id,
        },
      );

      var responseData = jsonDecode(response.body);
      print('Response - $responseData');

      if (responseData['status'] == 'Success') {
        var data = responseData['data'];
        print(data);
        if (data != null) {
          List<dynamic> assignedCarsJson = data['assigned_cars'] ?? [];

          if (mounted) {
            setState(() {
              assignedCars = List<AssignedCar>.from(
                  assignedCarsJson.map((x) => AssignedCar.fromJson(x)));
              firstPendingIndex = assignedCarsJson
                  .indexWhere((item) => item['wash_status'] == 'Pending');
              noOfCars = responseData['washed_car'];
              startKm = responseData['start_km'];
              endKm = responseData['end_km'];
            });
          }
        } else {
          throw Exception('Data field is null');
        }
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (e) {
      log('Error = $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> attendanceCheck() async {
    final authState = ref.watch(authProvider);
    // if (authState.hasCapturedSelfie) {
    //   print('Already captured');
    //   return;
    // }
    const url =
        'https://wash.sortbe.com/API/Employee/Attendance/Attendance-Check';

    print('Check - ${authState.employee!.id}');
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'enc_key': encKey,
          'emp_id': authState.employee!.id,
        },
      );

      final Map<String, dynamic> decodedJson = jsonDecode(response.body);
      print("Dash deco $decodedJson");
      print('Dash status -${decodedJson['status']}');

      if (decodedJson['status'] == 'Success') {
        print('Capture');
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const CaptureSelfiePage(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      log('Error = $e');
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTemplate.primaryClr,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  const CustomHeader(),
                  Positioned(
                    right: 0,
                    top: 13,
                    child: IconButton(
                      onPressed: () async {
                        ref.read(authProvider.notifier).logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      icon: Icon(
                        Icons.logout,
                        color: AppTemplate.primaryClr,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              firstPendingIndex == -1
                  ? Column(
                      children: [
                        SizedBox(height: 30.h),
                        StatusWidget(
                          totalCars: noOfCars,
                          startKm: startKm,
                          endKm: endKm,
                          time: (firstCardTime != null && lastCardTime != null)
                              ? formatDuration(
                                  lastCardTime!.difference(firstCardTime!))
                              : 'N/A',
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: isLoading
                          ? const Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                ),
                                Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Today's Wash",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                assignedCars.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: assignedCars.length,
                                        itemBuilder: (context, index) {
                                          return TodayDetailCard(
                                            assignedCar: assignedCars[index],
                                            isActive:
                                                index == firstPendingIndex &&
                                                    assignedCars[index]
                                                            .washStatus ==
                                                        'Pending',
                                            onClick: () {
                                              if (assignedCars[index]
                                                      .washStatus ==
                                                  'Pending') {
                                                if (firstCardTime == null) {
                                                  firstCardTime =
                                                      DateTime.now();
                                                }
                                                lastCardTime = DateTime.now();
                                              }
                                            },
                                          );
                                        },
                                      )
                                    : const Column(
                                        children: [
                                          SizedBox(
                                            height: 200,
                                          ),
                                          Center(
                                            child: Text(
                                              'No Assigned Cars',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
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
