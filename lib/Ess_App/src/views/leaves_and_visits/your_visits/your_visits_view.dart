import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/shared/loading_indicator.dart';
import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/views/leaves_and_visits/your_visits/widget/your_visits_data_table.dart';
import 'package:ess/Ess_App/src/views/leaves_and_visits/your_visits/your_visits_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../dashboard/widget/title_widget.dart';

class VisitsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VisitsViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "All Visits",
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
                    : VisitsDataTable(
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
      viewModelBuilder: () => VisitsViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }

  void showLeaveApplication(BuildContext context, VisitsTableData data) {
    showDetailDialog(
      context,
      title: 'Visit details',
      status: data.status.toString(),
      statusColor: data.statusColor,
      rows: [
        MapEntry('Visit on', data.visitsDate),
        MapEntry('Location', data.location),
        MapEntry('Reason', data.reason),
        MapEntry('Approved by', data.approvedBy),
      ],
    );
  }
}