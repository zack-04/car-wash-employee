import 'package:car_wash_employee/features/pages/dashboard_page.dart';
import 'package:car_wash_employee/features/pages/login_page.dart';
import 'package:car_wash_employee/features/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, child) {
        Widget home;
        if (!authState.isLoggedIn) {
          home = const LoginPage();
        } else {
          print("Navigating Dashboard");
          home = const DashboardPage();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: home,
        );
      },
    );
  }
}
