import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../base/utils/constants.dart';
import '../../../../models/api_response_models/Capex_approval_model.dart';
import '../../../../models/api_response_models/Capex_details.dart';
import '../../../../services/local/base/auth_view_model.dart';
import '../../../../services/remote/base/api_view_model.dart';




class Gm_Capex_approval_viewmodel extends ReactiveViewModel  with AuthViewModel, ApiViewModel
{

  List<CopexApproval> datalist=[];
  List<Expensedetail> copex_detailslist=[];

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
          apiService.gm_capex_approval(context));
      newsResponse.when(success: (data) async {
        print(data);
        if(data.copexApprovals!.length > 0) {
          datalist = data.copexApprovals!;
          print("Data: ${data.copexApprovals}");
        }
        else {
          Constants.customWarningSnack(context, "Capex Not Found");

        }
      }, failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      });

    }  catch(e, stack){
      print("Stack: ${stack.toString()}");
      print(e.toString());
    }

  }


  getcopex_details(BuildContext context,String copex_id) async {
    try {
      var newsResponse = await runBusyFuture(
          apiService.get_capex_details(context,copex_id));
      newsResponse.when(success: (data) async {
        print(data);
        // copex_detailslist = data;
        // print("Data: ${data.expenses}");
      }, failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      });

    }  catch(e){
      print(e.toString());
    }

  }



  void showApprovalStatusDialog(BuildContext context, {
    required String cordStatus,
    required String hodStatus,
    required String deptHeadStatus,
    required String gmStatus,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Approval Status",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 20),
              _buildStatusRow("Coordinator", cordStatus),
              Divider(),
              _buildStatusRow("HOD", hodStatus),
              Divider(),
              _buildStatusRow("Department Head", deptHeadStatus),

              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(

                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String title, String status) {
    IconData icon;
    Color iconColor;

    switch (status.toLowerCase()) {
      case "approved":
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case "rejected":
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.hourglass_empty;
        iconColor = Colors.orange;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            SizedBox(width: 8),
            Text(
              status[0].toUpperCase() + status.substring(1), // Capitalize
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
      ],
    );
  }


}