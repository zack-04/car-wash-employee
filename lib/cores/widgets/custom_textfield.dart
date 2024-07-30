import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Textfieldwidget extends StatelessWidget {
  final String labelTxt;
  final Color labelTxtClr;
  final Color enabledBorderClr;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatter;
  final AutovalidateMode autovalidateMode;
  const Textfieldwidget({
    super.key,
    required this.labelTxt,
    required this.labelTxtClr,
    required this.enabledBorderClr,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.inputFormatter,
    required this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: autovalidateMode,
      inputFormatters: inputFormatter,
      cursorColor: AppTemplate.enabledBorderClr,
      decoration: InputDecoration(
        labelText: labelTxt,
        labelStyle: GoogleFonts.inter(
            fontSize: 12.sp, color: labelTxtClr, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: BorderSide(color: AppTemplate.shadowClr, width: 1.5.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: BorderSide(color: AppTemplate.shadowClr, width: 1.5.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: BorderSide(color: const Color(0xFFD4D4D4), width: 1.5.w),
        ),
      ),
    );
  }
}
