import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:ess/Ess_App/src/views/Loan/Pending_hod_Approval/pending_approval_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:stacked/stacked.dart';
import '../../../base/utils/constants.dart';
import 'package:intl/intl.dart';
import '../../../models/api_response_models/ceo_model.dart';
import '../../../services/remote/api_result.dart';
import '../../../services/remote/api_service.dart';
import '../../../shared/top_app_bar.dart';
import '../../../styles/app_colors.dart';
import '../../your_attandence/widget/dropdown.dart';
import '../webview.dart';
import 'Ceo_loan_Approval_view_model.dart';

class Ceo_loan_approval extends StatefulWidget {
  @override
  State<Ceo_loan_approval> createState() => _Pending_guaranteesState();
}


class _Pending_guaranteesState extends State<Ceo_loan_approval> {
  @override
  Widget build(BuildContext context) {


    return ViewModelBuilder<ceo_view_model>.reactive(
      builder: (viewModelContext, model, child) =>
          Scaffold(

            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GeneralAppBar(
                        title: "CEO Loan Approval",
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
                        child:



                        ListView.builder(
                            shrinkWrap: true
                            ,
                            itemCount: model.loanlistfinal.length,
                            itemBuilder: (context, index) {
                              CeoLoanForm data = model.loanlistfinal[index];

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
                                  padding:EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: HexColor("#F3F3F3"),
                                    ),
                                    color: HexColor("#FAFAFA"),
                                      borderRadius: BorderRadius
                                          .circular(12),

                                  
                                  ),
                                  margin: EdgeInsets.fromLTRB(
                                      20, 10, 20, 5),
                                  // padding: EdgeInsets.fromLTRB(
                                  //     10, 15, 10, 15),
                                  child: Column(children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Case ID:  ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: data.loanId + "\n",
                                            style: GoogleFonts.poppins(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Mr. ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: "${data.empName.toString()} - ${data.empCode.toString()}",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                              fontWeight: FontWeight.bold,


                                            ),
                                          ),


                                          TextSpan(
                                            text: ' has applied for the loan of ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: ' ${NumberFormat('#,##0').format(
                                              int.tryParse(data.loanAmount) ?? 0, // Fallback to 0 if parsing fails
                                            )} Rs \n',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,


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
                                              fontWeight: FontWeight.bold,


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
                                              fontWeight: FontWeight.bold,


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
                                              fontWeight: FontWeight.bold,


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Posted Date:  ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: data.posted_date.toString() + "\n",
                                            style: GoogleFonts.poppins(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,


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
                                              fontWeight: FontWeight.bold,


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Branch:  ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: data.branch + "\n",
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                              fontWeight: FontWeight.bold,


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
                                              fontWeight: FontWeight.bold,


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
                                              fontWeight: FontWeight.bold,


                                            ),
                                          ),
                                          TextSpan(
                                            text: ' equal installments of ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: ' ${NumberFormat('#,##0').format(
                                              int.tryParse(data.perMonthRepay) ?? 0, // Fallback to 0 if parsing fails
                                            )} Rs',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold


                                            ),
                                          ),
                                          TextSpan(
                                            text: ' and need your approval for further proceedings. \n\n',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),

                                          // if(data.empShare.isNotEmpty)
                                          //   TextSpan(
                                          //     text: 'Emp Share : ${data.empShare} ',
                                          //     style: GoogleFonts.poppins(
                                          //       color: AppColors.black,
                                          //
                                          //
                                          //     ),
                                          //   ),
                                          // if(data.cmpShare.isNotEmpty)
                                          //   TextSpan(
                                          //     text: 'Cmp Share : ${data.cmpShare} ',
                                          //     style: GoogleFonts.poppins(
                                          //       color: AppColors.black,
                                          //
                                          //
                                          //     ),
                                          //   ),
                                          // if(data.prvBalance.isNotEmpty)
                                          //   TextSpan(
                                          //     text: 'Prv Share : ${data.prvBalance}',
                                          //     style: GoogleFonts.poppins(
                                          //       color: AppColors.black,
                                          //
                                          //
                                          //     ),
                                          //   ),
                                          // if(data.loanComments.isNotEmpty)
                                          //   TextSpan(
                                          //     text: 'Coments : ${data.loanComments.map((e) => e.comments)} \n',
                                          //     style: GoogleFonts.poppins(
                                          //       color: AppColors.black,
                                          //
                                          //
                                          //     ),
                                          //   ),
                                          //
                                          // if(data.loanComments.isNotEmpty)
                                          //   TextSpan(
                                          //     text: 'Posted by : ${data.loanComments.map((e) => e.postedBy)}',
                                          //     style: GoogleFonts.poppins(
                                          //       color: AppColors.black,
                                          //
                                          //
                                          //     ),
                                          //   ),

                                          TextSpan(
                                            text: '',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          TextSpan(
                                            text: 'Do you want to change this amount and tenure?  ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,
                                              fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Edit',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
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
                                                              inputFormatters: [CurrencyInputFormatter()],
                                                              keyboardType: TextInputType.number,
                                                              controller:    model.New_loan_amt[index],
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
                                                              model.update(context, data.loanId.toString(), index);
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
                                    if(data.attachmentUrl != null)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => WebViewScreen(url: data.attachmentUrl),
                                                ),
                                              );
                                            },
                                            child:
                                            Container(

                                              child:
                                              Text(
                                                "See "
                                                    ""
                                                    "Attachments",
                                                style: GoogleFonts.poppins(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w500


                                                ),
                                                textAlign: TextAlign.start,

                                              ),
                                            ),
                                          ) ],
                                      ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [

                                            InkWell(
                                              onTap: () {
                                                model.approval_details(context, data);
                                              },
                                              child:
                                              Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius: BorderRadius.circular(8)),
                                                child:
                                                Text(
                                                  "Approval Details",
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white
                                                  ),
                                                  textAlign: TextAlign.start,

                                                ),
                                              ),


                                            ),
                                            SizedBox(width: 5,)
                                          ],
                                        ),
                                        if(data.empShare.isNotEmpty)
                                          Row(
                                            children: [

                                              InkWell(
                                                onTap: () {
                                                  model.show_pf_details(context, data);
                                                },
                                                child:
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius: BorderRadius.circular(8)),
                                                  child:
                                                  Text(
                                                    "PF Details",
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white
                                                    ),
                                                    textAlign: TextAlign.start,

                                                  ),
                                                ),


                                              ),
                                              SizedBox(width: 5,)
                                            ],
                                          ),




                                      ],
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

                                                // Show confirmation dialog before making the API call
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      backgroundColor: AppColors.primary, // Custom primary background color
                                                      title: Text(
                                                        "Confirm Your Decision",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white, // White text color
                                                        ),
                                                      ),
                                                      content: Text(
                                                        "Are you sure you want to $newValue this loan?",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.white, // White content text
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        // Cancel Button
                                                        TextButton(
                                                          child: Text(
                                                            "Cancel",
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              color: Colors.white, // White color for cancel button text
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(context).pop(); // Close the dialog
                                                            // Optionally reset the selection if the user cancels
                                                            setState(() {
                                                              model.selectedvisitStatusList[index] = "Select your decision";
                                                            });
                                                          },
                                                        ),
                                                        // Confirm Button
                                                        TextButton(
                                                          child: Text(
                                                            "Confirm",
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white, // White color for confirm button text
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            Navigator.of(context).pop(); // Close the dialog

                                                            ApiService api = ApiService();
                                                            String selectedBackendValue;

                                                            // Map the dropdown value to the backend value
                                                            if (newValue == "Approved") {
                                                              selectedBackendValue = "approved";
                                                            } else if (newValue == "Rejected") {
                                                              selectedBackendValue = "rejected";
                                                            } else {
                                                              selectedBackendValue = "0"; // Default value for other cases
                                                            }

                                                            // Make the API call
                                                            final response = await api.ceo_loan_approved(
                                                              selectedBackendValue,
                                                              data.loanId.toString(),
                                                              model.comment.text.toString(),
                                                            );

                                                            if (response is Success) {
                                                              final jsonResponse = response.data;

                                                              if (jsonResponse != null && jsonResponse.containsKey("status")) {
                                                                final status = jsonResponse["status"];
                                                                final msg = jsonResponse['status_message'];
                                                                print("Status: $status");

                                                                if (newValue == "Approved") {
                                                                  Constants.customSuccessSnack(context, msg);
                                                                } else if (newValue == "Rejected") {
                                                                  Constants.customSuccessSnack(context, msg);
                                                                }

                                                                // If approved or rejected or status is success
                                                                if (newValue == "Approved" || newValue == "Rejected" || status == "200") {
                                                                  setState(() {
                                                                    if (model.selectedvisitStatusList[index] != "Select your decision") {
                                                                      model.loanlistfinal.removeAt(index); // Remove item from loan list
                                                                    }
                                                                    model.selectedvisitStatusList[index] = "Select your decision"; // Reset dropdown value
                                                                  });
                                                                }
                                                              } else {
                                                                print("JSON response is null or 'status' is missing");
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

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
      viewModelBuilder: () => ceo_view_model(),
      onModelReady: (model) => model.init(context),
    );
  }
}
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('en_IN'); // Indian format

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(',', '');
    if (digitsOnly.isEmpty) return newValue;

    try {
      final number = double.parse(digitsOnly);
      final newText = _formatter.format(number);
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } catch (_) {
      return oldValue;
    }
  }
}