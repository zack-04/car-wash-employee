import 'dart:convert';

import 'package:car_wash_employee/cores/model/employee_model.dart';
import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/cores/widgets/button_widget.dart';
import 'package:car_wash_employee/cores/widgets/custom_textfield.dart';
import 'package:car_wash_employee/features/pages/dashboard_page.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController mob = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    var url = Uri.parse('https://wash.sortbe.com/API/Employee/Login/Login');
    var request = http.MultipartRequest('POST', url)
      ..fields['enc_key'] = encKey
      ..fields['mobile'] = mob.text
      ..fields['password'] = pass.text;

    try {
      var streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      var responseData = jsonDecode(response.body);

      if (responseData['status'] == 'Success') {
        final employee = Employee(
          empName: responseData['name'],
          id: responseData['emp_id'],
          profilePic: responseData['employee_pic'],
        );

        ref.read(authProvider.notifier).login(employee);
        print('Employee - ${employee.empName}');
        print('Employeeid - ${employee.id}');
        print('Employeepic - ${employee.profilePic}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['remarks']),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardPage(),
            ),
            (Route<dynamic> route) => false,
          );
          // await attendanceCheck();
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exception: $e')),
        );
      }
    }
  }

  // Future<void> attendanceCheck() async {
  //   const url =
  //       'https://wash.sortbe.com/API/Employee/Attendance/Attendance-Check';

  //   final authState = ref.watch(authProvider);
  //   print('Check - ${authState.employee!.id}');
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: {
  //         'enc_key': encKey,
  //         'emp_id': authState.employee!.id,
  //       },
  //     );

  //     final Map<String, dynamic> decodedJson = jsonDecode(response.body);
  //     print(" deco $decodedJson");
  //     print('sta -${decodedJson['status']}');

  //     if (decodedJson['status'] == 'Success') {
  //       print('Capture');
  //       if (mounted) {
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const CaptureSelfiePage(),
  //           ),
  //           (Route<dynamic> route) => false,
  //         );
  //       }
  //     } else {
  //       if (mounted) {
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const DashboardPage(),
  //           ),
  //           (Route<dynamic> route) => false,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     log('Error = $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            const SizedBox(
              height: double.infinity,
              width: double.infinity,
            ),
            Container(
              height: 0.6.sh,
              width: double.infinity,
              color: Colors.blue,
              child: Image.asset(
                'assets/login_banner.png',
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              bottom: 0.h,
              left: 0.w,
              right: 0.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 35.w, vertical: 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          "Please Login to continue with your account",
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Textfieldwidget(
                          controller: mob,
                          labelTxt: "Mobile Number",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatter: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          labelTxtClr: const Color(0xFF929292),
                          enabledBorderClr: const Color(0xFFD4D4D4),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            if (value.length != 10) {
                              return 'Mobile number must be 10 digits';
                            }
                            final RegExp regex = RegExp(r'^\d{10}$');
                            if (!regex.hasMatch(value)) {
                              return 'Enter valid mobile number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Textfieldwidget(
                          controller: pass,
                          labelTxt: "Password",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          labelTxtClr: const Color(0xFF929292),
                          enabledBorderClr: const Color(0xFFD4D4D4),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }

                            return null;
                          },
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Buttonwidget(
                            width: double.infinity,
                            height: 50.h,
                            buttonClr: const Color(0xFf1E3763),
                            txt: 'Log in',
                            textClr: AppTemplate.primaryClr,
                            textSz: 18.sp,
                            onClick: () async {
                              FocusScope.of(context).unfocus();
                              await login();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Center(
                          child: Text(
                            "Authorized Access Only",
                            style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppTemplate.textClr,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
