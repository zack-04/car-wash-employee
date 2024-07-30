import 'package:car_wash_employee/cores/utils/constants.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHeader extends ConsumerWidget {
  const CustomHeader({
    super.key,
    this.showBack = false,
  });
  final bool showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Stack(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          color: const Color(0xFF021649),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 0,
              bottom: 0,
              left: 5,
              right: 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                showBack
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 40,
                          color: AppTemplate.primaryClr,
                        ),
                      )
                    : const SizedBox(
                        width: 20,
                      ),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: const AssetImage('assets/noavatar.png'),
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
                Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Text(
                    'Hi ${authState.employee!.empName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: -50,
          child: Container(
            height: 300,
            width: 100,
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
                focal: Alignment(0.8.w, 0.4.h),
                radius: 3.r,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
