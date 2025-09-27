import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import '../../base/utils/constants.dart';
import '../../models/api_response_models/Traval_Expense.dart';
import '../../services/local/base/auth_view_model.dart';
import '../../services/remote/base/api_view_model.dart';


class My_Expense_viewmodel extends ReactiveViewModel  with AuthViewModel, ApiViewModel
{

  List<dynamic> datalist=[];

  List<String?> initial=["Select Status"];
  init(BuildContext context) async {
    await getgoal(context);

    notifyListeners();
  }

  getgoal(BuildContext context,) async {
    try {
      var newsResponse = await runBusyFuture(
          apiService.my_expense(context));
      newsResponse.when(success: (data) async {
        print(data);
        datalist = data['Datalist']!;
        // print("Data: ${data.expenses}");
      }, failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      });

    }  catch(e){
      print(e.toString());
    }

  }

  String formatTravelDistance(String travelString) {
    // Extract number and unit
    final parts = travelString.split(' ');
    if (parts.length != 2) return travelString;

    final number = int.tryParse(parts[0]) ?? 0;
    final unit = parts[1];

    final formatter = NumberFormat('#,###');
    return '${formatter.format(number)} $unit';
  }


}