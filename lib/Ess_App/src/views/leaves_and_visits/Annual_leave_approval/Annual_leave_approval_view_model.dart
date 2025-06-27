import 'package:ess/Ess_App/src/base/utils/constants.dart';
import 'package:ess/Ess_App/src/models/api_form_data_models/leave_form_data.dart';
import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class Annual_leave_ViewModel extends ReactiveViewModel with AuthViewModel, ApiViewModel

{


  List<String> leaveTypes = ["sick", "annual", "casual"];
  int typeSelectedIndex = 0;
  DateTime toDateFormat = DateTime.now();
  TextEditingController employeeCode = TextEditingController();
  TextEditingController employeePosition = TextEditingController();
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  TextEditingController leaveReason = TextEditingController();


  init(BuildContext context) async {
    employeeCode.text = currentUser?.userId.toString() ?? "000000";
    // String? formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(''));
    // fromDate.text = formattedDate;
    // toDate.text = formattedDate;
  }

  clear()
  {
    employeePosition.clear();
    fromDate.clear();
    toDate.clear();
    leaveReason.clear();
    typeSelectedIndex = 0;
  }

  apply(BuildContext context) async {
    if(m.Form.of(context).validate()) {
      await setLeaveApplicationsData(context);
    }
  }

  setLeaveApplicationsData(BuildContext context,) async
  {
    LeaveFormData formData = LeaveFormData(
        fromDate: fromDate.text,
        toDate: toDate.text,
        leaveType: leaveTypes[typeSelectedIndex],
        empCode: employeeCode.text,
        empPosition: employeePosition.text,
        leaveReason: leaveReason.text
    );
    var newsResponse = await runBusyFuture(apiService.applyannualLeave(context,formData));
    newsResponse.when(success: (data) async
    {
      print("Data:${data}");
      if (data["status"] == "200") {
        clear();
        Constants.customSuccessSnack(context, data['status_message']);
      }
      else if(data['status'] =="400")
      {
        print(data['status_message']);
        Constants.customErrorSnack(context,data['status_message']);
      }
      else
      {
        Constants.customErrorSnack(context, "Your Application Not Submit, Try Again");
      }
    }, failure: (error)
    {
      Constants.customErrorSnack(context, error.toString());
    });
  }
}
