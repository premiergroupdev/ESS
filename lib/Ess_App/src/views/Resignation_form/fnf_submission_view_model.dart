import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';

import '../../base/utils/constants.dart';
import '../../models/api_response_models/branch.dart';
import '../../models/api_response_models/region.dart';
import '../../services/local/base/auth_view_model.dart';
import '../../services/remote/base/api_view_model.dart';
import 'dart:io';

class Fnf_viewModel extends ReactiveViewModel with  AuthViewModel, ApiViewModel {

  List<dynamic> datalist = [];



  TextEditingController qty = TextEditingController();



  init(BuildContext context) async {
    branchdata(context);
  }


  Future<void> branchdata(BuildContext context) async {
    var newsResponse = await runBusyFuture(apiService.fnf_submission(context));
    newsResponse.when(
      success: (data) {
        // Append data to finalApprovalData
        datalist=data['Datalist'];
        print(datalist);

      },
      failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      },
    );
  }
}




