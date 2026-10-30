/// One employee as returned by loan_employee.php
/// (action=self, action=list and action=details all use the same keys).
///
/// The list action only returns code, name, designation, department and
/// branch, so empContact / empDoj / empCnic are '' for list items.
class LoanEmployee {
  final String empCode;
  final String empName;
  final String empDesignation;
  final String department;
  final String empBranch;
  final String empContact;
  final String empDoj;
  final String empCnic;

  const LoanEmployee({
    required this.empCode,
    required this.empName,
    required this.empDesignation,
    required this.department,
    required this.empBranch,
    this.empContact = '',
    this.empDoj = '',
    this.empCnic = '',
  });

  factory LoanEmployee.fromJson(Map<String, dynamic> json) {
    // emp_code comes back as a number, the rest as strings (or null),
    // so everything is normalised to a trimmed String here.
    String s(dynamic v) => v?.toString().trim() ?? '';

    return LoanEmployee(
      empCode: s(json['emp_code']),
      empName: s(json['emp_name']),
      empDesignation: s(json['emp_designation']),
      department: s(json['department']),
      empBranch: s(json['emp_branch']),
      empContact: s(json['emp_contact']),
      empDoj: s(json['emp_doj']),
      empCnic: s(json['emp_cnic']),
    );
  }
}