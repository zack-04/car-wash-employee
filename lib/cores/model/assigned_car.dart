// ignore_for_file: public_member_api_docs, sort_constructors_first

class AssignedCar {
  final String carId;
  final String washName;
  final String modelName;
  final String latitude;
  final String longitude;
  final String clientName;
  final String washRemarks;
  final String vehicleNo;
  final String vehicleImage;
  final String washStatus;

  AssignedCar({
    required this.carId,
    required this.washName,
    required this.modelName,
    required this.latitude,
    required this.longitude,
    required this.clientName,
    required this.washRemarks,
    required this.vehicleNo,
    required this.vehicleImage,
    required this.washStatus,
  });

  factory AssignedCar.fromJson(Map<String, dynamic> json) {
    return AssignedCar(
      carId: json['car_id'],
      washName: json['wash_name'],
      modelName: json['model_name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      clientName: json['client_name'],
      washRemarks: json['wash_remarks'],
      vehicleNo: json['vehicle_no'],
      vehicleImage: json['vehicle_img'],
      washStatus: json['wash_status'],
    );
  }
}
