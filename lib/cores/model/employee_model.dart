class Employee {
  final String empName;
  final String id;
  final String profilePic;

  Employee({
    required this.empName,
    required this.id,
    required this.profilePic,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empName: json['name'],
      id: json['emp_id'],
      profilePic: json['employee_pic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': empName,
      'emp_id': id,
      'employee_pic': profilePic,
    };
  }
}
