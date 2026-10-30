import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/shared/loading_indicator.dart';
import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/views/leaves_and_visits/your_leave_aplications/widget/leave_aplications_data_table.dart';
import 'package:ess/Ess_App/src/views/leaves_and_visits/your_leave_aplications/your_leave_aplications_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../dashboard/widget/title_widget.dart';

class LeaveApplicationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LeaveApplicationsViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "Leave Applications",
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  onNotificationTap: () {}),
              LegendRow(
                children: [
                  TitleWidget(title: "Approved", color: AppColors.success),
                  TitleWidget(title: "Pending", color: Colors.orange),
                  TitleWidget(title: "Rejected", color: AppColors.danger),
                ],
              ),
              Expanded(
                child: model.isBusy
                    ? const Center(child: LoadingIndicator())
                    : LeaveApplicationsDataTable(
                  heading: model.heading,
                  data: model.data,
                  onTap: (int index) {
                    var selectedData = model.data[index];
                    showLeaveApplication(context, selectedData);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => LeaveApplicationsViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }

  void showLeaveApplication(
      BuildContext context, LeaveApplicationsTableData data) {
    showDetailDialog(
      context,
      title: 'Leave details',
      status: data.status?.toString(),
      statusColor: data.statusColor,
      rows: [
        MapEntry('Applied on', data.appliedDate),
        MapEntry('Leave starts', data.startDate),
        MapEntry('Leave ends', data.endDate),
        MapEntry('Number of days', data.totalDays.toString()),
      ],
      footer: CountTiles(
        items: [
          MapEntry('Sick', data.sick.toString()),
          MapEntry('Casual', data.casual.toString()),
          MapEntry('Annual', data.annual.toString()),
        ],
      ),
    );
  }
}
