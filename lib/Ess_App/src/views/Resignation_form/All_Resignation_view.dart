import 'package:ess/Ess_App/src/views/Loan/customtextfeild.dart';
import 'package:ess/Learning_management_system/Utilis/colors.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../shared/loading_indicator.dart';
import '../../shared/top_app_bar.dart';
import '../../styles/app_colors.dart';
import 'All_resignation_view_model.dart';
import 'fnf_submission_view_model.dart';


class AllResignationView extends StatefulWidget {


  @override
  State<AllResignationView> createState() => _AllResignationViewState();
}

class _AllResignationViewState extends State<AllResignationView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AllResignationViewModel>.reactive(
      viewModelBuilder: () => AllResignationViewModel(),
      onModelReady: (model) => model.init(context),
      builder: (ctx, model, child) => Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: model.isBusy
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            SizedBox(height: 10),
            GeneralAppBar(
              title: "All Resignations",
              onMenuTap: () => Scaffold.of(context).openDrawer(),
              onNotificationTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: CustomTextField1(
                      controller: model.controller,
                      inputType: TextInputType.number,
                      labelText: "Search EmpCode",
                      onChanged: (val) =>
                          model.search(val, "empcode"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 1,
                          color: AppColors.primary,
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: model.Selectedvalue.isEmpty
                            ? null
                            : model.Selectedvalue,
                        hint: Text(
                          "  Select Region",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        isExpanded: true,
                        underline: SizedBox(),
                        borderRadius: BorderRadius.circular(12),
                        items: model.list
                            .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text("  ${e}"),
                        ))
                            .toList(),
                        onChanged: (val) {
                          model.search(val ?? '', "region");
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              child: Row(
                children: ["pending", "closed", "rejected"].map((status) {
                  final color = status == "pending"
                      ? Colors.orange
                      : status == "closed"
                      ? Colors.green[700]
                      : Colors.red;
                  return Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: status,
                          groupValue: model.selectedValue,
                          activeColor: color,
                          onChanged: (val) =>
                              model.search(val ?? '', "status"),
                        ),
                        Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(color: color),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            model.filterlist.isNotEmpty ?
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(12),
                itemCount: model.filterlist.length,
                itemBuilder: (context, idx) {
                  final data = model.filterlist[idx];
                  return
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// === CASE INFO ===
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "CASE ID: ${data['fnf_id']}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: data['final_status'] == "pending"
                                        ? Colors.orange
                                        : data['final_status'] == "closed"
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    data['final_status'].toString().toUpperCase(),
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            /// === EMPLOYEE DETAILS ===
                            _buildInfoRow("Emp Code", data['emp_code']),
                            _buildInfoRow("Employee", data['emp_name']),
                            _buildInfoRow("Region", data['region']),

                            Divider(height: 10),

                            /// === BUTTONS ===
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    icon: Icon(Icons.person, size: 18),
                                    label: Text("Details", style: TextStyle(fontSize: 14)),
                                    onPressed: () => _showDetailsDialog(context, data),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    icon: Icon(Icons.history, size: 18),
                                    label: Text("Approval", style: TextStyle(fontSize: 14)),
                                    onPressed: () => _showApprovalDialog(context, data["fnf_log"]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                },
              ),
            )
                :
            Text("No data", style: TextStyle(fontSize: 17, color: Colors.grey, fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }




  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text("$label:", style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value ?? "-", style: TextStyle())),
        ],
      ),
    );
  }



































  void _showDetailsDialog(BuildContext context, Map<String, dynamic> caseData) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Employee Details"),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Employee Name", caseData['emp_name']),
                  _buildDetailRow("Designation", caseData['designation']),
                  _buildDetailRow("Department", caseData['emp_dept']),
                  _buildDetailRow("Branch", caseData['branch']),
                  _buildDetailRow("Father Name", caseData['father_name']),
                  _buildDetailRow("CNIC", caseData['cnic']),
                  _buildDetailRow("Contact", caseData['contact']),
                  _buildDetailRow("Joining Date", caseData['date_of_joining']),
                  _buildDetailRow("Resign Date", caseData['date_of_resign']),
                  _buildDetailRow("Notice Period", caseData['notice_period']),
                  _buildDetailRow("Region", caseData['region']),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close", style: TextStyle(color: AppColors.primary)),
              onPressed: () => Navigator.pop(dialogContext), // ✅ FIX
            )
          ],
        );
      },
    );
  }

  void _showApprovalDialog(BuildContext context, List logs) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primary, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "Approval Log",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                logs.length > 0 ?
                Container(
                  height: 500, // fixed height for scroll
                  width: double.maxFinite,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child:

                    ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, i) {
                        final log = logs[i];
                        final status = log['status'];
                        final isApproved = status == "approved";
                        final isRejected = status == "rejected";

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isApproved
                                  ? Colors.green
                                  : isRejected
                                  ? Colors.red
                                  : Colors.orange,
                              child: Icon(
                                isApproved
                                    ? Icons.check
                                    : isRejected
                                    ? Icons.close
                                    : Icons.hourglass_top,
                                color: Colors.white,
                              ),
                            ),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isApproved
                                        ? Colors.green
                                        : isRejected
                                        ? Colors.red
                                        : Colors.orange,
                                  ),
                                ),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isApproved
                                        ? Colors.green.withOpacity(0.15)
                                        : isRejected
                                        ? Colors.red.withOpacity(0.15)
                                        : Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child:

                                  Text(
                                    log['posted_by'] ?? "Unknown",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  log['postedate'] ?? "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (log['comments'] != null &&
                                    log['comments'].isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    "💬 ${log['comments']}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
                ) :
                Container(child: Text("No Data Found"),),

                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(dialogContext), // ✅ FIXED
                    icon: Icon(Icons.close, color: AppColors.primary),
                    label: Text(
                      "Close",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text("$title:",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 5, child: Text(value ?? "-")),
        ],
      ),
    );
  }
}