import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

import '../../base/utils/constants.dart';
import '../../models/api_response_models/branch.dart';
import '../../models/api_response_models/region.dart';
import '../../services/local/base/auth_view_model.dart';
import '../../services/remote/base/api_view_model.dart';
import 'dart:io';

class LineManagerApprovalViewModel extends ReactiveViewModel with AuthViewModel, ApiViewModel {
  List<dynamic> datalist = [];
  List<dynamic> filterlist = [];
  String? initial="Select Status";
  TextEditingController controller = TextEditingController();
  List<String> list = ["Karachi", "South", "Central", "North"];

  String Selectedvalue = "";
  String selectedValue = ""; // status

  Future<void> init(BuildContext context) async {
    await branchdata(context);
  }

  Future<void> branchdata(BuildContext context) async {
    // ✅ Get emp_code dynamically from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final empCode = prefs.getString('emp_code') ?? '';

    if (empCode.isEmpty) {
      Constants.customErrorSnack(context, "Employee code not found in storage!");
      return;
    }

    var response = await runBusyFuture(apiService.resignations_approval(context, empCode, "line_manager"));
    response.when(
      success: (data) {
        datalist = data['ApprovalList'];
        filterlist = List.from(datalist);
      },
      failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      },
    );
    notifyListeners();
  }

  void search(String value, String searchType) {
    // Update appropriate filter value retaining original casing
    switch (searchType) {
      case "empcode":
        controller.text = value.trim();
        break;
      case "region":
        Selectedvalue = value.trim();
        break;
      case "status":
        selectedValue = value.trim();
        break;
    }

    final empFilter = controller.text.trim().toLowerCase();
    final regionFilter = Selectedvalue.trim().toLowerCase();
    final statusFilter = selectedValue.trim().toLowerCase();

    filterlist = datalist.where((item) {
      final ec = (item['emp_code'] ?? '').toString().toLowerCase();
      final rg = (item['region'] ?? '').toString().toLowerCase();
      final st = (item['final_status'] ?? '').toString().toLowerCase();

      final matchEmp = empFilter.isEmpty || ec.contains(empFilter);
      final matchReg = regionFilter.isEmpty || rg == regionFilter;
      final matchSt = statusFilter.isEmpty || st == statusFilter;

      return matchEmp && matchReg && matchSt;
    }).toList();

    notifyListeners();
  }


}

