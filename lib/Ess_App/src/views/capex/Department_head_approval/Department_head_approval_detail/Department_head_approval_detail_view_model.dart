import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../base/utils/constants.dart';
import '../../../../models/api_response_models/Capex_details.dart';
import '../../../../services/local/base/auth_view_model.dart';
import '../../../../services/remote/base/api_view_model.dart';


class Department_head_Capex_detail_view_viewmodel extends ReactiveViewModel  with AuthViewModel, ApiViewModel
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
          apiService.Department_of_head_capex_details(context,copex_id));
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



  copex_quotation_approval(BuildContext context,String copex_id, String copex_product_id , String quotation_id , String vendorprice,String quote_reason ) async {
    try {
      var newsResponse = await runBusyFuture(
          apiService.copex_quotation_approval(context, copex_id, copex_product_id, quotation_id, vendorprice, quote_reason));
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

  void showRemarksDialog(BuildContext context, String copex_id, String copex_product_id,
      String quotation_id,String vendorprice,String quote_reason,) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Remarks"),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Type your remarks here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
            ElevatedButton(
              child: Text("Submit"),
              onPressed: () async {

               await copex_quotation_approval(context, copex_id, copex_product_id, quotation_id, vendorprice,controller.text);

             //      _remarks = _controller.text;
             // notifyListeners();
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }


}