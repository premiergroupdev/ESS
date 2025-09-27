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

class AccountsPopupDialog extends StatefulWidget {
  final List<dynamic> datalist;
  final List<dynamic> hodlist;
  final String name;
  final String fnf_id;
  AccountsPopupDialog({Key? key, required this.hodlist, required this.name , required this.fnf_id, required this.datalist}) : super(key: key);

  @override
  State<AccountsPopupDialog> createState() => _ProfessionalPopupDialogState();
}

class _ProfessionalPopupDialogState extends State<AccountsPopupDialog> {
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedStatus;
  List<dynamic> memberlist=[];
  bool _isLoading = false;
  bool _showDropdown = false;
  AuthService? authService;

  AuthService _authService = locator<AuthService>();
  User? get
  currentUser => _authService.user;

  void _selectItem(dynamic item) {
    setState(() {
      searchController.text = "${item['member_name']} - ${item['member_code']}" ?? item.toString();
      _showDropdown = false;
    });
    // Yahan selected item ka kaam kar sakte hain
    print('Selected: ${item['member_name']}');
  }



  Future<void> Apicall2() async {




    final url = Uri.parse(
      'https://premierspulse.com/ess/scripts/update_fnf_linemanager.php'
          '?fnf_id=${widget.fnf_id}'
          '&username=${currentUser?.userName.toString()}'
          '&status=${_selectedStatus == "Accept" ? "approved" : "rejected"}'
          '&approval_type=account'
          '&erp_code=${_commentsController.text}'
    );
    print('https://premierspulse.com/ess/scripts/update_fnf_linemanager.php'
        '?fnf_id=${widget.fnf_id}'
        '&username=${currentUser?.userName.toString()}'
        '&status=${_selectedStatus == "Accept" ? "approved" : "rejected"}'
        '&approval_type=account'
        '&erp_code=${_commentsController.text}');
       // '&comments=${_commentsController.text}',);

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
          widget.datalist.removeWhere((item) => item['fnf_id'].toString() == widget.fnf_id.toString());
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



  // Future<void> Apicall2() async {
  //
  //
  //
  //   final url = Uri.parse(
  //     'https://premierspulse.com/ess/scripts/update_fnf_linemanager.php'
  //         '?fnf_id=${widget.fnf_id}'
  //         '&username=${currentUser?.userName.toString()}'
  //         '&status=${_selectedStatus == "Accept" ? "approved" : "rejected"}'
  //         '&comments=${_commentsController.text}',
  //   );
  //   print('https://premierspulse.com/ess/scripts/update_fnf_linemanager.php'
  //       '?fnf_id=${widget.fnf_id}'
  //       '&username=${currentUser?.userName.toString()}'
  //       '&status=${_selectedStatus == "Accept" ? "approved" : "rejected"}'
  //       '&comments=${_commentsController.text}',);
  //
  //   try
  //   {
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200)
  //     {
  //       print('Success: ${response.body}');
  //       var data = jsonDecode(response.body);
  //       if(data['status'] == 200)
  //       {
  //         Navigator.of(context).pop(true);
  //         Constants.customSuccessSnack(context, data['status_message']);
  //         widget.datalist.removeWhere((item) => item['fnf_id'].toString() == widget.fnf_id.toString());
  //       }
  //       else
  //       {
  //         Constants.customErrorSnack(context, data['status_message']);
  //       }
  //     }
  //
  //     else {
  //       print('Failed with status: ${response.statusCode}');
  //     }
  //   }
  //   catch (e) {
  //     print('Error: $e');
  //   }
  // }



  Future<void> search_memeber(String value) async {
    if (value.isEmpty) {
      setState(() {
        memberlist.clear();
        _showDropdown = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showDropdown = false; // hide until data is ready
    });

    final url = Uri.parse(
        'https://premierspulse.com/ess/scripts/fetch_hod_list.php?emp_code=99935751&search_name=$value'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          memberlist = data['Datalist'];
          _showDropdown = memberlist.isNotEmpty;
        });
      } else {
        print('Failed with status: ${response.statusCode}');
        setState(() {
          memberlist = [];
          _showDropdown = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        memberlist = [];
        _showDropdown = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  final List<String> _categories = [
    'General Inquiry',
    'Technical Issue',
    'Feature Request',
    'Bug Report',
    'Feedback',
    'Other'
  ];

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
                        'Erp Code',
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
                          inputFormatters: [],
                          controller: _commentsController,

                          decoration: const InputDecoration(

                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintText: 'Enter your Erp Code...',
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
                              // _selectedStatus != null &&
                              // _commentsController.text.isNotEmpty
                              // ?
                                  ( ) {
                                print("Hello");
                                submitForm1();
                              }
                              // : null
                              ,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:AppColors.primary,
                                padding:  EdgeInsets.symmetric(vertical: 16),
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
    if (_commentsController.text.isNotEmpty && _selectedStatus != null) {
      print("Username: ${currentUser?.userName.toString()}");


      Apicall2();
    } else {
      print("Username: ${currentUser?.userName.toString()}");
      Constants.customWarningSnack(context, "Please fill all fields");
    }
  }

}