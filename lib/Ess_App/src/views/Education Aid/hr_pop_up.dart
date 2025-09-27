import 'dart:async';
import 'package:ess/Ess_App/src/views/local_db.dart';
import 'package:ess/Ess_App/src/services/local/auth_service.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/views/Profile_screen/Change_thumb_recognition.dart';
import 'package:flutter/material.dart';
import 'package:ess/Ess_App/src/services/remote/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/api_response_models/user.dart';

import '../../base/utils/constants.dart';
import '../../configs/app_setup.locator.dart';

class HrPopupDialog extends StatefulWidget {
  final List<dynamic> datalist;

  final String name;
  final String fnf_id;
  final String title;
  HrPopupDialog({Key? key, required this.name , required this.title, required this.fnf_id, required this.datalist}) : super(key: key);

  @override
  State<HrPopupDialog> createState() => _ProfessionalPopupDialogState();
}

class _ProfessionalPopupDialogState extends State<HrPopupDialog> {
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController hodcode_controller = TextEditingController();
  String? _selectedStatus;
  List<dynamic> memberlist=[];

  AuthService? authService;

  AuthService _authService = locator<AuthService>();
  User? get
  currentUser => _authService.user;









  Future<void> Apicall2() async {



    final url = Uri.parse(
      'https://premierspulse.com/ess/scripts/update_education_aid_status.php'
          '?aid_id=${widget.fnf_id}'
          '&username=${currentUser?.userName.toString()}'
          '&status=${_selectedStatus == "Accept" ? "approved" : "rejected"}'
          '&approval_type=hr_approval'
          '&hod_code=${hodcode_controller.text}'
          '&comments=${_commentsController.text}',
    );
    print('https://premierspulse.com/ess/scripts/update_education_aid_status.php'
        '?aid_id=${widget.fnf_id}'
        '&username=${currentUser?.userName.toString()}'
        '&status=${_selectedStatus == "Accept" ? "approved" : "rejected"}'
        '&approval_type=hr_approval'
        '&hod_code=${hodcode_controller.text}'
        '&comments=${_commentsController.text}',);

    try
    {
      final response = await http.get(url);

      if (response.statusCode == 200)
      {
        print('Success: ${response.body}');
        var data = jsonDecode(response.body);
        if(data['status'] == 200)
        {
          Navigator.of(context).pop(true);
          Constants.customSuccessSnack(context, data['status_message']);
          widget.datalist.removeWhere((item) => item['aid_id'].toString() == widget.fnf_id.toString());
        }
        else
        {
          Constants.customErrorSnack(context, data['status_message']);
        }
      }

      else {
        print('Failed with status: ${response.statusCode}');
      }
    }
    catch (e) {
      print('Error: $e');
    }
  }


  final List<String> _statusOptions = [
    'Accept',
    'Reject'
  ];

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return

      Dialog(

        backgroundColor: Colors.transparent,
        child:

        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.85, // Ensuring the dialog doesn't take up too much space
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset:  Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding:  EdgeInsets.all(24),
                  decoration:  BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child:
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_note,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submit Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Please provide your feedback',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: 10),
                      // Comments TextBox
                      const Text(
                        'HOD Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: hodcode_controller,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintText: 'Enter code here...',
                            hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF2D3748),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                      // Comments TextBox
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _commentsController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintText: 'Enter your comments here...',
                            hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF2D3748),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Status Dropdown
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintText: 'Select status',
                            hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF6B73FF),
                          ),
                          items: _statusOptions.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: status == 'Accept'
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    status,
                                    style: const TextStyle(
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedStatus = value;

                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side:  BorderSide(color: Color(0xFFE2E8F0)),
                                padding:  EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:  Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF718096),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),


                          Expanded(
                            child: ElevatedButton(
                              onPressed:


                              // _selectedCategory != null &&
                              //     _selectedStatus != null &&
                              //     _commentsController.text.isNotEmpty
                              //     ?
                              //
                                  () {
                                print("Hello");
                                submitForm1();
                              },
                              // : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:AppColors.primary,
                                padding:EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )


                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      );
  }





  void submitForm1() {
    if (_commentsController.text.isNotEmpty && _selectedStatus != null && hodcode_controller.text.isNotEmpty) {
      print("Username: ${currentUser?.userName.toString()}");

      print(widget.title);
      Apicall2();
    } else {
      print("Username: ${currentUser?.userName.toString()}");
      Constants.customWarningSnack(context, "Please fill all fields");
    }
  }

}