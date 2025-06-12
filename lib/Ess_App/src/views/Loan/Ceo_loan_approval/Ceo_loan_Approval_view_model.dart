import 'package:ess/Ess_App/src/models/api_response_models/Hod_loan_approval.dart';
import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../../base/utils/constants.dart';
import '../../../models/api_response_models/ceo_model.dart';
import 'package:intl/intl.dart';

import '../../../styles/app_colors.dart';

class ceo_view_model extends ReactiveViewModel with AuthViewModel, ApiViewModel {


  @override
  void dispose() {
    New_loan_amt.forEach((element) {element.dispose();});
    loan_repay_tenure.forEach((element) {element.dispose();});
    resultController.forEach((element) {element.dispose();});
    super.dispose();
  }

  List<String?> selectedvisitStatusList=["Select your decision"];

  List<String> dropdownValues = ["Select your decision", "Approved", "Rejected"];
  List<CeoLoanForm> loanlistfinal=[];
  TextEditingController comment=TextEditingController();
  List<TextEditingController> New_loan_amt=[];
  List<TextEditingController> loan_repay_tenure=[];
  List<TextEditingController> loan_installment=[];
  List<TextEditingController> resultController=[];
  List<String> url=[];
  final formatter = NumberFormat.decimalPattern('en_IN');


  init(BuildContext context) async {

    await getvisitApprovalData(context);
    selectedvisitStatusList = List.generate(
      loanlistfinal.length, (index) => "Select your decision",);
    url = List.generate(
      loanlistfinal.length, (index) => "Select your decision",);
    New_loan_amt = List.generate(loanlistfinal.length, (_) => TextEditingController());
    // New_loan_amt = List.generate(loanlistfinal.length, (i) {
    //   final controller = TextEditingController();
    //
    //   var rawAmount = loanlistfinal[i].loanAmount; // could be int/double
    //   controller.text = formatter.format(rawAmount); // assign formatted text
    //
    //   return controller;
    // });
    loan_repay_tenure = List.generate(loanlistfinal.length, (_) => TextEditingController());
    loan_installment = List.generate(loanlistfinal.length, (_) => TextEditingController());
    resultController = List.generate(loanlistfinal.length, (_) => TextEditingController());


    for (int i = 0; i < loanlistfinal.length; i++) {
      New_loan_amt[i].addListener(() => calculateMonthlyAmount(i));
      loan_repay_tenure[i].addListener(() => calculateMonthlyAmount(i));
    }

  }


  void calculateMonthlyAmount(int index) {
    double loanAmount = double.tryParse(New_loan_amt[index].text) ?? 0.0;
    double repayMonth = double.tryParse(loan_repay_tenure[index].text) ?? 1.0; // Default to 1 if parsing fails or value is 0
    double monthlyAmount = loanAmount / repayMonth;
    resultController[index].text = monthlyAmount.round().toString(); // Format the result to 2 decimal places
  }

  getvisitApprovalData(
      BuildContext context,
      ) async {
    var newsResponse = await runBusyFuture(apiService.loan_approval_ceo());
    newsResponse.when(success: (data) async {
      if ((data?.forms.length ?? 0) > 0) {
        loanlistfinal = data.forms.reversed.toList();




      } else {
        Constants.customWarningSnack(context, "Loan Approval not found");
      }
    }, failure: (error) {
      Constants.customErrorSnack(context, error.toString());
    });
  }


  update(BuildContext context , String loanid, int index) async {
    var response = await apiService.updateloan( loanid, New_loan_amt[index].text, loan_repay_tenure[index].text, resultController[index].text);
    response.when(success: (data)
    async {
      if (data["status"] == "200")
      {
        //
        print(data["status_message"].toString());
        Constants.customSuccessSnack(context, data["status_message"]);
        getvisitApprovalData(context);
        notifyListeners();

      }
      else {
        Constants.customErrorSnack(context, data["status_message"]);
        print(data["status"].toString());
        notifyListeners();

      }
    },
        failure: (error){
          print(error);
          Constants.customErrorSnack(context, error.toString());
        });
  }



  void show_pf_details(BuildContext context, CeoLoanForm data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 200,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'PF Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'Complete PF: '),
                        TextSpan(
                          text:
                          '${NumberFormat('#,##0').format(int.tryParse(data.completePf) ?? 0)}\n',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        TextSpan(text: 'Emp Share: '),
                        TextSpan(
                          text:
                          '${NumberFormat('#,##0').format(int.tryParse(data.empShare) ?? 0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),


                        if (data.cmpShare.isNotEmpty) ...[
                          TextSpan(text: '\nCmp Share: '),
                          TextSpan(
                            text:
                            '${NumberFormat('#,##0').format(int.tryParse(data.cmpShare) ?? 0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const WidgetSpan(child: SizedBox(height: 8)), // 👈 Spacing
                        ],
                        if (data.prvBalance.isNotEmpty) ...[
                          TextSpan(text: '\nPrv Share: '),
                          TextSpan(
                            text:
                            '${NumberFormat('#,##0').format(int.tryParse(data.prvBalance) ?? 0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],

                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void approval_details(BuildContext context, CeoLoanForm data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 280, // Increased width for breathing room
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // Left-align content
                children: [
                  Center(
                    child: Text(
                      'Approval Details',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // HOD Section
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'HOD Status:\n',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text:
                          '${data.hodStatus} (${data.hodName})\nDate: ${data.hoddate}\nComment: ${data.hod_comments}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Director Section
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Director Status:\n',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text:
                          '${data.directorStatus} (${data.directorname})\nDate: ${data.dir_approval_date} \n Comment: ${data.dir_comments}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        "Close",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }







}


