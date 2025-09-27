import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';

import '../../base/utils/constants.dart';

class AdvanceViewModel extends ReactiveViewModel with AuthViewModel, ApiViewModel{

  TextEditingController Advance_amount = TextEditingController();
  TextEditingController Reason = TextEditingController();
  List<dynamic> dataList= [];
  init(BuildContext context) async {
    setBusy(true);
    applyrequest_advanced(context);
    setBusy(false);
  }
  clear(){
    Advance_amount.clear();
    Reason.clear();
  }
  Future<void> applyrequest_advanced(BuildContext context) async {
    var newsResponse = await runBusyFuture(apiService.advanc_list(context));
    newsResponse.when(
        success: (data) {
          if(data['Datalist'] != []) {
            dataList = data['Datalist'];
            print(data);
          }
          else {
            Constants.customWarningSnack(context, "Advance not found");
            dataList = [];
          }
        },
        failure: (error) {
          Constants.customErrorSnack(context, error.toString());
        });
  }




}


