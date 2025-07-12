import 'package:ess/Ess_App/src/base/utils/constants.dart';
import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:ess/Ess_App/src/views/leaves_and_visits/your_visits/widget/your_visits_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../models/api_response_models/List_temperature_sheet.dart';
import '../../models/api_response_models/warehouse_model.dart';

class RecordViewModel extends ReactiveViewModel with AuthViewModel, ApiViewModel
{
  List<Warehousetemp> datalist = [];

  List<String> selectedOption = ['Select Status'];
  List<String> list =  [ "Select Status", 'Approved', "Rejected"];
  DateTime? startDates;
  DateTime? endDates;
  String formattedStartDate='';
  String formattedEndDate='';
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');


  init(BuildContext context) async {
    DateTime now = DateTime.now();

    // Set the first day of the current month
    startDates = DateTime(now.year, now.month, 1);

    // Set the last day of the current month
    endDates = DateTime(now.year, now.month ,now.day);

    // Format them
    formattedStartDate = dateFormat.format(startDates!);
    formattedEndDate = dateFormat.format(endDates!);

    await temp_list(context);

    selectedOption = List.generate(
      datalist.length,
          (index) => "Select Status",
    );

    notifyListeners();
  }



  temp_list(BuildContext context) async
  {
    var newsResponse = await runBusyFuture(apiService.my_records(context,formattedStartDate,formattedEndDate));
    newsResponse.when(success: (data)
    async
    {
      if ((data.datalist?.length ?? 0) > 0) {
        datalist = data.datalist;
        print("Data: ${datalist}");

      }
      else
      {
        datalist =[];

        Constants.customWarningSnack(context, "Not Found");
      }
    },
        failure: (error)
        {


          Constants.customErrorSnack(context, error.toString());
        });
    notifyListeners();
  }

  Delete_record(BuildContext context, String id, int index) async
  {
    var newsResponse = await apiService.Delete_record(context, id);
    newsResponse.when(success: (data)
    async
    {
     if(data['code'] == "200")
       {
         datalist.removeAt(index);
         Constants.customSuccessSnack(context, data['msg']);
         notifyListeners();
       }
      else
      {
        Constants.customWarningSnack(context, "Something went wrong");
      }
    },
        failure: (error)
        {
          Constants.customErrorSnack(context, error.toString());
        });
  }








  approval(BuildContext context,int index, String record, String status) async
  {
    var newsResponse = await apiService.approval_temp(context,record , status);
    newsResponse.when(success: (data) async
    {
      if (data['code'] == "200")
      {
        datalist.removeAt(index);
        Constants.customSuccessSnack(context, data['msg']);
        notifyListeners();
      }
      else
      {
        Constants.customErrorSnack(context, data['msg']);
      }
    },
        failure: (error) {
          Constants.customErrorSnack(context, error.toString());
        }
    );
  }







  void showimage(BuildContext context, String img)
  {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display Network Image with smaller size
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  img,
                  fit: BoxFit.fill, // Use BoxFit.contain to ensure the image stays within the given space
                  // Set a smaller width for the image
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}






