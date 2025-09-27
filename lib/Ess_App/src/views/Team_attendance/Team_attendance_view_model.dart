import 'package:ess/Ess_App/src/base/utils/constants.dart';
import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class Team_attendance_ViewModel extends ReactiveViewModel with AuthViewModel, ApiViewModel {


  var datalist;




  init(BuildContext context) async {
    setLeaveApplicationsData(context);
    // String? formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(''));
    // fromDate.text = formattedDate;
    // toDate.text = formattedDate;
  }

  // clear() {
  //   employeePosition.clear();
  //   fromDate.clear();
  //   toDate.clear();
  //   leaveReason.clear();
  //   typeSelectedIndex = 0;
  // }



  setLeaveApplicationsData(BuildContext context) async {
    var newsResponse = await runBusyFuture(apiService.team_attendance(context));

    newsResponse.when(
      success: (data) async {
        if(data['status_code'] == "200") {
          datalist = data['TeamMembers'];
        }
        else {
          Constants.customWarningSnack(context, "Attendance not found");

          datalist =[];
        }

      },
      failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      },
    );
  }

}