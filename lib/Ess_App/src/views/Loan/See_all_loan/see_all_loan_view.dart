import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/shared/loading_indicator.dart';
import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:ess/Ess_App/src/views/Loan/See_all_loan/see_all_loan_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../models/api_response_models/fetch_loan_approval.dart';

class Allloan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AllLoanViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "My Loan Applications",
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
                    title: 'No loan applications found',
                    subtitle:
                    'You have not applied for a loan yet. Your applications will appear here.',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                )
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                  itemCount: model.loanlistfinal.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LoanCard(data: model.loanlistfinal[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => AllLoanViewModel(),
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

class _LoanCard extends StatelessWidget {
  final loanList data;

  const _LoanCard({required this.data});

  void _showDetails(BuildContext context) {
    showDetailDialog(
      context,
      title: 'Loan details',
      rows: [
        MapEntry('Employee code', _dash(data.emp_code)),
        MapEntry('Employee name', _dash(data.emp_name)),
        MapEntry('Designation', _dash(data.position)),
        MapEntry('Loan type', _dash(data.loantype)),
        MapEntry('Loan amount', 'Rs. ${_formatAmount(data.loan_amount)}'),
        MapEntry('Date of joining', _dash(data.doj)),
        MapEntry('Total installments', _dash(data.total_installment)),
        MapEntry('Per month repay', _dash(data.per_month_repay)),
        MapEntry('HOD status', _dash(data.hod_status)),
        MapEntry('Director status', _dash(data.director_status)),
        MapEntry('CEO status', _dash(data.ceo_status)),
        MapEntry('Reason', _dash(data.purpose)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final installments = _dash(data.total_installment);
    final perMonth = _dash(data.per_month_repay);

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _showDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: who + loan type ────────────────────────────────────
          Row(
            children: [
              const IconTile(
                icon: Icons.account_balance_wallet_rounded,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dash(data.emp_name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyling.bold16,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_dash(data.loantype)}  ·  Code ${_dash(data.emp_code)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyling.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.grey, size: 22),
            ],
          ),
          const SizedBox(height: 14),

          // ── Amount strip ───────────────────────────────────────────────
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
                      Text('Loan amount', style: TextStyling.caption),
                      const SizedBox(height: 2),
                      Text(
                        'Rs. ${_formatAmount(data.loan_amount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyling.title
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                if (perMonth != '-')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        installments != '-'
                            ? '$installments installments'
                            : 'Per month',
                        style: TextStyling.caption,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rs. ${_formatAmount(perMonth)} / mo',
                        style: TextStyling.bold14,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Approval progress ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _ApprovalStep(label: 'HOD', status: data.hod_status)),
              Expanded(
                  child: _ApprovalStep(
                      label: 'Director', status: data.director_status)),
              Expanded(
                  child: _ApprovalStep(label: 'CEO', status: data.ceo_status)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApprovalStep extends StatelessWidget {
  final String label;
  final String? status;

  const _ApprovalStep({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final text = _dash(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyling.caption),
        const SizedBox(height: 5),
        text == '-'
            ? const StatusChip(label: '-', tone: StatusTone.neutral)
            : StatusChip.fromText(text),
      ],
    );
  }
}