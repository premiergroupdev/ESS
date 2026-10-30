// import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import '../../base/utils/constants.dart';
import '../../models/api_response_models/branch.dart';
import '../../models/api_response_models/guaranter.dart';
import '../../models/api_response_models/loan_employee.dart';
import '../../models/api_response_models/loan_model.dart';
import '../../services/local/base/auth_view_model.dart';
import '../../services/local/navigation_service.dart';
import '../../services/remote/base/api_view_model.dart';
class LoanViewModel extends ReactiveViewModel with AuthViewModel, ApiViewModel {
  List<finalloan> finalApprovalData = [];
  List<finalguaranter> finalguaranterlist1 = [];
  List<finalbranch> branchlist = [];
  List<finalguaranter> finalguaranterlist2 = [];
  List<String> loan_applicants = ["Self","For Employee"];

  // ── Employee autofill state ──────────────────────────────────────────
  /// Result of action=list, used by the "Employee" dropdown (For Employee).
  List<LoanEmployee> employeeList = [];

  /// Why the list could not be loaded (the server's own message when it gave
  /// one, e.g. "You are not eligible to fill a loan form on behalf of another
  /// employee."). Shown in the Employee area of the screen.
  String? employeeListError;

  /// emp_code of the employee picked in the "Employee" dropdown.
  String? selectedEmployeeCode;
  bool employeeDropdownError = false;

  /// True while a self / list / details call is running. This is deliberately
  /// NOT runBusyFuture: isBusy swaps the whole form for the loading indicator,
  /// which destroys every dropdown's internal state (their selected label).
  bool isFetchingEmployee = false;

  /// Bumped every time the user switches type or picks an employee, so a slow
  /// response from an older action can't overwrite the newer one.
  int _fillToken = 0;

  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController positioncontroller = TextEditingController();
  final TextEditingController departmentcontroller = TextEditingController();
  final TextEditingController branchcontroller = TextEditingController();
  final TextEditingController empcodecontroller = TextEditingController();
  final TextEditingController mobilenumbercontroller = TextEditingController();
  final TextEditingController dateofjoningcontroller = TextEditingController();
  final TextEditingController cniccontroller = TextEditingController();
  final TextEditingController loanamountinwordscontroller = TextEditingController();
  final TextEditingController loanamountrs = TextEditingController();
  final TextEditingController purposeofloancontroller = TextEditingController();
  final TextEditingController repaymonthlyamount = TextEditingController();
  final TextEditingController repay_loan_month_controller = TextEditingController();
  final TextEditingController resultController = TextEditingController();
  bool applicantDropdownError = false;
  bool loanTypeDropdownError = false;
  bool guarantor1DropdownError = false;
  bool guarantor2DropdownError = false;

  bool imageError = false;

  DateTime bookDateFormat = DateTime.now();
  @override
  void dispose() {
    loanamountrs.dispose();
    repay_loan_month_controller.dispose();
    repaymonthlyamount.dispose();
    resultController.dispose();
    super.dispose();
  }
  String? selectedValue;
  String? loanapplicants;
  String? selectedgraduatevalue1;
  String? selectedgraduatevalue2;

  /// What is sent to the server as branch_name. Normally the bms_code of the
  /// branch that matches the name returned by the employee API.
  String? branchvalue;
  LoanViewModel() {

    // loanamountrs.addListener(calculateMonthlyAmount);
    repay_loan_month_controller.addListener(calculateMonthlyAmount);

    notifyListeners();
  }
  String imagepath = "";
  ImagePicker picker = ImagePicker();

  Future<void> get_gallery_image() async {
    try {
      // final result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png',],
      // );

      // if (result != null) {
      //   final pickedFile = result.files.first;

      // if (pickedFile.extension == 'pdf') {
      //   imagepath = pickedFile.path!;
      //   notifyListeners();
      // } else {
      // Handle image file
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        imagepath = pickedImage.path;
        notifyListeners();
      }
      //}
      //  }
    } catch (e) {
      print('Error picking file: $e');
    }
  }
  void showDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Important Notice', style: TextStyle(),textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: Text(
              'This loan service is only available to internal employees of Premier Sales Private Limited as part of their Provident Fund (PF) benefits.This is not a public loan or consumer lending product.There are no APRs, fees, penalties, or third-party financing involved.',
              style: TextStyle(fontSize: 16, ),

            ),
          ),
          actions: [
            TextButton(
              child: Text('I Understand'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void calculateMonthlyAmount() {
    // Remove commas, currency symbols, and whitespace
    String cleanedLoanAmount = loanamountrs.text
        .replaceAll(RegExp(r'[^\d.]'), '')  // Keep only digits and decimal
        .trim();

    String cleanedRepayMonth = repay_loan_month_controller.text
        .replaceAll(RegExp(r'[^\d.]'), '')
        .trim();

    double loanAmount = double.tryParse(cleanedLoanAmount) ?? 0.0;
    double? repayMonth = double.tryParse(cleanedRepayMonth);

    // Default to 1 if parsing fails or is 0
    if (repayMonth == null || repayMonth == 0) {
      repayMonth = 1.0;
    }

    // Calculate monthly amount and update the resultController text
    double monthlyAmount = loanAmount / repayMonth;
    resultController.text = monthlyAmount.round().toString();

    notifyListeners();
  }


  /// Runs one loader so that a network / parsing error in it (for example the
  /// server refusing the connection) can't abort init() and leave the screen
  /// half loaded. runBusyFuture re-throws a TypeError when the call fails,
  /// which is what used to crash here.
  Future<void> _safeLoad(
      BuildContext context, String what, Future<void> Function() load) async {
    try {
      await load();
    } catch (e) {
      print('Loan: could not load $what: $e');
      Constants.customErrorSnack(context,
          "Could not load $what. Please check your connection and try again.");
    }
  }

  init(BuildContext context) async {
    // loanapplicants stays null until the user picks "Applying for"
    await _safeLoad(context, 'loan types', () => getFinalApprovalData(context));
    await _safeLoad(context, 'guarantors', () => guaranterdata(context));
    await _safeLoad(context, 'branches', () => branchdata(context));
    notifyListeners();
    showDisclaimerDialog(context);




    // The finalApprovalData list may not be populated here
  }

  // ─────────────────────────────────────────────────────────────────────
  // Applicant autofill (Self / For Employee)
  // ─────────────────────────────────────────────────────────────────────

  /// Empties only the fields the autofill touches (not the loan details,
  /// attachment, etc.).
  void clearApplicantFields() {
    namecontroller.clear();
    positioncontroller.clear();
    departmentcontroller.clear();
    branchcontroller.clear();
    empcodecontroller.clear();
    mobilenumbercontroller.clear();
    dateofjoningcontroller.clear();
    cniccontroller.clear();
    branchvalue = null;
  }

  /// Called when "Applying for" is picked.
  Future<void> onApplicantTypeChanged(BuildContext context, String value) async {
    final newType = value == "Self"
        ? "for_self"
        : value == "For Employee"
        ? "for_employee"
        : null;
    if (newType == null) return;

    _fillToken++; // invalidates any call still running for the old selection
    final typeChanged = loanapplicants != newType;

    clearApplicantFields();
    selectedEmployeeCode = null;
    employeeDropdownError = false;
    applicantDropdownError = false;
    isFetchingEmployee = false;

    // The guarantor dropdowns are rebuilt when the type changes, which resets
    // their visible label, so their stored values must be reset with them.
    if (typeChanged) {
      selectedgraduatevalue1 = null;
      selectedgraduatevalue2 = null;
      guarantor1DropdownError = false;
      guarantor2DropdownError = false;
    }

    loanapplicants = newType;
    notifyListeners();

    if (newType == "for_self") {
      await loadSelfDetails(context);
    } else if (employeeList.isEmpty) {
      await loadEmployeeList(context);
    }
  }

  /// Text to show for a failed loan_employee call: the server's own message
  /// when it sent one (403 "not eligible", 404 "not found", ...), otherwise
  /// the generic error text.
  String _employeeErrorText(dynamic error) {
    final serverMessage = apiService.loanEmployeeError;
    return (serverMessage != null && serverMessage.isNotEmpty)
        ? serverMessage
        : error.toString();
  }

  /// Snack for a failed loan_employee call. A message that came from the
  /// server (e.g. "You are not eligible...") is shown under the heading
  /// "Note"; anything else (network problems, ...) keeps the heading "Error".
  void _showEmployeeError(BuildContext context, dynamic error) {
    final serverMessage = apiService.loanEmployeeError;
    final fromServer = serverMessage != null && serverMessage.isNotEmpty;
    Constants.customErrorSnack(
      context,
      _employeeErrorText(error),
      title: fromServer ? 'Note' : 'Error',
    );
  }

  /// action=self -> fill the form with the logged-in employee.
  Future<void> loadSelfDetails(BuildContext context) async {
    final token = _fillToken;
    isFetchingEmployee = true;
    notifyListeners();

    final response = await apiService.loanEmployeeSelf(context);
    if (token != _fillToken) return; // user switched meanwhile

    isFetchingEmployee = false;
    response.when(
      success: (data) => _fillFromEmployee(data),
      failure: (error) => _showEmployeeError(context, error),
    );
    notifyListeners();
  }

  /// action=list -> items for the "Employee" dropdown.
  Future<void> loadEmployeeList(BuildContext context) async {
    final token = _fillToken;
    employeeListError = null;
    isFetchingEmployee = true;
    notifyListeners();

    final response = await apiService.loanEmployeeList(context);
    if (token != _fillToken) return;

    isFetchingEmployee = false;
    response.when(
      success: (data) => employeeList = data,
      failure: (error) {
        employeeList = [];
        employeeListError = _employeeErrorText(error);
        _showEmployeeError(context, error);
      },
    );
    notifyListeners();
  }

  /// An employee was picked in the dropdown -> action=details -> fill form.
  Future<void> onEmployeeSelected(BuildContext context, LoanEmployee emp) async {
    final token = ++_fillToken;

    clearApplicantFields();
    selectedEmployeeCode = emp.empCode;
    employeeDropdownError = false;
    isFetchingEmployee = true;
    notifyListeners();

    final response = await apiService.loanEmployeeDetails(context, emp.empCode);
    if (token != _fillToken) return;

    isFetchingEmployee = false;
    response.when(
      success: (data) => _fillFromEmployee(data),
      failure: (error) => _showEmployeeError(context, error),
    );
    notifyListeners();
  }

  void _fillFromEmployee(LoanEmployee e) {
    empcodecontroller.text = e.empCode;
    namecontroller.text = e.empName;
    positioncontroller.text = e.empDesignation;
    departmentcontroller.text = e.department;

    // The API returns e.g. "0346-0536096"; the submit check wants exactly 11
    // characters, so keep digits only. Empty stays empty (user can type it).
    mobilenumbercontroller.text = e.empContact.replaceAll(RegExp(r'\D'), '');

    dateofjoningcontroller.text = e.empDoj; // already yyyy-MM-dd
    final doj = DateTime.tryParse(e.empDoj);
    if (doj != null) bookDateFormat = doj;

    cniccontroller.text = e.empCnic;
    _applyBranch(e.empBranch);
  }

  /// Shows the branch name (read-only) and works out the value to submit.
  /// The form used to submit the bms_code of the branch picked from
  /// branchlist, so the returned name is matched against that list.
  void _applyBranch(String branchName) {
    branchcontroller.text = branchName;
    final wanted = branchName.trim().toLowerCase();

    finalbranch? match;
    for (final b in branchlist) {
      if (b.branch_name.trim().toLowerCase() == wanted) {
        match = b;
        break;
      }
    }

    if (match != null) {
      branchvalue = match.bms_code.toString();
    } else {
      // No exact name match: fall back to the name itself so the form is not
      // blocked. Watch for this line in the console when testing a submit.
      print('Loan: branch "$branchName" not found in branchlist, sending the name');
      branchvalue = branchName;
    }
  }

  Future<void> getFinalApprovalData(BuildContext context) async {
    var newsResponse = await runBusyFuture(apiService.loanapproval(context));
    newsResponse.when(
      success: (data) {
        // Append data to finalApprovalData
        finalApprovalData=data.approvalItems;

        print(finalApprovalData);
      },
      failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      },
    );
  }
  clear(){
    namecontroller.clear();
    positioncontroller.clear();
    departmentcontroller.clear();
    branchcontroller.clear();
    empcodecontroller.clear();
    mobilenumbercontroller.clear();
    dateofjoningcontroller.clear();
    cniccontroller.clear();
    loanamountinwordscontroller.clear();
    loanamountrs.clear();
    purposeofloancontroller.clear();
    repaymonthlyamount.clear();
    repay_loan_month_controller.clear();
    selectedValue=null;
    selectedgraduatevalue1=null;
    selectedgraduatevalue2=null;
    selectedEmployeeCode=null;
    branchvalue=null;
    imagepath='';
  }

  Future<void> guaranterdata(BuildContext context) async {
    var newsResponse = await runBusyFuture(apiService.guaranterapi(context));
    newsResponse.when(
      success: (data) {
        // Append data to finalApprovalData
        finalguaranterlist1=data.approvalItems;
        finalguaranterlist2=data.approvalItems;
        print(finalApprovalData);
      },
      failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      },
    );
  }
  Future<void> branchdata(BuildContext context) async {
    var newsResponse = await runBusyFuture(apiService.branchapi(context));
    newsResponse.when(
      success: (data) {
        // Append data to finalApprovalData
        branchlist=data.approvalItems;

      },
      failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      },
    );
  }
  Future<void> applyloan(BuildContext context) async {
    var newsResponse = await runBusyFuture(apiService.applyloan(
        context,
        loanapplicants.toString(),
        selectedValue.toString(),
        namecontroller.text,
        positioncontroller.text,
        departmentcontroller.text,
        branchvalue.toString(),
        '', // pre_code: dropped from the form for now (backend check pending)
        empcodecontroller.text,
        mobilenumbercontroller.text,
        dateofjoningcontroller.text,
        cniccontroller.text,
        loanamountrs.text,
        loanamountinwordscontroller.text,
        purposeofloancontroller.text,
        repay_loan_month_controller.text,
        resultController.text,
        selectedgraduatevalue1.toString(),
        selectedgraduatevalue2.toString(),
        imagepath


    ));

    newsResponse.when(
      success: (data) {
        newsResponse.when(
          success: (data) {
            if (data == "Loan Submitted Successfully") {
              clear();
              NavService.allloan();
              Constants.customSuccessSnack(
                  context, "Your Application Submitted Successfully");

            } else {
              Constants.customErrorSnack(
                  context, "Your Application Not Submit, Try Again");
            }
          },
          failure: (error) {
            Constants.customErrorSnack(context, error.toString());
          },
        );
      },
      failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      },
    );
  }
}