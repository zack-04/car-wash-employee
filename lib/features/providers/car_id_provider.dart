import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarState {
  final String? carId;

  CarState({this.carId});
}

class CarNotifier extends StateNotifier<CarState> {
  CarNotifier() : super(CarState()) {
    // loadCarState();
  }

  Future<void> checkDateAndClearCarId() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSavedDate = prefs.getString('savedDate');
    final currentDate = DateTime.now().toIso8601String().split('T').first;

    if (lastSavedDate != currentDate) {
      await clearCarId();
      await prefs.setString('savedDate', currentDate);
    } else {
      await loadCarState();
    }
  }

  Future<void> loadCarState() async {
    final prefs = await SharedPreferences.getInstance();
    final carId = prefs.getString('carId');
    state = CarState(carId: carId);
    print('Loaded carId: ${state.carId}');
  }

  Future<void> setCarId(String carId) async {
    state = CarState(carId: carId);
    final prefs = await SharedPreferences.getInstance();
    final currentDate = DateTime.now().toIso8601String().split('T').first;
    await prefs.setString('carId', carId);
    await prefs.setString('savedDate', currentDate);
    print('Set carId: ${state.carId}');
  }

  Future<void> clearCarId() async {
    state = CarState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('carId');
    print('Cleared carId: ${state.carId}');
  }
}

final carProvider = StateNotifierProvider<CarNotifier, CarState>((ref) {
  return CarNotifier();
});
