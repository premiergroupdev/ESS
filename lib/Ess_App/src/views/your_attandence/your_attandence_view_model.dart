import 'package:ess/Ess_App/src/base/utils/constants.dart';
import 'package:ess/Ess_App/src/models/api_response_models/attendence.dart';
import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/views/your_attandence/widget/attendence_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class YourAttendanceViewModel extends ReactiveViewModel
    with AuthViewModel, ApiViewModel {
  List<Forms> attendances = [];

  AttendenceTableData heading = AttendenceTableData(
    date: 'Date',
    checkIn: 'Check In',
    checkOut: 'Check Out',
      Attendstatus: 'attend_status',
      formetedDate: DateTime.now()
  );
  List<AttendenceTableData> data = [];

  init(BuildContext context, String check, String code) async {
    await getAttendanceData(context, check, code);

    // // Clear existing data
    // data.clear();
    //
    // Sort attendances by date before processing
    attendances.sort((a, b) {
      DateTime dateA = DateTime.parse(a.attendDate.toString());
      DateTime dateB = DateTime.parse(b.attendDate.toString());
      return dateB.compareTo(dateA); // Descending order (newest first)
      // OR use dateA.compareTo(dateB) for ascending order (oldest first)
    });

    attendances.toList().forEach((element) {
      var timeInputFormat = DateFormat('hh:mm a');
      var datedInputFormat = DateFormat('EE ,dd-MMM');
      DateTime inTime = DateTime.parse("2020-01-02 ${element.checkIn.toString()}");
      var checkIn = timeInputFormat.format(inTime);
      DateTime outTime = DateTime.parse("2020-01-02 ${element.checkOut.toString()}");
      var checkOut = timeInputFormat.format(outTime);
      var date = datedInputFormat.format(DateTime.parse(element.attendDate.toString()));

      // FIX: Check if it's Sunday and override the status
      DateTime attendanceDate = DateTime.parse(element.attendDate.toString());
      String attendstatus;
      if (attendanceDate.weekday == 7) { // 7 = Sunday
        attendstatus = "Weekend";
      } else {
        attendstatus = element.attendStatus.toString();
      }

      data.add(
          AttendenceTableData(
            date: date,
            checkIn: checkIn,
            checkOut: checkOut,
            Attendstatus: attendstatus, // Now shows "Weekend" for Sundays
            formetedDate: attendanceDate,
            statusColor: colorSelection(attendstatus), // Use the corrected status
          )
      );
    });
    notifyListeners();
  }

  Color colorSelection(String title) {
    switch (title) {
      case "Late":
        {
          return Colors.red;
          }
      case "Half Day":
        {
          return Colors.black;
        }
      case "Absent":
        {
          return Colors.orange;
        }
      case "On Time":
        {
          return Colors.green;
        }
      case "Weekend":
        {
          return AppColors.primary;
        }
      default:
        {
          return AppColors.primary;
        }
    }
  }


    getAttendanceData(BuildContext context,String check,String code) async {
    var newsResponse = await runBusyFuture(apiService.attendance(context, check, code: code));
    newsResponse.when(success: (data) async {
      if ((data.forms?.length ?? 0) > 0) {
        attendances = data.forms?.toList() ?? [];
      } else {
        Constants.customWarningSnack(context, "Attendence not found");
      }
    }, failure: (error) {
      Constants.customErrorSnack(context, error.toString());
    });
  }
}
