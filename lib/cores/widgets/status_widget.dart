import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({
    super.key,
    required this.totalCars,
    required this.startKm,
    required this.endKm,
    required this.time,
  });
  final String totalCars;
  final String startKm;
  final String endKm;
  final String time;

  @override
  Widget build(BuildContext context) {
    final int startKmInt = int.tryParse(startKm) ?? 0;
    final int endKmInt = int.tryParse(endKm) ?? 0;
    final totalDistance = startKmInt + endKmInt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 80),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF001C63),
              borderRadius: BorderRadius.circular(20),
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Cars Cleaned',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTemplate.primaryClr,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      totalCars,
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: AppTemplate.primaryClr,
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'cars',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppTemplate.primaryClr,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                const Text(
                  'Total Hours Spent',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTemplate.primaryClr,
                  ),
                ),
                 Text(
                  time,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: AppTemplate.primaryClr,
                  ),
                ),
                SizedBox(height: 30.h),
                const Text(
                  'Total Distance Traveled',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTemplate.primaryClr,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${totalDistance}',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: AppTemplate.primaryClr,
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'kms',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppTemplate.primaryClr,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
