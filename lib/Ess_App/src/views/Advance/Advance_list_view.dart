import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/cupertino.dart';
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
    return
      ViewModelBuilder<AdvanceViewModel>.reactive(
          builder: (viewModelContext, model, child) =>
              Scaffold(
                  resizeToAvoidBottomInset: false,
                  body:
                  model.isBusy
                      ? Center(child: LoadingIndicator())
                      :
                  Column(
                    children: [
                      SizedBox(height: 15,),
                      GeneralAppBar(
                          title: "Advance List",
                          onMenuTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          onNotificationTap: () {}),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
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
  return Card(
    margin: EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['member_name'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Chip(
                label: Text(
                  item['status'],
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: item['status'] == 'Closed'
                    ? Colors.green
                    : Colors.orange,
              ),
            ],
          ),
          SizedBox(height: 8),

          // Date & Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconRow(Icons.calendar_today, item['case_date']),
              Text(
                "Rs. ${formatAmount(item['amount'])}",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600, // makes it slightly bold
                  color: AppColors.black,
                ),
              )

              //_buildIconRow(Icons.abc_rounded, "${item['amount']}"),
            ],
          ),

          SizedBox(height: 8),

          // Advance ID
          _buildIconRow(Icons.receipt, "Advance ID: ${item['adv_id']}"),

          // ERP Remarks if any
          if (item['erp_remarks'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _buildIconRow(Icons.info_outline, item['erp_remarks']),
            ),
        ],
      ),
    ),
  );
}

Widget _buildIconRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey[700]),
      SizedBox(width: 6),
      Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ),
    ],
  );
}
