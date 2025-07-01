// import 'package:flutter/cupertino.dart';
//
// class Plan_approval_view extends StatefulWidget {
//   const Plan_approval_view({super.key});
//
//   @override
//   State<Plan_approval_view> createState() => _Plan_approval_viewState();
// }
//
// class _Plan_approval_viewState extends State<Plan_approval_view> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
import 'package:ess/Ess_App/src/shared/bottons.dart';
import 'package:ess/Ess_App/src/shared/input_field.dart';
import 'package:ess/Ess_App/src/shared/spacing.dart';
import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/views/leaves_and_visits/apply_leave/apply_leave_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import '../../../base/utils/constants.dart';
import '../../../services/remote/api_result.dart';
import '../../../services/remote/api_service.dart';
import '../../../shared/loading_indicator.dart';
import '../../your_attandence/widget/dropdown.dart';
import 'Annual_leave_approval_view_model.dart';
import 'Plan_approvals_view_model.dart';

class Plan_approval_view extends StatefulWidget {
  final String? date;
  const Plan_approval_view({Key? key, this.date}) : super(key: key);

  @override
  State<Plan_approval_view> createState() => _Plan_approval_viewState();
}

class _Plan_approval_viewState extends State<Plan_approval_view> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<Plan_approval_ViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        body:
        model.isBusy
            ? Center(child: LoadingIndicator())
            :
        SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "Annual Plan Approval",
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();},

                  onNotificationTap: () {}
              ),
              Expanded(
                child:

              ListView.builder(
              padding: const EdgeInsets.all(16),
    itemCount: model.plan.length,
    itemBuilder: (context, index) {
      final plan = model.plan[index];

      return
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          color: Colors.blue.shade50,
          shadowColor: Colors.black12,
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary, size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'Plan ID: ${plan.planId}',
                        style: TextStyle(

                            fontSize: 18,
                            color: AppColors.primary
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1.2),
                  _buildRow(Icons.person, "Member Name:", '${plan.memberName}',Colors.black),
                  const SizedBox(height: 12),
                  _buildRow(Icons.work_outline, "Member Designation:", '${plan.memberDesignation}',Colors.blue),
                  const SizedBox(height: 12),
                  _buildRow(Icons.date_range, "Start Date:", '${plan.startDate}',Colors.green),
                  const SizedBox(height: 12),
                  _buildRow(Icons.event_available_rounded, "End Date:", "${plan.endDate}", Colors.redAccent),
                  const SizedBox(height: 12),
                  _buildRow(Icons.edit_calendar_outlined, "Filled On:", "${plan.filledDate}", Colors.orangeAccent),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Spacer(),
                      Container(
                          height:35,
                          child: buildStatusDropdown(
                            model.selectedvisitStatusList[index],
                            model.dropdownValues,
                                (String? newValue) async {
                              setState(() {
                                model.selectedvisitStatusList[index] = newValue; // Update the selected status for this item
                              });
                              print(model.selectedvisitStatusList[index]);
                              print("Selected value for index $index: $newValue");

                              // Check if the selected value is "Select your decision"
                              if (newValue == "Select your decision") {
                                model.resetSelectedStatus(index);
                                return; // Exit the function early, skipping the API call
                              }

                              // Show confirmation dialog before making the API call
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: AppColors.primary, // Custom primary background color
                                    title: Text(
                                      "Confirm Your Decision",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // White text color
                                      ),
                                    ),
                                    content: Text(
                                      "Are you sure you want to $newValue this plan?",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white, // White content text
                                      ),
                                    ),
                                    actions: <Widget>[
                                      // Cancel Button
                                      TextButton(
                                        child: Text(
                                          "Cancel",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white, // White color for cancel button text
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                          // Optionally reset the selection if the user cancels
                                          setState(() {
                                            model.selectedvisitStatusList[index] = "Select your decision";
                                          });
                                        },
                                      ),
                                      // Confirm Button
                                      TextButton(
                                        child: Text(
                                          "Confirm",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white, // White color for confirm button text
                                          ),
                                        ),
                                        onPressed: () async {


                                          ApiService api = ApiService();
                                          String selectedBackendValue;

                                          // Map the dropdown value to the backend value
                                          if (newValue == "Approved") {
                                            selectedBackendValue = "approved";
                                          } else if (newValue == "Rejected") {
                                            selectedBackendValue = "rejected";
                                          } else {
                                            selectedBackendValue = "0"; // Default value for other cases
                                          }

                                          // Make the API call
                                          final response = await api.plan_approval_update(
                                            selectedBackendValue,
                                            plan.planId.toString(),

                                          );

                                          if (response is Success) {
                                            final jsonResponse = response.data;

                                            if (jsonResponse != null && jsonResponse.containsKey("code")) {
                                              final status = jsonResponse["code"];
                                              final msg = jsonResponse['message'];
                                              print("Status: $status");

                                              // if (newValue == "Approved") {
                                              //   Constants.customSuccessSnack(context, msg);
                                              // } else if (newValue == "Rejected") {
                                              //   Constants.customSuccessSnack(context, msg);
                                              // }

                                              // If approved or rejected or status is success
                                              if ( status == "200") {
                                                setState(() {
                                                  if (model.selectedvisitStatusList[index] != "Select your decision") {
                                                    model.plan.removeAt(index); // Remove item from loan list
                                                  }
                                                  model.selectedvisitStatusList[index] = "Select your decision"; // Reset dropdown value
                                                });
                                                Constants.customSuccessSnack(context, msg);
                                                Navigator.of(context).pop();
                                              }
                                            } else {
                                              print("JSON response is null or 'status' is missing");
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                            },
                          )


                      ) ],
                  ),


                ],
              )
          ),
        );
    }))
            ],
          ),
        ),
      ),
      viewModelBuilder: () => Plan_approval_ViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}
Widget _buildRow(IconData icon, String label, String value, Color iconColor) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: iconColor, size: 20),
      const SizedBox(width: 10),
      Text(
        "$label",
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(color: AppColors.black),
          overflow: TextOverflow.ellipsis, // hides overflow
          maxLines: 2, // adjust as needed
        ),
      ),
    ],
  );
}

