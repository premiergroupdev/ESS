import 'dart:convert';

// CopexApproval model class
class CopexApproval {
  final String? copexId;
  final String? empCode;
  final String? memberName;
  final String? memberDesignation;
  final String? branch;
  final String? postedDate;
  final String? capexType;
  final String? cordStatus;
  final String? hodStatus;
  final String? deptHeadStatus;
  final String? gmStatus;

  CopexApproval({
    this.copexId,
    this.empCode,
    this.memberName,
    this.memberDesignation,
    this.branch,
    this.postedDate,
    this.capexType,
    this.cordStatus,
    this.hodStatus,
    this.deptHeadStatus,
    this.gmStatus,
  });

  // Factory method to parse JSON
  factory CopexApproval.fromJson(Map<String, dynamic> json) {
    return CopexApproval(
      copexId: json['copex_id'] as String?,
      empCode: json['emp_code'] as String?,
      memberName: json['member_name'] as String?,
      memberDesignation: json['member_designation'] as String?,
      branch: json['branch'] as String?,
      postedDate: json['posted_date'] as String?,
      capexType: json['capex_type'] as String?,
      cordStatus: json['cord_status'] as String?,
      hodStatus: json['hod_status'] as String?,
      deptHeadStatus: json['dept_head_status'] as String?,
      gmStatus: json['gm_status'] as String?,
    );
  }

  // To convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'copex_id': copexId,
      'emp_code': empCode,
      'member_name': memberName,
      'member_designation': memberDesignation,
      'branch': branch,
      'posted_date': postedDate,
      'capex_type': capexType,
      'cord_status': cordStatus,
      'hod_status': hodStatus,
      'dept_head_status': deptHeadStatus,
      'gm_status': gmStatus,
    };
  }
}

// Main response model
class CopexResponse {
  final String statusCode;
  final String statusMessage;
  final List<CopexApproval>? copexApprovals;

  CopexResponse({
    required this.statusCode,
    required this.statusMessage,
    this.copexApprovals,
  });

  // Factory method to parse JSON response
  factory CopexResponse.fromJson(Map<String, dynamic> json) {
    var list = json['CopexApprovals'] as List?;
    List<CopexApproval>? approvalsList = list != null
        ? list.map((item) => CopexApproval.fromJson(item)).toList()
        : null;

    return CopexResponse(
      statusCode: json['status_code'] as String,
      statusMessage: json['status_message'] as String,
      copexApprovals: approvalsList,
    );
  }

  // To convert the response object to JSON
  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'status_message': statusMessage,
      'CopexApprovals': copexApprovals?.map((item) => item.toJson()).toList(),
    };
  }
}


