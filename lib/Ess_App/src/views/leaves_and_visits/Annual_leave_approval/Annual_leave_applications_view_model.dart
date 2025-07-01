import 'package:ess/Ess_App/src/base/utils/constants.dart';
import 'package:ess/Ess_App/src/models/api_form_data_models/leave_form_data.dart';
import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class Annual_leave_applications_ViewModel extends ReactiveViewModel with AuthViewModel, ApiViewModel {


  List<String> leaveTypes = ["sick", "annual", "casual"];
  int typeSelectedIndex = 0;
  DateTime toDateFormat = DateTime.now();
  TextEditingController employeeCode = TextEditingController();
  TextEditingController employeePosition = TextEditingController();
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  TextEditingController leaveReason = TextEditingController();
  String plan_id='';
  String start_date='';
  String end_date='';
  String filled_date='';


  init(BuildContext context) async {
    employeeCode.text = currentUser?.userId.toString() ?? "000000";
    setLeaveApplicationsData(context);
    // String? formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(''));
    // fromDate.text = formattedDate;
    // toDate.text = formattedDate;
  }

  clear() {
    employeePosition.clear();
    fromDate.clear();
    toDate.clear();
    leaveReason.clear();
    typeSelectedIndex = 0;
  }



  setLeaveApplicationsData(BuildContext context) async {
    var newsResponse = await runBusyFuture(apiService.getLeaveApplicationslist(context));

    newsResponse.when(
      success: (data) async {
        print("Raw Data: ${data.toString()}");

        // Parse inner 'your_plans' map
        var yourPlans = data['your_plans'];

        if (yourPlans != null && yourPlans is Map) {
          var plan = yourPlans['0'];

          if (plan != null && plan is Map) {
            print("📦 Plan Details:");
           plan_id= plan['plan_id'];
           start_date= plan['start_date'];
          end_date=  plan['end_date'];
           filled_date = plan['filled_date'];
          } else {
            print("❌ Plan data not found inside your_plans['0']");
          }
        } else {
          print("❌ your_plans not found or not valid format.");
        }
      },
      failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      },
    );
  }

}