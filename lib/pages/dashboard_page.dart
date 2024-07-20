import 'package:car_wash_employee/cores/constants/constants.dart';
import 'package:car_wash_employee/cores/widgets/today_detail_card.dart';
import 'package:car_wash_employee/cores/widgets/header_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTemplate.primaryClr,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderContainer(),
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
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
                    const TodayDetailCard(bgColor: AppTemplate.primaryClr),
                    const TodayDetailCard(
                      bgColor: Color(0xFFD4D4D4),
                    ),
                    const TodayDetailCard(
                      bgColor: Color(0xFFD4D4D4),
                    ),
                    const TodayDetailCard(
                      bgColor: Color(0xFFD4D4D4),
                    ),
                    const TodayDetailCard(
                      bgColor: Color(0xFFD4D4D4),
                    ),
                    const TodayDetailCard(
                      bgColor: Color(0xFFD4D4D4),
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
