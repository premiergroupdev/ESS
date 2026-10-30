import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/shared/input_field.dart';
import 'package:ess/Ess_App/src/shared/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../base/utils/constants.dart';
import '../../../models/api_response_models/advance_line_manager_approval.dart';
import '../../../services/remote/api_result.dart';
import '../../../services/remote/api_service.dart';
import '../../../shared/top_app_bar.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/text_theme.dart';
import 'line_manager_approval_view_model.dart';

class LineManager extends StatefulWidget {
  @override
  State<LineManager> createState() => _LineManagerState();
}

List<String> dropdownValues = ["Select Status", "approved", "rejected"];

class _LineManagerState extends State<LineManager> {
  /// Same flow as before: pick a status -> call the API -> on success remove
  /// the request from the list. The only difference is that choosing
  /// "Select Status" just resets the dropdown (it no longer calls the API).
  Future<void> _onStatusChanged(
      LinemanagerViewModel model,
      int index,
      finalloanList data,
      String? newValue,
      ) async {
    if (newValue == null) return;

    // keep the per-row selection list in step with the data list
    while (model.selectedvisitStatusList.length <= index) {
      model.selectedvisitStatusList.add("Select Status");
    }

    setState(() {
      model.selectedvisitStatusList[index] = newValue;
    });
    print(model.selectedvisitStatusList[index]);
    print("Selected value for index $index: $newValue");

    if (newValue == "Select Status") {
      return;
    }

    ApiService api = ApiService();
    final response =
    await api.linemanagerapprovalstatus(newValue, data.case_id.toString());

    if (!mounted) return;

    if (response is Success) {
      final jsonResponse = response.data;

      // Check if jsonResponse is not null and contains the "status" property
      if (jsonResponse != null && jsonResponse.containsKey("status")) {
        final status = jsonResponse["status"];
        print("Status: $status");

        if (newValue == "approved") {
          print(newValue);
          Constants.customSuccessSnack(context, "Request is Approved");
        } else if (newValue == "rejected") {
          Constants.customSuccessSnack(context, "Request is Rejected");
        }

        if (newValue == "approved" || newValue == "rejected" || status == "200") {
          setState(() {
            model.loanlistfinal.removeAt(index);
            if (index < model.selectedvisitStatusList.length) {
              model.selectedvisitStatusList[index] = "Select Status";
            }
          });
        }
      } else {
        // Handle the case where jsonResponse is null or "status" is missing
        print("JSON response is null or 'status' is missing");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LinemanagerViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "Line Manager Approval",
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  onNotificationTap: () {}),
              Expanded(
                child: model.isBusy
                    ? const Center(child: LoadingIndicator())
                    : model.loanlistfinal.isEmpty
                    ? const Center(
                  child: EmptyState(
                    title: 'No requests to approve',
                    subtitle:
                    'There are no pending requests waiting for your approval.',
                    icon: Icons.task_alt_rounded,
                  ),
                )
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                  itemCount: model.loanlistfinal.length,
                  itemBuilder: (context, index) {
                    final data = model.loanlistfinal[index];
                    final selected =
                    index < model.selectedvisitStatusList.length
                        ? (model.selectedvisitStatusList[index] ??
                        "Select Status")
                        : "Select Status";
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RequestCard(
                        data: data,
                        selected: selected,
                        onChanged: (String? v) =>
                            _onStatusChanged(model, index, data, v),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => LinemanagerViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}

String _formatAmount(String amount) {
  try {
    final intAmount = int.parse(amount.trim());
    return intAmount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  } catch (e) {
    return amount;
  }
}

String _dash(String? v) =>
    (v == null || v.trim().isEmpty || v.trim().toLowerCase() == 'null')
        ? '-'
        : v.trim();

String _label(String v) =>
    v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);

class _RequestCard extends StatelessWidget {
  final finalloanList data;
  final String selected;
  final ValueChanged<String?> onChanged;

  const _RequestCard({
    required this.data,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final reason = _dash(data.reason);
    final status = _dash(data.status);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: who + current status ───────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTile(icon: Icons.person_outline_rounded, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dash(data.member_name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyling.bold16,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Code ${_dash(data.emp_code)}  ·  Case #${_dash(data.case_id)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyling.caption,
                    ),
                  ],
                ),
              ),
              if (status != '-') ...[
                const SizedBox(width: 8),
                StatusChip.fromText(status),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // ── Amount + date strip ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount', style: TextStyling.caption),
                      const SizedBox(height: 2),
                      Text(
                        'Rs. ${_formatAmount(data.amount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyling.title
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Case date', style: TextStyling.caption),
                    const SizedBox(height: 2),
                    Text(_dash(data.case_date), style: TextStyling.bold14),
                  ],
                ),
              ],
            ),
          ),

          // ── Reason ─────────────────────────────────────────────────────
          if (reason != '-') ...[
            const SizedBox(height: 14),
            Text('Reason', style: TextStyling.caption),
            const SizedBox(height: 3),
            Text(
              reason,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyling.body.copyWith(color: AppColors.black),
            ),
          ],

          // ── Decision ───────────────────────────────────────────────────
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          CustomDropDown(
            label: 'Your decision',
            value: dropdownValues.contains(selected)
                ? selected
                : dropdownValues.first,
            items: dropdownValues
                .map((v) => DropdownMenuItem<String>(
              value: v,
              child: Text(_label(v)),
            ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}