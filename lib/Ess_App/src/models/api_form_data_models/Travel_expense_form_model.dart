// lib/Ess_App/src/models/api_response_models/travel_form_model.dart
//
// Model for: GET /get_travel_form.php?emp_code=XXXXXXX
// Adjust the file location / package path to match where your other
// api_response_models live in your project.

class TravelFormModel {
  final bool status;
  final String message;
  final TravelFormData? data;

  TravelFormModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory TravelFormModel.fromJson(Map<String, dynamic> json) {
    return TravelFormModel(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? TravelFormData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TravelFormData {
  final String code;
  final String name;
  final String email;
  final String designation;
  final String grades;
  final String department;
  final String branch;
  final String branchCode;
  final String mobile;
  final String role;
  final String managerId;
  final String hodId;

  // Entitlements
  final double kmRate;
  final double da;
  final double nightstay;
  final double kmLtr;
  final double maxKm;
  final double mobileLimit;
  final double entertainmentLimit;
  final double bikeLimit;
  final double courierLimit;
  final double photocopyLimit;
  final double stationaryLimit;
  final double tollLimit;

  TravelFormData({
    required this.code,
    required this.name,
    required this.email,
    required this.designation,
    required this.grades,
    required this.department,
    required this.branch,
    required this.branchCode,
    required this.mobile,
    required this.role,
    required this.managerId,
    required this.hodId,
    required this.kmRate,
    required this.da,
    required this.nightstay,
    required this.kmLtr,
    required this.maxKm,
    required this.mobileLimit,
    required this.entertainmentLimit,
    required this.bikeLimit,
    required this.courierLimit,
    required this.photocopyLimit,
    required this.stationaryLimit,
    required this.tollLimit,
  });

  factory TravelFormData.fromJson(Map<String, dynamic> json) {
    return TravelFormData(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      grades: json['grades']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      branchCode: json['branch_code']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      managerId: json['manager_id']?.toString() ?? '',
      hodId: json['hod_id']?.toString() ?? '',
      kmRate: _toDouble(json['km_rate']),
      da: _toDouble(json['da']),
      nightstay: _toDouble(json['nightstay']),
      kmLtr: _toDouble(json['km_ltr']),
      maxKm: _toDouble(json['max_km']),
      mobileLimit: _toDouble(json['mobile_limit']),
      entertainmentLimit: _toDouble(json['entertainment_limit']),
      bikeLimit: _toDouble(json['bike_limit']),
      courierLimit: _toDouble(json['courier_limit']),
      photocopyLimit: _toDouble(json['photocopy_limit']),
      stationaryLimit: _toDouble(json['stationary_limit']),
      tollLimit: _toDouble(json['toll_limit']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}