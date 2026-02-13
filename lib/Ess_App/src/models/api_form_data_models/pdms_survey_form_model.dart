// survey model for only showing list

class SurveyModel {
  final String surveyId;
  final String userId;
  final String userName;
  final String productCode;
  final String productName;
  final String generic;
  final String registrationNo;
  final String postedDate;
  final Map<String, dynamic>? fullDetails;

  SurveyModel({
    required this.surveyId,
    required this.userId,
    required this.userName,
    required this.productCode,
    required this.productName,
    required this.generic,
    required this.registrationNo,
    required this.postedDate,
    this.fullDetails,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      surveyId: json['survey_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      productCode: json['product_code']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      generic: json['generic']?.toString() ?? '',
      registrationNo: json['registration_no']?.toString() ?? '',
      postedDate: json['posted_date']?.toString() ?? '',
      fullDetails: json,
    );
  }

  // For card display
  String get displayTitle => productName.isNotEmpty ? productName : "Survey #$surveyId";
  String get displaySubtitle => "Code: $productCode | Generic: $generic";
  String get displayUserInfo => "$userName ($userId)";
}