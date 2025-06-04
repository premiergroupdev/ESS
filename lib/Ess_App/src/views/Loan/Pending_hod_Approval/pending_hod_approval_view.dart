import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:ess/Ess_App/src/views/Loan/Pending_hod_Approval/pending_approval_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import '../../../base/utils/constants.dart';
import '../../../models/api_response_models/Hod_loan_approval.dart';
import '../../../services/remote/api_result.dart';
import '../../../services/remote/api_service.dart';
import '../../../shared/top_app_bar.dart';
import '../../../styles/app_colors.dart';
import '../../your_attandence/widget/dropdown.dart';
import '../webview.dart';

class Pending_hod_approval extends StatefulWidget {
  @override
  State<Pending_hod_approval> createState() => _Pending_guaranteesState();
}


class _Pending_guaranteesState extends State<Pending_hod_approval> {
  @override
  Widget build(BuildContext context) {


    return ViewModelBuilder<pending_hod_view_model>.reactive(
      builder: (viewModelContext, model, child) =>
          Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GeneralAppBar(
                        title: "Pending HOD for Approval",
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
                            shrinkWrap: true
                            ,
                            itemCount: model.loanlistfinal.length,
                            itemBuilder: (context, index) {
                              LoanForm data = model.loanlistfinal[index];

                              model.New_loan_amt[index].text = data.loanAmount.toString();
                              model.loan_installment[index].text = data.perMonthRepay.toString();
                              model.loan_repay_tenure[index].text = data.totalInstallment;
                              void resetSelectedStatus(int index) {

                                setState(() {
                                  model.selectedvisitStatusList[index] =
                                  "Select your decision";
                                });
                              }


                              return

                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius
                                          .circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                            AppColors.primary
                                                .withOpacity(0.6),
                                            offset: Offset(1, 1),
                                            blurRadius: 2)
                                      ]),
                                  margin: EdgeInsets.fromLTRB(
                                      20, 10, 20, 5),
                                  padding: EdgeInsets.fromLTRB(
                                      10, 15, 10, 15),
                                  child: Column(children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Mr. ',
                                                    style: GoogleFonts.poppins(
                                                      color: AppColors.black,


                                                    ),
                                          ),
                                          TextSpan(
                                            text: data.empName.toString(),
                                                    style: GoogleFonts.poppins(
                                                        color: AppColors.primary,
                                                        fontWeight: FontWeight.w600


                                                    ),
                                          ),

                                          TextSpan(
                                            text: ' has applied for the loan of ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: data.loanAmount.toString() + " Rs. \n",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),

                                          TextSpan(
                                            text: 'Designation:  ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: data.position + "\n",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Department:  ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: data.department + "\n",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Date of joining:  ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: data.doj + "\n",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Loan type:  ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: data.loanType + "\n",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Purpose : ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: "${data.purpose + "\n\n"}",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: ' He will repay the loan in',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: ' ${data.totalInstallment}',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: ' equal installments of ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: ' ${data.perMonthRepay} Rs',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: ' and need your approval for further proceedings. \n',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.black,


                                              ),
                                          ),

                                          if(data.empShare.isNotEmpty)
                                          TextSpan(
                                            text: 'Emp Share : ${data.empShare} ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          if(data.cmpShare.isNotEmpty)
                                          TextSpan(
                                            text: 'Cmp Share : ${data.cmpShare} ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          if(data.prvBalance.isNotEmpty)
                                          TextSpan(
                                            text: 'Prv Share : ${data.prvBalance}',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          if(data.loanComments.isNotEmpty)
                                          TextSpan(
                                            text: 'Coments : ${data.loanComments.map((e) => e.comments)} \n',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),

                                          if(data.loanComments.isNotEmpty)
                                          TextSpan(
                                            text: 'Posted by : ${data.loanComments.map((e) => e.postedBy)}',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),

                                          TextSpan(
                                            text: '',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          TextSpan(
                                            text: 'Do you want to change this amount and tenure?  ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Edit',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,


                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {

                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext contexts) {
                                                    return AlertDialog(
                                                      title: Text('Edit Form', textAlign: TextAlign.center,),
                                                      content: Container(
                                                        height: 250,  // Reduced height
                                                        child: Column(
                                                          children: [
                                                            TextFormField(
                                                              keyboardType: TextInputType.number,
                                                              controller:model.New_loan_amt[index],
                                                              decoration: InputDecoration(
                                                                labelText: 'New Loan Amount',
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                                ),
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                                  borderSide: BorderSide(
                                                                    color: AppColors.primary,  // Border color when enabled
                                                                    width: 2.0, // Border width when enabled
                                                                  ),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                                  borderSide: BorderSide(
                                                                    color: AppColors.primary, // Border color when focused
                                                                    width: 2.0, // Border width when focused
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 10,),
                                                            TextFormField(
                                                              keyboardType: TextInputType.number,
                                                              controller:model.loan_repay_tenure[index],
                                                              decoration: InputDecoration(
                                                                labelText: 'Loan Repay Tenure',
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                                ),
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                                  borderSide: BorderSide(
                                                                    color: AppColors.primary,  // Border color when enabled
                                                                    width: 2.0, // Border width when enabled
                                                                  ),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                                  borderSide: BorderSide(
                                                                    color: AppColors.primary, // Border color when focused
                                                                    width: 2.0, // Border width when focused
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 10,),
                                                            TextFormField(
                                                              enabled: false,
                                                              keyboardType: TextInputType.number,
                                                              controller:model.resultController[index],
                                                              decoration: InputDecoration(
                                                                labelText: 'Loan Installment',
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                                ),
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                                  borderSide: BorderSide(
                                                                    color: AppColors.primary,  // Border color when enabled
                                                                    width: 2.0, // Border width when enabled
                                                                  ),
                                                                ),
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                                  borderSide: BorderSide(
                                                                    color: AppColors.primary, // Border color when focused
                                                                    width: 2.0, // Border width when focused
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Text('Close'),
                                                          onPressed: () {
                                                            Navigator.of(contexts).pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text('Save'),
                                                          onPressed: ()    {

if(model.New_loan_amt[index].text.isNotEmpty && model.loan_repay_tenure[index].text.isNotEmpty){
  model.update(context, data.loanId, index);
  Navigator.pop(contexts);
}
else {
  Constants.customErrorSnack(context, "Please fill both feilds");

}
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

                                                // You can perform any action here, such as navigating to another screen
                                                // or showing a dialog
                                              },

                                          ),


                                        ],

                                      ),
                                    ),



                                    SizedBox(height: 10,),
                                    if(data.attachmenturl != null)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => WebViewScreen(url: data.attachmenturl),
                                                ),
                                              );
                                            },
                                            child:
                              Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8)),
                              child:
                                            Text(
                                              "See "
                                                  ""
                                                  "Attachments",
                                              style: TextStyle(fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                                color: Colors.white
                                              ),
                                              textAlign: TextAlign.start,

                                            ),
                                          ),
                                          ) ],
                                      ),



                                    SizedBox(height: 20,),
                              Container(
                              color: Colors.white,
                              height: 35,
                              child: TextFormField(
                                      controller:model.comment,
                                    decoration: InputDecoration(

                                    labelText: 'Enter Comment',

                                      labelStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500, fontSize: 15),

                                    border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                    color: AppColors.primary,  // Border color when enabled
                                    width: 1.0, // Border width when enabled
                                    ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                    color: AppColors.primary, // Border color when focused
                                     // Border width when focused
                              ),
                              ),
                              ),
                              ),
                              ),
SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        Spacer(),
                                        Container(
                                        height:35,
                              child: buildStatusDropdown(
                                          model.selectedvisitStatusList[index],
                                          model.dropdownValues,
                                              (String? newValue) async {
                                            setState(() {
                                              model.selectedvisitStatusList[index] = newValue; // Update the selected status for this item
                                            });
                                            print(model.selectedvisitStatusList[index]);
                                            print("Selected value for index $index: $newValue");

                                            // Check if the selected value is "Select your decision"
                                            if (newValue == "Select your decision") {
                                              resetSelectedStatus(index);
                                              return; // Exit the function early, skipping the API call
                                            }

                                            ApiService api = ApiService();
                                            String selectedBackendValue;
                                            if (newValue == "Approved") {
                                              selectedBackendValue = "approved";
                                            } else if (newValue ==
                                                "Rejected") {
                                              selectedBackendValue = "rejected";
                                            } else {
                                              selectedBackendValue =
                                              "0"; // Default value for other cases
                                            }

                                            final response = await api
                                                .hod_loan_approved(
                                              selectedBackendValue,
                                              data.loanId.toString(),
                                              model.comment.text.toString(),
                                            );

                                            if (response is Success) {
                                              final jsonResponse = response.data;

                                              if (jsonResponse != null &&
                                                  jsonResponse.containsKey(
                                                      "status")) {
                                                final status = jsonResponse["status"];
                                                final msg = jsonResponse['status_message'];
                                                print("Status: $status");

                                                if (newValue ==
                                                    "Approved") {
                                                  Constants.customSuccessSnack(
                                                      context, msg);
                                                } else if (newValue ==
                                                    "Rejected") {
                                                  Constants.customSuccessSnack(
                                                      context, msg);
                                                }

                                                if (
                                                newValue ==
                                                    "Approved" ||
                                                    newValue == "Rejected" ||
                                                    status == "200") {
                                                  setState(() {
                                                    if(model.selectedvisitStatusList != "Select your decision")

                                                      model.loanlistfinal.removeAt(index);
                                                    model.selectedvisitStatusList[index] = "Select your decision";
                                                  });
                                                }
                                              } else {
                                                print(
                                                    "JSON response is null or 'status' is missing");
                                              }
                                            }
                                          },
                                        )

                                        ) ],
                                    ),

                                  ],),
                                );
                            }
                        )
                    )
                  ],
                ),
              ),
            ),
          ),
      viewModelBuilder: () => pending_hod_view_model(),
      onModelReady: (model) => model.init(context),
    );
  }
}
