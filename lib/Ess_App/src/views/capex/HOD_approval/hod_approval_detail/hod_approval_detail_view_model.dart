import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../base/utils/constants.dart';
import '../../../../models/api_response_models/Capex_details.dart';
import '../../../../services/local/base/auth_view_model.dart';
import '../../../../services/remote/base/api_view_model.dart';
import '../../../../styles/app_colors.dart';


class Hod_Capex_detail_view_viewmodel extends ReactiveViewModel  with AuthViewModel, ApiViewModel
{

  List<Expensedetail> copex_detailslist=[];
  String emp_code='';
  // String selectedOption = 'Option 1';
  late List<String?> selectedOption;
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
          apiService.hod_capex_details(context,copex_id));
      newsResponse.when(success: (data) async {
        print(data);
        copex_detailslist = data.expenses;
        selectedOption = copex_detailslist[0].copexItems
            .map((item) => item.is_exp) // assuming is_exp is "Yes" or "No"
            .toList();
        // final grandTotal = double.tryParse(model.copex_detailslist[0].grandtotal) ?? 0.0;
        // final formattedTotal = NumberFormat('#,##0.00').format(grandTotal);
        print("Data: ${data.expenses}");
      }, failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      });

    }  catch(e, stack){
      print(stack.toString());

      print(e.toString());
    }

  }


  expenditure(BuildContext context,String product_id,String status) async {
    try {
      var newsResponse = await runBusyFuture(
          apiService.update_copex_expenditure(context,product_id,status));
      newsResponse.when(success: (data) async {
        print(data);
        if(data['status'] == 200) {
          Constants.customSuccessSnack(context, data['status_message']);
        }
        else {
          Constants.customErrorSnack(context, data['status_message']);
        }


        // final grandTotal = double.tryParse(model.copex_detailslist[0].grandtotal) ?? 0.0;
        // final formattedTotal = NumberFormat('#,##0.00').format(grandTotal);
      }, failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      });

    }  catch(e, stack)
    {
      print(stack.toString());

      print(e.toString());
    }

  }




  void showSpecsDialog(BuildContext context, String specs) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Shrinks the size of the dialog based on content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Specifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,  // You can use your custom color
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  specs,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("close")
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  String selectedValue = 'Option 1'; // Default value
  List<String> dropdownItems = ['Option 1', 'Option 2', 'Option 3'];

  void ExpandetureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String tempSelectedValue = selectedValue;

        return AlertDialog(
          title: Text('Select an Option'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                isExpanded: true,
                value: tempSelectedValue,
                items: dropdownItems.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    tempSelectedValue = newValue!;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {

                selectedValue = tempSelectedValue;
                notifyListeners();
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }



  void showQuotationDialog({
    required BuildContext context,
    required String vendor,
    required String description,
    required double price,
    required int qty,
    required bool isSelected,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// Top Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vendor,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: Colors.green, size: 22),
                  ],
                ),

                const SizedBox(height: 16),

                /// Quotation URL (Clickable)
                InkWell(
                  onTap: () async {
                    final Uri uri = Uri.parse(description);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch URL')),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Price & Quantity Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Price: ₹${price.toStringAsFixed(0)}    |    Qty: $qty",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Close Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.redAccent),
                    label: Text(
                      "Close",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}