import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import '../../../../base/utils/constants.dart';
import '../../../../models/api_response_models/Capex_details.dart';
import '../../../../services/local/base/auth_view_model.dart';
import '../../../../services/remote/base/api_view_model.dart';


class Capex_detail_view_viewmodel extends ReactiveViewModel  with AuthViewModel, ApiViewModel
{

  List<Expensedetail> copex_detailslist=[];
  late List<String?> selectedOption;

String emp_code='';

String? initial="Select Status";
TextEditingController remarkscontroller =TextEditingController();
  init(BuildContext context, String copex_id) async
  {
    await getcopex_details(context,copex_id);
    notifyListeners();
  }




  getcopex_details(BuildContext context,String copex_id) async {
    try {
      var newsResponse = await runBusyFuture(
          apiService.get_capex_details(context,copex_id));
      newsResponse.when(success: (data) async {
        if(data.expenses.length >0) {
          print(data);
          copex_detailslist = data.expenses;
          selectedOption = copex_detailslist[0].copexItems
              .map((item) => item.is_exp) // assuming is_exp is "Yes" or "No"
              .toList();
          // final grandTotal = double.tryParse(model.copex_detailslist[0].grandtotal) ?? 0.0;
          // final formattedTotal = NumberFormat('#,##0.00').format(grandTotal);
          print("Data: ${data.expenses}");
        }
        else {
          Constants.customErrorSnack(context, "No Capex Found");

        }
      }, failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      });

    }  catch(e, stack){
      print(stack.toString());

      print(e.toString());
    }

  }
}