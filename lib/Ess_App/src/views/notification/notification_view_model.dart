import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';

import '../../models/api_response_models/Notification.dart';
import '../local_db.dart';
import '../login/local/local_db.dart';

class NotificationViewModel extends ReactiveViewModel with AuthViewModel {


  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
  List<Map<String, dynamic>> list = [];
  DatabaseHelper db=DatabaseHelper();
  List<bool> expandedList = [];
  List<Notification_model> data = [];
  static DatabaseHelpe databaseHelper = DatabaseHelpe();
  void init(BuildContext context) async {
    getData();
  }
  void fetchdata() async {
    list = await db.getlocation();
    print("list: ${list}");
    notifyListeners();
  }

  Future<void> getData() async {
    try {
      var model = await databaseHelper.getnotification();
      model.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

        data = model;
        expandedList = List<bool>.filled(data.length, false); // Initialize expanded state
        print('data: $data');
      notifyListeners();
    } catch (e) {

      print('Error fetching data: $e');
    }
  }


  void toggleExpand(int index) {

      expandedList[index] = !expandedList[index];
   notifyListeners();
  }
}
