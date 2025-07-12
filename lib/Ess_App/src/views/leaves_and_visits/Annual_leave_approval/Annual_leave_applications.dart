import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';

import '../../../shared/loading_indicator.dart';
import '../../../shared/top_app_bar.dart';
import 'Annual_leave_applications_view_model.dart';

class Annual_leave_applications extends StatefulWidget {
  const Annual_leave_applications({super.key});

  @override
  State<Annual_leave_applications> createState() => _Annual_leave_applicationsState();
}

class _Annual_leave_applicationsState extends State<Annual_leave_applications> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<Annual_leave_applications_ViewModel>.reactive(
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
              title: "My Annual Plan",
              onMenuTap: () {
                Scaffold.of(context).openDrawer();},

              onNotificationTap: () {}
          ),
          model.plan_id.isNotEmpty ?
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
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
                          'Plan ID: ${model.plan_id}',
                          style: TextStyle(

                            fontSize: 18,
                               color: AppColors.primary
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30, thickness: 1.2),
                    _buildRow(Icons.date_range, "Start Date:", '${model.start_date}',Colors.green),
                    const SizedBox(height: 12),
                    _buildRow(Icons.event_available_rounded, "End Date:", "${model.end_date}", Colors.redAccent),
                    const SizedBox(height: 12),
                    _buildRow(Icons.edit_calendar_outlined, "Filled On:", "${model.filled_date}", Colors.orangeAccent),


                  ],
                )
          ),
            ))
              :Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Data Not Available",
              style: TextStyling.bold18
                  .copyWith(color: AppColors.darkGrey),
            ),
          ),

        ],
      ),
    ),),
        viewModelBuilder: () => Annual_leave_applications_ViewModel(),
    onModelReady: (model) => model.init(context));
  }
}
Widget _buildRow(IconData icon, String label, String value, Color iconColor) {
  return Row(
    children: [
      Icon(icon, color: iconColor),
      const SizedBox(width: 10),
      Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const Spacer(),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    ],
  );
}