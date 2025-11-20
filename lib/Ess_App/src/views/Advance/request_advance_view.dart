import 'package:ess/Ess_App/src/views/Advance/request_advance_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../base/utils/constants.dart';
import '../../shared/bottons.dart';
import '../../shared/input_field.dart';
import '../../shared/spacing.dart';
import '../../shared/top_app_bar.dart';

class requestadvance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final isBefore15th = currentDate.day <= 15;

    return ViewModelBuilder<RequestAdvanceViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                title: "Request Advance",
                onMenuTap: () {
                  Scaffold.of(context).openDrawer();
                },
                onNotificationTap: () {},
              ),
              if (isBefore15th)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "Advance Facility Will Be Enable After 15th Of Every Month",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User info section
                          if (model.userName != null && model.branch != null)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                children: [
                                  // English version (Default LTR)
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: "Dear ${model.userName}, your current branch is "),
                                        TextSpan(
                                          text: model.branch,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: ". Please confirm if it's correct before filling the Advance Form."),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  // Urdu version (Added textDirection: TextDirection.rtl)
                                  RichText(
                                    textAlign: TextAlign.center,
                                    // ***Crucial for Urdu (RTL)***
                                    textDirection: TextDirection.rtl,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                        // You might also consider setting the font family to one that supports Urdu/Nastaliq
                                        // if you are using custom fonts, but the default should work for basic display.
                                      ),
                                      children: [
                                        TextSpan(text: "محترم "),
                                        TextSpan(
                                          text: model.userName,
                                          style: TextStyle(
                                            color: Colors.blue[800],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(text: "، آپ کا موجودہ برانچ "),
                                        TextSpan(
                                          text: model.branch,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: " ہے۔ براہ کرم ایڈوانس فارم بھرنے سے پہلے تصدیق کریں کہ یہ درست ہے۔"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (model.userName != null)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange[100]!),
                              ),
                              child: Text(
                                "Dear ${model.userName}, please fill the Advance Form below.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          SecondInputField(
                            label: 'Advance Amount',
                            hint: 'Enter Amount',
                            controller: model.Advance_amount,
                            inputType: TextInputType.number,
                            onTap: () {},
                            message: 'Please enter advance amount',
                          ),

                          VerticalSpacing(20),

                          SecondInputField(
                            label: 'Reason',
                            hint: 'Enter Reason for Advance',
                            controller: model.Reason,
                            inputType: TextInputType.text,
                            onTap: () {},
                            message: 'Please enter reason for advance',
                          ),

                          VerticalSpacing(30),

                          MainButton(
                            text: "Apply for Advance",
                            isBusy: model.isBusy,
                            onTap: () {
                              if (model.Advance_amount.text.isNotEmpty &&
                                  model.Reason.text.isNotEmpty) {
                                model.applyrequest_advanced(context);
                              } else {
                                Constants.customErrorSnack(
                                    context,
                                    "Please fill in all fields"
                                );
                              }
                            },
                          ),

                          VerticalSpacing(20),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => RequestAdvanceViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}