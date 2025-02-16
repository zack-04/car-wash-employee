import 'dart:convert';
import 'dart:developer';
import 'package:car_wash_employee/cores/model/assigned_car.dart';
import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/cores/widgets/custom_header.dart';
import 'package:car_wash_employee/cores/widgets/status_widget.dart';
import 'package:car_wash_employee/cores/widgets/today_detail_card.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchAssignedCars();
  }

  Future<void> fetchAssignedCars() async {
    const url = 'https://wash.sortbe.com/API/Employee/Dashboard/Dashboard';

    final authState = ref.watch(authProvider);
    print(authState.employee!.id);
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

          setState(() {
            assignedCars = List<AssignedCar>.from(
                assignedCarsJson.map((x) => AssignedCar.fromJson(x)));
            firstPendingIndex = assignedCarsJson
                .indexWhere((item) => item['wash_status'] == 'Pending');
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTemplate.primaryClr,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomHeader(),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: Container(
              //     height: 20,
              //     width: 100,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       // color: const Color(0xFF021649),
              //       gradient: RadialGradient(
              //         colors: const [
              //           Color.fromARGB(255, 0, 52, 182),
              //           AppTemplate.bgClr,
              //           // AppTemplate.bgClr,
              //           // AppTemplate.bgClr,
              //           // AppTemplate.bgClr
              //         ],
              //         focal: Alignment(0.8.w, 0.4.h),
              //         radius: 6.r,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: 20.h),
              firstPendingIndex == -1
                  ? Column(
                      children: [
                        SizedBox(height: 30.h),
                        StatusWidget(),
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
