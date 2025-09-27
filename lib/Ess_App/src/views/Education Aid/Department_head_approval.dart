import 'package:ess/Learning_management_system/Utilis/colors.dart';
import 'package:flutter/material.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../configs/app_setup.locator.dart';
import '../../services/local/auth_service.dart';
import '../../shared/spacing.dart';
import '../../shared/top_app_bar.dart';
import '../../styles/app_colors.dart';
import '../../models/api_response_models/user.dart';

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'hod_pop_up.dart';
import 'hr_pop_up.dart';

class DepartmentHeadAidDataScreen extends StatefulWidget {
  const DepartmentHeadAidDataScreen({super.key});

  @override
  State<DepartmentHeadAidDataScreen> createState() => _AidDataScreenState();
}

class _AidDataScreenState extends State<DepartmentHeadAidDataScreen> {
  List<dynamic> aidDataList = [];
  bool isLoading = true;
  AuthService? authService;


  AuthService _authService = locator<AuthService>();

  User? get
  currentUser => _authService.user;

  @override
  void initState() {
    super.initState();
    fetchAidData();
  }

  Future<void> fetchAidData() async {
    final url = Uri.parse(
        'https://premierspulse.com/ess/scripts/fetch_my_aid.php?EMPCODE=${currentUser?.userId.toString()}&api_type=dept_head');
    final headers = {
      'Authorization': 'Basic Basic RVNTOngyRnN0VnN5eg==',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          print("Data: ${data}");
          aidDataList = data['aiddata'] ?? [];
          print(aidDataList);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          VerticalSpacing(10),
          GeneralAppBar(
            title: "Deparment Head Approval",
            onMenuTap: () {
              Scaffold.of(context).openDrawer();
            },
            onNotificationTap: () {},
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : aidDataList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: aidDataList.length,
              itemBuilder: (context, index) {
                final item = aidDataList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with Aid ID and Case Type
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "Aid ID: ${item["aid_id"] ?? ''}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    (item["case_type"] ?? '').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Employee Info Section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary.withOpacity(0.8),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.transparent,
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["employee_name"] ?? '',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          item["designation"] ?? '',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // // Student Information
                            // Container(
                            //   padding: const EdgeInsets.all(16),
                            //   decoration: BoxDecoration(
                            //     color: Colors.blue.shade50,
                            //     borderRadius: BorderRadius.circular(16),
                            //     border: Border.all(
                            //       color: Colors.blue.shade200,
                            //       width: 1,
                            //     ),
                            //   ),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Row(
                            //         children: [
                            //           Icon(
                            //             Icons.school_rounded,
                            //             color: Colors.blue.shade700,
                            //             size: 20,
                            //           ),
                            //           const SizedBox(width: 8),
                            //           Text(
                            //             "Student Information",
                            //             style: TextStyle(
                            //               fontSize: 16,
                            //               fontWeight: FontWeight.bold,
                            //               color: Colors.blue.shade700,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       const SizedBox(height: 12),
                            //       _buildInfoRow("Name", item["student_name"] ?? ''),
                            //       _buildInfoRow("Age", "${item["age"] ?? ''} years"),
                            //       _buildInfoRow("Institution", item["current_institution"] ?? ''),
                            //       _buildInfoRow("Degree", item["degree_name"] ?? ''),
                            //       _buildInfoRow("Grade", (item["grades"] ?? '').toUpperCase()),
                            //       _buildInfoRow("Fees", "Rs. ${item["fees"] ?? '0'}"),
                            //     ],
                            //   ),
                            // ),
                            //
                            // const SizedBox(height: 20),
                            //
                            // // Divider
                            // Container(
                            //   height: 1,
                            //   decoration: BoxDecoration(
                            //     gradient: LinearGradient(
                            //       colors: [
                            //         Colors.transparent,
                            //         Colors.grey.shade300,
                            //         Colors.transparent,
                            //       ],
                            //     ),
                            //   ),
                            // ),

                            // const SizedBox(height: 20),
                            //
                            // // Status Section
                            // Row(
                            //   children: [
                            //     Icon(
                            //       Icons.approval_rounded,
                            //       color: AppColors.primary,
                            //       size: 20,
                            //     ),
                            //     const SizedBox(width: 8),
                            //     Text(
                            //       "Approval Status",
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.w700,
                            //         color: Colors.grey.shade700,
                            //         letterSpacing: -0.3,
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            // const SizedBox(height: 16),
                            //
                            // // Status Grid
                            // GridView.count(
                            //   crossAxisCount: 2,
                            //   shrinkWrap: true,
                            //   physics: const NeverScrollableScrollPhysics(),
                            //   crossAxisSpacing: 12,
                            //   mainAxisSpacing: 12,
                            //   childAspectRatio: 2.5,
                            //   children: [
                            //     _buildEnhancedStatusChip("HR", item["hr_status"]),
                            //     _buildEnhancedStatusChip("HOD", item["hod_status"]),
                            //     _buildEnhancedStatusChip("Dept Head", item["dept_head_status"]),
                            //     _buildEnhancedStatusChip("CEO", item["ceo_status"]),
                            //   ],
                            // ),

                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildStatusChip("HR", item["hr_status"]),
                                _buildStatusChip(
                                    "HOD", item["hod_status"]),
                                _buildStatusChip(
                                    "Dept Head", item["dept_head_status"]),
                                _buildStatusChip("CEO", item["ceo_status"]),
                              ],
                            ),
                            // Action Buttons Row
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    "Details",
                                    Icons.info_outline_rounded,
                                    AppColors.primary,
                                        () => _showDetailsPopup(context, item),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    "Attachments",
                                    Icons.attachment_rounded,
                                    Colors.green,
                                        () => _showAttachmentsPopup(context, item),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    "Logs",
                                    Icons.history_rounded,
                                    Colors.orange,
                                        () => _showLogsPopup(context, item),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    "Vouchers",
                                    Icons.receipt_long_rounded,
                                    Colors.purple,
                                        () => _showVouchersPopup(context, item),
                                  ),
                                ),
                              ],
                            ),
                            VerticalSpacing(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () async {

                                    bool? shouldRemove = await   showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return  HodPopupDialog( title: 'hr_level2', fnf_id: item['aid_id'], datalist: aidDataList, name: item['employee_name'],

                                        );
                                      },
                                    );


                                    if (shouldRemove == true) {
                                      setState(() {
                                        if (aidDataList.isNotEmpty) {
                                          aidDataList.remove(item); // 0 ho ya koi aur, safe rahega
                                        }
                                      });
                                    }


                                  },
                                  child: Container(

                                    padding:EdgeInsets.all(8),
                                    child: Text("Submit Approval", style: TextStyle(color: Colors.white, fontSize: 12),),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,

                                      borderRadius: BorderRadius.circular(8),

                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "No Education Aid Data",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't applied for any education aid yet.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEnhancedStatusChip(String label, String? status) {
    MaterialColor chipColor;
    IconData chipIcon;

    switch (status?.toLowerCase()) {
      case 'approved':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        chipColor = Colors.red;
        chipIcon = Icons.cancel_rounded;
        break;
      default:
        chipColor = Colors.orange;
        chipIcon = Icons.schedule_rounded;
        status = status ?? 'pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: chipColor.shade50, // ✅ Now works
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chipColor.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: chipColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            chipIcon,
            size: 16,
            color: chipColor.shade700,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: chipColor.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  (status ?? 'pending')[0].toUpperCase() + (status ?? 'pending').substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: chipColor.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }


  // Details Popup
  void _showDetailsPopup(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (con) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Employee Details",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection("Personal Information", [
                        _buildDetailRow("Employee Code", item["employee_code"] ?? ''),
                        _buildDetailRow("Full Name", item["employee_name"] ?? ''),
                        _buildDetailRow("Designation", item["designation"] ?? ''),
                        _buildDetailRow("Department", item["department"] ?? ''),
                        _buildDetailRow("Group", item["group"] ?? ''),
                        _buildDetailRow("CNIC", item["cnic"] ?? ''),
                        _buildDetailRow("Phone", item["phone"] ?? ''),
                        _buildDetailRow("Address", item["address"] ?? ''),
                        _buildDetailRow("City", item["city"] ?? ''),
                        _buildDetailRow("Date of Birth", item["date_of_birth"] ?? ''),
                        _buildDetailRow("Joining Date", item["date_of_joining"] ?? ''),
                      ]),

                      const SizedBox(height: 24),

                      _buildDetailSection("Financial Information", [
                        _buildDetailRow("Last Drawn Salary", "Rs. ${item["last_drawn_salary"] ?? '0'}"),
                        _buildDetailRow("Dependents", item["number_of_dependents"] ?? '0'),
                        _buildDetailRow("Total Tenure", item["total_tenure"] ?? ''),
                        _buildDetailRow("Approved Percentage", "${item["approved_percentage"] ?? '0'}%"),
                      ]),

                      const SizedBox(height: 24),

                      _buildDetailSection("Education Details", [
                        _buildDetailRow("Student Name", item["student_name"] ?? ''),
                        _buildDetailRow("Student Age", "${item["age"] ?? ''} years"),
                        _buildDetailRow("Institution", item["current_institution"] ?? ''),
                        _buildDetailRow("Degree", item["degree_name"] ?? ''),
                        _buildDetailRow("Grades", (item["grades"] ?? '').toUpperCase()),
                        _buildDetailRow("Total Fees", "Rs. ${item["fees"] ?? '0'}"),
                      ]),
                    ],
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  onPressed: () => Navigator.pop(con),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showAttachmentsPopup(BuildContext context, Map<String, dynamic> item) {
    final attachments = item["attachment"] as List? ?? [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (con) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.green.withOpacity(0.8)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attachment_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Attachments (${attachments.length})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: attachments.isEmpty
                    ? _buildEmptyContent("No Attachments Found", Icons.attach_file_outlined)
                    : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: attachments.length,
                  itemBuilder: (context, index) {
                    final attachment = attachments[index];
                    final imageUrl = attachment["image_url"];
                    final fileUrl = attachment["image_url"];

                    return GestureDetector(
                      onTap: () async {
                        if (fileUrl != null && fileUrl.toString().isNotEmpty) {
                          final Uri uri = Uri.parse(fileUrl);
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Could not open link")),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.attach_file_rounded,
                                color: Colors.green,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                "Open Attachment",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new_rounded,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );

                  },
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(con),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // Logs Popup
  void _showLogsPopup(BuildContext context, Map<String, dynamic> item) {
    final logs = item["logs"] as List? ?? [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (con) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orange.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Activity Logs (${logs.length})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: logs.isEmpty
                    ? _buildEmptyContent("No Logs Available", Icons.history_outlined)
                    : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_rounded, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  log["username"] ?? "Unknown User",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                              Text(
                                log["posted_date"] ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            log["remarks"] ?? "",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(con),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vouchers Popup
  void _showVouchersPopup(BuildContext context, Map<String, dynamic> item) {
    final vouchers = item["voucher"] as List? ?? [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (con) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.purple.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Vouchers (${vouchers.length})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: vouchers.isEmpty
                    ? _buildEmptyContent("No Vouchers Available", Icons.receipt_outlined)
                    : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: vouchers.length,
                  itemBuilder: (context, index) {
                    final voucher = vouchers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Voucher Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Voucher ${index + 1}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getVoucherStatusColor(voucher["final_status"]),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (voucher["final_status"] ?? "pending").toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Voucher Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildVoucherDetailRow("Amount", "Rs. ${voucher["vouch_amt"] ?? '0'}"),
                                _buildVoucherDetailRow("Posted Date", voucher["posted_date"] ?? ''),
                                _buildVoucherDetailRow("Paid Date", voucher["paid_date"] ?? ''),
                                _buildVoucherDetailRow("Status", (voucher["final_status"] ?? "pending").toUpperCase()),

                                const SizedBox(height: 16),

                                // Voucher Image
                                if (voucher["image"] != null && voucher["image"].toString().isNotEmpty)
                                  GestureDetector(
                                    onTap: () async {
                                      if (voucher["image"]  != null && voucher["image"] .toString().isNotEmpty) {
                                        final Uri uri = Uri.parse(voucher["image"] );
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Could not open link")),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade700.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.attach_file_rounded,
                                              color: Colors.purple,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          const Expanded(
                                            child: Text(
                                              "Open Attachment",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.open_in_new_rounded,
                                            color: Colors.purple.shade700,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                      //  border: Border.dashed(color: Colors.grey.shade400),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image_not_supported_outlined, size: 32, color: Colors.grey.shade500),
                                        const SizedBox(height: 8),
                                        Text("No voucher image available", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(con),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getVoucherStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'paid':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildVoucherDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
          ),
          Text(
            ": ",
            style: TextStyle(
              fontSize: 14,
              color: Colors.purple.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "There are no items to display at the moment.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String field, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              field,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            ": ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatusChip(String title, String? status) {
    Color color;
    IconData icon;

    switch (status) {
      case "approved":
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case "rejected":
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_bottom;
    }

    return Row(
        children: [
          Icon(icon, size: 14, color: color),
          Text(
            "$title: ${status?[0].toUpperCase()}${status?.substring(1) ?? ''}",
            style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 11),
          ),
          // backgroundColor: color.withOpacity(0.07),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(20),
          //   side: BorderSide(color: color.withOpacity(0.3)),
          // ),
        ]
    );
  }

}