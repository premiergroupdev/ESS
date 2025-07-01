class PlanApprovalResponse {
  final List<PlanApproval> approvals;
  final int code;
  final String message;

  PlanApprovalResponse({
    required this.approvals,
    required this.code,
    required this.message,
  });

  factory PlanApprovalResponse.fromJson(Map<String, dynamic> json) {
    final approvalsJson = json['plan_approvals'] as Map<String, dynamic>;

    // Remove non-numeric keys like 'code' and 'message'
    final approvalEntries = approvalsJson.entries
        .where((entry) => int.tryParse(entry.key) != null)
        .map((entry) => PlanApproval.fromJson(entry.value))
        .toList();

    return PlanApprovalResponse(
      approvals: approvalEntries,
      code: approvalsJson['code'],
      message: approvalsJson['message'],
    );
  }
}

class PlanApproval {
  final String planId;
  final String memberName;
  final String memberDesignation;
  final String startDate;
  final String endDate;
  final String filledDate;

  PlanApproval({
    required this.planId,
    required this.memberName,
    required this.memberDesignation,
    required this.startDate,
    required this.endDate,
    required this.filledDate,
  });

  factory PlanApproval.fromJson(Map<String, dynamic> json) {
    return PlanApproval(
      planId: json['plan_id'],
      memberName: json['member_name'],
      memberDesignation: json['member_designation'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      filledDate: json['filled_date'],
    );
  }
}
