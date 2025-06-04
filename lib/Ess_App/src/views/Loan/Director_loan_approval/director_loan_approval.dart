import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import '../../../base/utils/constants.dart';
import '../../../models/api_response_models/Hod_loan_approval.dart';
import '../../../models/api_response_models/director_model.dart';
import '../../../services/remote/api_result.dart';
import '../../../services/remote/api_service.dart';
import '../../../shared/top_app_bar.dart';
import '../../../styles/app_colors.dart';
import '../../dashboard/widget/available_leaves_chart.dart';
import '../../your_attandence/widget/dropdown.dart';
import '../customsearchabledropdown.dart';
import '../webview.dart';
import 'director_loan_approval_view_model.dart';

class director_loan_approval extends StatefulWidget {
  @override
  State<director_loan_approval> createState() => _Pending_guaranteesState();
}


class _Pending_guaranteesState extends State<director_loan_approval> {
  @override
  Widget build(BuildContext context) {


    return ViewModelBuilder<director_loan_view_model>.reactive(
      builder: (viewModelContext, model, child) =>
          Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GeneralAppBar(
                        title: "Direcctor loan for Approval",
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
                              directorForm data = model.loanlistfinal[index];

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
                                      color: Colors.white,
                                      borderRadius: BorderRadius
                                          .circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),  // Shadow color with opacity
                                        offset: Offset(4, 4),  // Shadow position (x, y)
                                        blurRadius: 8,         // How blurry the shadow is
                                        spreadRadius: 2,       // How far the shadow spreads
                                      ),
                                    ],
                              ),
                                  margin: EdgeInsets.fromLTRB(
                                      20, 10, 20, 5),
                                  padding: EdgeInsets.all(16),
                                  child: Column(children: [

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Loan type: ",  style: GoogleFonts.poppins(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600


                                        ),),
                                         Container(
                                           width: 200,

                                           child: CustomSearchableDropDown(
                                              items: model.finalApprovalData,
                                              label: model.selectedValue[index],
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                border: Border.all(color: AppColors.primary),
                                              ),
                                              // prefixIcon: const Padding(
                                              //   padding: EdgeInsets.all(0.0),
                                              //   child: Icon(Icons.search),
                                              // ),
                                              dropDownMenuItems: model.finalApprovalData
                                                  .map((item) => item.loanTypeName)
                                                  .toList(),
                                              onChanged: (value) {
                                                FocusScope.of(context).unfocus();
                                                if (value != null) {
                                                  setState(()  {
                                                    model.selectedValue[index] = value.loanTypeId.toString();
                                                    print("Selected value: ${model.selectedValue[index]}");
                                                    model.updateloantype(context, data.loanId, index);
                                                  });
                                                }
                                              },
                                            ),
                                         ),
                                        
                                      ],
                                    ),



                                    SizedBox(height: 20,),
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
                                            text: '${data.empName}',
                                            style: GoogleFonts.poppins(
                                               color: AppColors.primary,
                                              fontWeight: FontWeight.w600


                                            ),
                                          ),

                                          TextSpan(
                                            text: 'has applied for a loan of ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: '${data.loanAmount} Rs.\n',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),

                                          TextSpan(
                                            text: 'Designation: ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: '${data.position}\n',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),

                                          TextSpan(
                                            text: 'Department: ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: '${data.department}\n',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),

                                          TextSpan(
                                            text: 'Date of Joining: ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: '${data.doj}\n',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Purpose: ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: '${data.purpose}\n\n',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'He will repay the loan in ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: '${data.totalInstallment} ',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'equal installments of ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: '${data.perMonthRepay} Rs.\n',
                                            style: GoogleFonts.poppins(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600


                                            ),
                                          ),



                                          if (data.empShare.isNotEmpty)
                                            TextSpan(
                                              text: 'Employee Share: ${data.empShare}\n',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.black,


                                              ),
                                            ),
                                          if (data.cmpShare.isNotEmpty)
                                            TextSpan(
                                              text: 'Company Share: ${data.cmpShare}\n',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.black,


                                              ),
                                            ),
                                          if (data.prvBalance.isNotEmpty)
                                            TextSpan(
                                              text: 'Previous Balance: ${data.prvBalance}\n\n',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.black,


                                              ),
                                            ),

                                          TextSpan(
                                            text: 'Do you want to change this amount and tenure? ',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.black,


                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Edit',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext contexts) {
                                                    return AlertDialog(
                                                      title: Text('Edit Form', textAlign: TextAlign.center,),
                                                      content: Container(
                                                        height: 400,  // Reduced height
                                                        child: SingleChildScrollView(
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
                                                              SizedBox(height: 10,),
                                                              Text("Loan Distribution", style: TextStyle(
                                                                  fontSize: 18

                                                              ),textAlign: TextAlign.start,),
                                                              SizedBox(height: 10,),
                                                              TextFormField(
                                                                keyboardType: TextInputType.number,
                                                                controller:model.from_company[index],
                                                                decoration: InputDecoration(
                                                                  labelText: 'From company',
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
                                                                controller:model.from_employee_pf[index],
                                                                decoration: InputDecoration(
                                                                  labelText: 'From employee pf',
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
                                              },
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10,),
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
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(8)),
                                            child: Text(
                                              "See Attachments",
                                              style: TextStyle(
                                                fontSize: 11,
                                                  color: Colors.white),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
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
                                              width: 2.0, // Border width when focused
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
SizedBox(height: 7,),
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
                                                  .director_loan_approved(
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

                                                        model.loanlistfinal.removeAt(
                                                            index);
                                                      model
                                                          .selectedvisitStatusList[index] =
                                                      "Select your decision";
                                                    });
                                                  }
                                                } else {
                                                  print(
                                                      "JSON response is null or 'status' is missing");
                                                }
                                              }
                                            },
                                          ),
                                        )

                                      ],
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
      viewModelBuilder: () => director_loan_view_model(),
      onModelReady: (model) => model.init(context),
    );
  }
}
