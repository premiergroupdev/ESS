class ExpensesModel {
  final List<Expense>? expenses;

  ExpensesModel({this.expenses});

  factory ExpensesModel.fromJson(Map<String, dynamic> json) {
    return ExpensesModel(
      expenses: (json['Expenses'] as List?)
          ?.map((e) => Expense.fromJson(e))
          .toList(),
    );
  }
}

class Expense {
  final String? travelId;
  final String? empCode;
  final String? empName;
  final String? grade;
  final String? postedDate;
  final String? dept;
  final String? totalTravel;
  final String? totalKmRate;
  final String? travelType;
  final String? reasonOfTravel;
  final String? dailyAllowance;
  final String? convExpense;
  final String? tollTax;
  final String? bikeAllowance;
  final String? courierAllowance;
  final String? photoAllow;
  final String? stationaryAllow;
  final int? totalExpense;
  final List<Attachment>? billsAttachments;
  final List<ApprovalStatus>? approvalStatus;
  final List<Comment>? comments;
  final List<Routelist>? route;

  Expense({
    this.travelId,
    this.empCode,
    this.empName,
    this.grade,
    this.postedDate,
    this.dept,
    this.totalTravel,
    this.totalKmRate,
    this.travelType,
    this.reasonOfTravel,
    this.dailyAllowance,
    this.convExpense,
    this.tollTax,
    this.bikeAllowance,
    this.courierAllowance,
    this.photoAllow,
    this.stationaryAllow,
    this.totalExpense,
    this.billsAttachments,
    this.approvalStatus,
    this.comments,
    this.route,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      travelId: json['travel_id'],
      empCode: json['emp_code'],
      empName: json['emp_name'],
      grade: json['grade'],
      postedDate: json['posted_date'],
      dept: json['Dept'],
      totalTravel: json['total_travel'],
      totalKmRate: json['totalKmRate'],
      travelType: json['traveltype'],
      reasonOfTravel: json['reason_of_travel'],
      dailyAllowance: json['daily_allowance'],
      convExpense: json['conv_expense'],
      tollTax: json['toll_tax'],
      bikeAllowance: json['bike_allowance'],
      courierAllowance: json['courier_allowance'],
      photoAllow: json['photo_allow'],
      stationaryAllow: json['stationary_allow'],
      totalExpense: json['total_expense'],
      billsAttachments: (json['bills_attachments'] as List?)
          ?.map((e) => Attachment.fromJson(e))
          .toList(),
      approvalStatus: (json['approval_status'] as List?)
          ?.map((e) => ApprovalStatus.fromJson(e))
          .toList(),
      comments: (json['comments'] as List?)
          ?.map((e) => Comment.fromJson(e))
          .toList(),
      route: (json['route'] as List?)
          ?.map((e) => Routelist.fromJson(e))
          .toList(),
    );
  }
}

class Attachment {
  final String? attachments;

  Attachment({this.attachments});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      attachments: json['attachments'],
    );
  }
}

class ApprovalStatus {
  final String? status;

  ApprovalStatus({this.status});

  factory ApprovalStatus.fromJson(Map<String, dynamic> json) {
    return ApprovalStatus(
      status: json['status'],
    );
  }
}

class Comment {
  final String? commentsLog;
  final String? commentsby;

  Comment({this.commentsLog, this.commentsby});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentsLog: json['comments_log'],
      commentsby: json['comments_by'],
    );
  }
}

class Routelist {
  final String? origin;
  final String? destination;
  final String? distance;
  final String? depDate;
  final String? arrivalStatus;
  final String? arrival_data;

  Routelist({
    this.origin,
    this.destination,
    this.distance,
    this.depDate,
    this.arrivalStatus,
    this.arrival_data
  });

  factory Routelist.fromJson(Map<String, dynamic> json) {
    return Routelist(
      arrival_data: json['arrival_date'],
      origin: json['origin'],
      destination: json['destination'],
      distance: json['distance'],
      depDate: json['dep_date'],
      arrivalStatus: json['arrival_status'],
    );
  }
}
