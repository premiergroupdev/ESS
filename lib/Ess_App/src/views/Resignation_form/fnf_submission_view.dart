import 'package:ess/Learning_management_system/Utilis/colors.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../shared/loading_indicator.dart';
import '../../shared/top_app_bar.dart';
import '../../styles/app_colors.dart';
import 'fnf_submission_view_model.dart';


class FnfSubmissionView extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return
      ViewModelBuilder<Fnf_viewModel>.reactive(
        builder: (viewModelContext, model, child) =>
      Scaffold(

      body:
      model.isBusy
          ? Center(child: LoadingIndicator())
          :
      Column(
        children: [
          SizedBox(height: 10,),
          GeneralAppBar(
              title: "FNF Submission",
              onMenuTap: () {
                Scaffold.of(context).openDrawer();
              },
              onNotificationTap: () {}),
          Expanded(
            child: ListView.builder(
              itemCount: model.datalist.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final caseData = model.datalist[index];
                return
                  Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CASE ID: ${caseData['fnf_id']}",
                            style: TextStyle(
                                fontSize: 15,

                                color: AppColors.black)),
                        SizedBox(height: 10),
                        Text("Employee: ${caseData['emp_name']}",
                            style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Text("Reason: ${caseData['reason']}"),
                        Text("Last Day: ${caseData['last_day']}"),
                        Divider(height: 25, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.person, size: 18),
                              label: Text("View Details"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _showDetailsDialog(context, caseData);
                              },
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.history, size: 18),
                              label: Text("Approval Logs"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _showApprovalDialog(context, caseData['fnf_log']);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
          viewModelBuilder: () => Fnf_viewModel(),
    onModelReady: (model) => model.init(context),
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

