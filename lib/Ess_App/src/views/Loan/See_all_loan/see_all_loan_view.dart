import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:ess/Ess_App/src/views/Loan/See_all_loan/see_all_loan_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../models/api_response_models/fetch_loan_approval.dart';
import '../../../shared/top_app_bar.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/text_theme.dart';

class Allloan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AllLoanViewModel>.reactive(
      builder: (viewModelContext, model, child) =>
          Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GeneralAppBar(
                        title: "My Loan Applications",
                        onMenuTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        onNotificationTap: () {}),
                    (model.isBusy == true)
                        ? Center(child: CircularProgressIndicator(
                      color: AppColors.primary,))
                        : SizedBox(
                        height: context
                            .screenSize()
                            .height - 145,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                            shrinkWrap: true
                            ,
                            itemCount: model.loanlistfinal.length,
                            itemBuilder: (context, index) {
                              loanList data = model.loanlistfinal[index];


                              return

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.blue.shade100,
                                    //     offset: Offset(2, 2),
                                    //     blurRadius: 6,
                                    //   ),
                                    // ],
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Employee Code
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Employee Code: ",
                                            style: TextStyling.text14.copyWith(
                                              color: AppColors.black,
                                              fontSize: 13,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: data.emp_code.toString(),
                                                style: TextStyling.bold14.copyWith(
                                                  color: AppColors.primary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Employee Name
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Employee Name: ",
                                            style: TextStyling.text14.copyWith(color: AppColors.black),
                                            children: [
                                              TextSpan(
                                                text: data.emp_name.toString(),
                                                style: TextStyling.bold14.copyWith(
                                                  color: AppColors.primary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Loan Amount
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Loan Amount: ",
                                            style: TextStyling.text14.copyWith(  color: AppColors.black,),
                                            children: [
                                              TextSpan(
                                                text: data.loan_amount.toString(),
                                                style: TextStyling.text12.copyWith(
                                                  color: AppColors.primary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Button Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12)),
                                                    title: Center(
                                                      child: Text(
                                                        'Loan Details',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                          color: AppColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                    content: SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          detailRow("Designation", data.position),
                                                          detailRow("Loan Type", data.loantype),
                                                          detailRow("Date of Joining", data.doj),
                                                          detailRow("Total Installments", data.total_installment),
                                                          detailRow("Per Month Repay", data.per_month_repay),
                                                          detailRow("HOD Status", data.hod_status),
                                                          detailRow("Director Status", data.director_status),
                                                          detailRow("CEO Status", data.ceo_status),
                                                          detailRow("Reason", data.purpose),
                                                        ],
                                                      ),
                                                    ),
                                                    // actions: [
                                                    //   Center(
                                                    //     child: TextButton(
                                                    //       onPressed: () => Navigator.of(context).pop(),
                                                    //       child: Text('Close'),
                                                    //     ),
                                                    //   )
                                                    // ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: AppColors.primary,
                                              ),
                                              child: Text(
                                                "See Details",
                                                style: TextStyle(color: Colors.white, fontSize: 10),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                );

                            }
                        )
                    )
                  ],
                ),
              ),
            ),
          ),
      viewModelBuilder: () => AllLoanViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }}

Widget detailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: Text("$title:")),
        Expanded(flex: 4, child: Text(value, style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    ),
  );
}
