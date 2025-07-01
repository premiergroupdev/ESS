import 'package:ess/Ess_App/src/shared/bottons.dart';
import 'package:ess/Ess_App/src/shared/input_field.dart';
import 'package:ess/Ess_App/src/shared/spacing.dart';
import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/views/leaves_and_visits/apply_leave/apply_leave_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import 'Annual_leave_approval_view_model.dart';

class Annual_leave_View extends StatelessWidget {
  final String? date;
  const Annual_leave_View({Key? key, this.date}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<Annual_leave_ViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        body:

        SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "Annual Leave Planner",
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();},

                  onNotificationTap: () {}
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Form(
                      child: Builder(
                          builder: (ctx) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Submit your Annual Leave Planner",style: TextStyle(fontSize: 19),  textAlign: TextAlign.center,),

                                VerticalSpacing(20),
                                SecondInputField(
                                  label: 'From Date',
                                  hint: 'Select From Date',
                                  controller: model.fromDate,
                                  inputType: TextInputType.datetime,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2022),
                                        lastDate: DateTime(2100));


                                    if (pickedDate != null) {
                                      model.toDateFormat = pickedDate;
                                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                      model.fromDate.text = formattedDate;
                                      model.notifyListeners();
                                    } else {

                                    }
                                  },
                                  message: 'Please select from Date',
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                VerticalSpacing(20),
                                SecondInputField(
                                  label: 'To Date',
                                  hint: 'Select To Date',
                                  controller: model.toDate,
                                  inputType: TextInputType.datetime,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: model.toDateFormat,
                                        firstDate: DateTime(2022),
                                        lastDate: DateTime(2100));

                                    if (pickedDate != null) {
                                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                      model.toDate.text = formattedDate;
                                      model.notifyListeners();
                                    } else {

                                    }
                                  },
                                  message: 'Please select to date',
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),

                                VerticalSpacing(20),
                                MainButton(
                                    text: "Apply",
                                    isBusy: model.isBusy,
                                    onTap: () {
                                      model.apply(ctx);
                                    }),
                                VerticalSpacing(20),
                              ],
                            );
                          }
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      viewModelBuilder: () => Annual_leave_ViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}
