import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';

import '../../base/utils/constants.dart';
import '../../models/api_response_models/Traval_Expense.dart';
import '../../services/local/base/auth_view_model.dart';
import '../../services/remote/base/api_view_model.dart';


class Expense_travel_viewmodel extends ReactiveViewModel  with AuthViewModel, ApiViewModel
{

  List<Expense> datalist=[];

  List<String?> initial=["Select Status"];
  init(BuildContext context) async {
    await getgoal(context);
    initial = List.generate(
      datalist.length,
          (index) => "Select Status",);
    notifyListeners();
  }

  getgoal(BuildContext context,) async {
    try {
      var newsResponse = await runBusyFuture(
          apiService.get_travel_expenses(context));
      newsResponse.when(success: (data) async {
        print(data);
        datalist = data.expenses!;
        print("Data: ${data.expenses}");
      }, failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      });

  }  catch(e){
      print(e.toString());
    }

  }
}