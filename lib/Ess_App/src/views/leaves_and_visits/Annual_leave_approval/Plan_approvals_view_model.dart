import 'package:ess/Ess_App/src/base/utils/constants.dart';
import 'package:ess/Ess_App/src/models/api_response_models/leave_applications.dart';
import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/views/leaves_and_visits/your_leave_aplications/widget/leave_aplications_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../models/api_response_models/plan_approval_model.dart';

class Plan_approval_ViewModel extends ReactiveViewModel
    with AuthViewModel, ApiViewModel {

  List<PlanApproval> plan = [];
  List<String?> selectedvisitStatusList=["Select your decision"];

  List<String> dropdownValues = ["Select your decision", "Approved", "Rejected"];
  void resetSelectedStatus(int index) {


      selectedvisitStatusList[index] = "Select your decision";
    notifyListeners();
  }
  LeaveApplicationsTableData heading = LeaveApplicationsTableData(
      appliedDate: "Date",
      totalDays: "Total Days",
      sick: "Sick",
      casual: "Casual",
      annual: "Annual",
      startDate: "Start At",
      endDate: "End At");
  List<LeaveApplicationsTableData> data = [];


  init(BuildContext context) async {
    await getLeaveApplicationsData(context);
    selectedvisitStatusList = List.generate(plan.length, (index) => "Select your decision",);


    notifyListeners();
  }



  getLeaveApplicationsData(
      BuildContext context,
      ) async {
    var newsResponse =
    await runBusyFuture(apiService.plan_approval(context));
    newsResponse.when(success: (data) async {
      if ((data.approvals?.length ?? 0) > 0) {
        plan = data.approvals;
      } else {
        Constants.customWarningSnack(context, "Plans not found");
      }
    }, failure: (error) {
      Constants.customErrorSnack(context, error.toString());
    });
  }
}
