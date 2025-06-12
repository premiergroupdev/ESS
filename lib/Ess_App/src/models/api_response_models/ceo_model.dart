class CeoLoanModel {
  final List<CeoLoanForm> forms;

  CeoLoanModel({required this.forms});

  factory CeoLoanModel.fromJson(Map<String, dynamic> json) {
    final formsJson = json['Forms'];
    return CeoLoanModel(
      forms: formsJson != null && formsJson is List
          ? formsJson.map<CeoLoanForm>((e) => CeoLoanForm.fromJson(e)).toList()
          : [],
    );
  }
}

class CeoLoanForm {
  final String loanId;
  final String empCode;
  final String empName;
  final String position;
  final String doj;
  final String loanType;
  final String department;
  final String branch;
  final String loanAmount;
  final String purpose;
  final String totalInstallment;
  final String perMonthRepay;
  final String hodStatus;
  final String hoddate;
  final String hodName;
  final String directorStatus;
  final String directorname;
  final String ceoStatus;
  final String posted_date;
  final String attachmentUrl;
  final String completePf;
  final String empShare;
  final String cmpShare;
  final String dir_comments;
  final String hod_comments;

  final String dir_approval_date;

  final String prvBalance;

  CeoLoanForm({
    required this.loanId,
    required this.empCode,
    required this.empName,
    required this.dir_comments,
    required this.hoddate,
    required this.position,
    required this.doj,
    required this.loanType,
    required this.hod_comments,
    required this.department,
    required this.branch,
    required this.loanAmount,
    required this.purpose,
    required this.posted_date,
    required this.totalInstallment,
    required this.perMonthRepay,
    required this.hodStatus,
    required this.dir_approval_date,
    required this.hodName,
    required this.directorStatus,
    required this.ceoStatus,
    required this.attachmentUrl,
    required this.completePf,
    required this.empShare,
    required this.cmpShare,
    required this.prvBalance,
    required this.directorname,

  });

  factory CeoLoanForm.fromJson(Map<String, dynamic> json) {
    return CeoLoanForm(
      hod_comments: json['hod_comments'],
      dir_comments: json['dir_comments'],
      directorname: json['director_name'],
      loanId: json['loan_id'] ?? 0,
      hoddate: json['hod_approval_date'] ?? 0,
      posted_date: json['posted_date'],
      empCode: json['emp_code']?.toString() ?? '',
      empName: json['emp_name']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      doj: json['doj']?.toString() ?? '',
      dir_approval_date: json['dir_approval_date']?.toString() ?? '',

      loanType: json['loantype']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      loanAmount: json['loan_amount']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      totalInstallment: json['total_installment']?.toString() ?? '',
      perMonthRepay: json['per_month_repay']?.toString() ?? '',
      hodStatus: json['hod_status']?.toString() ?? '',
      hodName: json['hod_name']?.toString() ?? '',
      directorStatus: json['director_status']?.toString() ?? '',
      ceoStatus: json['ceo_status']?.toString() ?? '',
      attachmentUrl: json['attachmenturl']?.toString() ?? '',
      completePf: json['complete_pf']?.toString() ?? '',
      empShare: json['emp_share']?.toString() ?? '',
      cmpShare: json['cmp_share']?.toString() ?? '',
      prvBalance: json['prv_balance']?.toString() ?? '',
    );
  }
}
