import 'dart:convert';

import 'package:car_wash_employee/cores/model/employee_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final Employee? employee;
  final bool isLoggedIn;
  final bool hasCapturedSelfie;

  AuthState({
    this.employee,
    this.isLoggedIn = false,
    this.hasCapturedSelfie = false,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeJson = prefs.getString('employee');
    final hasCapturedSelfie = prefs.getBool('hasCapturedSelfie') ?? false;
    if (employeeJson != null) {
      final Map<String, dynamic> data = jsonDecode(employeeJson);
      final employee = Employee.fromJson(data);
      state = AuthState(employee: employee, isLoggedIn: true,hasCapturedSelfie: hasCapturedSelfie);
    }
  }

  Future<void> login(Employee employee) async {
    state = AuthState(employee: employee, isLoggedIn: true);
    final prefs = await SharedPreferences.getInstance();
    final employeeJson = jsonEncode(employee.toJson());
    await prefs.setString('employee', employeeJson);
  }

  Future<void> logout() async {
    state = AuthState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('employee');
    await prefs.remove('hasCapturedSelfie');
  }
  Future<void> setHasCapturedSelfie(bool value) async {
    state = AuthState(employee: state.employee, isLoggedIn: state.isLoggedIn, hasCapturedSelfie: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCapturedSelfie', value);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
