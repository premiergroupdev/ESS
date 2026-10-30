import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../shared/loading_indicator.dart';
import '../../shared/top_app_bar.dart';
import 'Advance_list_view_model.dart';

class Advance_list_view extends StatefulWidget {
  const Advance_list_view({super.key});

  @override
  State<Advance_list_view> createState() => _Advance_list_viewState();
}

class _Advance_list_viewState extends State<Advance_list_view> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AdvanceViewModel>.reactive(
        builder: (viewModelContext, model, child) => Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                GeneralAppBar(
                    title: "Advance List",
                    onMenuTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    onNotificationTap: () {}),
                Expanded(
                  child: model.isBusy
                      ? const Center(child: LoadingIndicator())
                      : model.dataList.isEmpty
                      ? const Center(
                    child: EmptyState(
                      title: 'No advances found',
                      subtitle:
                      'You have no advance records yet. Your requests will appear here.',
                      icon: Icons.payments_outlined,
                    ),
                  )
                      : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding:
                    const EdgeInsets.fromLTRB(18, 4, 18, 24),
                    itemCount: model.dataList.length,
                    itemBuilder: (context, index) {
                      final item = model.dataList[index];
                      return _buildAdvanceCard(item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        viewModelBuilder: () => AdvanceViewModel(),
        onModelReady: (model) => model.init(context));
  }
}

Widget _buildAdvanceCard(Map<String, dynamic> item) {
  String formatAmount(dynamic amount) {
    try {
      final intAmount = int.parse(amount.toString());
      return intAmount.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => ',',
      );
    } catch (e) {
      return amount.toString();
    }
  }

  final bool closed = item['status'] == 'Closed';

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['member_name'],
                  style: TextStyling.bold16,
                ),
              ),
              StatusChip(
                label: item['status'],
                tone: closed ? StatusTone.success : StatusTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildIconRow(Icons.calendar_today_rounded, item['case_date']),
              ),
              Text(
                "Rs. ${formatAmount(item['amount'])}",
                style: TextStyling.title.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildIconRow(Icons.receipt_long_rounded, "Advance ID: ${item['adv_id']}"),
          if (item['erp_remarks'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildIconRow(Icons.info_outline_rounded, item['erp_remarks']),
            ),
        ],
      ),
    ),
  );
}

Widget _buildIconRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: AppColors.darkGrey),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: TextStyling.body.copyWith(fontSize: 13))),
    ],
  );
}