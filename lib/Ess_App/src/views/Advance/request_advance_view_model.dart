import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../base/utils/constants.dart';

class RequestAdvanceViewModel extends ReactiveViewModel with AuthViewModel, ApiViewModel {
  TextEditingController Advance_amount = TextEditingController();
  TextEditingController Reason = TextEditingController();

  // User data
  Map<String, dynamic>? userData;
  String? userName;
  String? branch;

  // API headers
  final Map<String, String> _headers = {
    'Authorization': 'Basic UHJFbSFlci5Hcm91cCQkJCsrOkNyRThpVmUmKl4xMjM0NTYrKw==',
    'Pr3mKEY': 'W74=Jse==ZU1JWR158TjJuUjlVN@t3Zz09',
    'Content-Type': 'application/json',
  };

  init(BuildContext context) async {
    setBusy(true);
    await _getUserData();
    setBusy(false);
  }

  // Get user data from auth and API
  Future<void> _getUserData() async {
    try {
      // Get basic user info from auth
      if (authService.user != null) {
        var userJson = (authService.user as dynamic).toJson();
        userName = userJson['userName']?.toString();

        // Get employee code for API call
        String? empCode = userJson['userId']?.toString();

        print('👤 UserName from auth: $userName');
        print('🆔 Employee Code from auth: $empCode');

        if (empCode != null && empCode.isNotEmpty) {
          await _fetchUserDetailsFromAPI(empCode);
        } else {
          print('❌ No employee code found in auth service');
        }
      } else {
        print('❌ User is null in authService');
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error getting user data: $e');
    }
  }

  // Fetch user details from POST API with query parameter
// Fetch user details from POST API with query parameter
  Future<void> _fetchUserDetailsFromAPI(String empCode) async {
    try {
      print('🔄 Calling POST API with EmpCode: $empCode');

      // POST request with query parameter in URL
      final response = await http.post(
        Uri.parse('http://pg-ERPBI.premiergroup.com.pk:7060/api/Worker/GetErpEmployees?EmpCode=$empCode&EmpType=1'),
        headers: _headers,
        // Empty body since parameter is in URL
        body: json.encode({}),
      );

      print('📡 API Response Status: ${response.statusCode}');
      print('📦 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ API Success - Full Response: $jsonResponse');

        if (jsonResponse['status_Code'] == 200 &&
            jsonResponse['response'] != null &&
            jsonResponse['response'].length > 0) {
          userData = jsonResponse['response'][0];
          branch = userData?['branch'];

          print('✅ User Data: $userData');
          print('✅ Branch extracted: $branch');

          notifyListeners();
        } else {
          print('❌ API returned error: ${jsonResponse['status_Message']}');
        }
      } else {
        print('❌ API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in API call: $e');
    }
  }

  clear() {
    Advance_amount.clear();
    Reason.clear();
  }

  Future<void> applyrequest_advanced(BuildContext context) async {
    if (Advance_amount.text.isEmpty || Reason.text.isEmpty) {
      Constants.customErrorSnack(context, "Please fill in all fields");
      return;
    }

    var newsResponse = await runBusyFuture(apiService.applyrequestadvancec(
      context,
      Advance_amount.text,
      Reason.text,
    ));

    newsResponse.when(
      success: (data) {
        if (data == "Advance Successfully Submitted") {
          clear();
          Constants.customSuccessSnack(context, data);
        } else {
          Constants.customErrorSnack(context, data);
        }
      },
      failure: (error) {
        Constants.customErrorSnack(context, error.toString());
      },
    );
  }

  @override
  void dispose() {
    Advance_amount.dispose();
    Reason.dispose();
    super.dispose();
  }
}