import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:flutter/material.dart';

class LeaveApplicationsTableData {
  final String appliedDate;
  final dynamic totalDays;
  final dynamic sick;
  final dynamic casual;
  final dynamic annual;
  final String startDate;
  final String endDate;
  final Color? statusColor;
  final String? status;

  LeaveApplicationsTableData({
    required this.appliedDate,
    required this.totalDays,
    required this.sick,
    required this.casual,
    required this.annual,
    required this.startDate,
    required this.endDate,
    this.statusColor,
    this.status,
  });
}

/// Card list of leave applications. Same constructor as before; `heading` is
/// kept for compatibility (column headings are no longer needed in card form).
class LeaveApplicationsDataTable extends StatelessWidget {
  final LeaveApplicationsTableData heading;
  final List<LeaveApplicationsTableData> data;
  final ValueChanged<int> onTap;

  const LeaveApplicationsDataTable({
    Key? key,
    required this.heading,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const EmptyState(
        title: 'Data not available',
        subtitle: 'You have not applied for any leave yet.',
        icon: Icons.beach_access_outlined,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final accent = item.statusColor ?? AppColors.primary;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: EdgeInsets.zero,
            onTap: () => onTap(index),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(18),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.startDate}  →  ${item.endDate}',
                                  style: TextStyling.bold14,
                                ),
                              ),
                              if (item.status != null)
                                StatusChip(
                                  label: item.status!,
                                  color: item.statusColor,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.event_note_rounded,
                                  size: 15, color: AppColors.darkGrey),
                              const SizedBox(width: 5),
                              Text('Applied ${item.appliedDate}',
                                  style: TextStyling.caption),
                              const Spacer(),
                              Text(
                                '${item.totalDays} day${item.totalDays.toString() == '1' ? '' : 's'}',
                                style: TextStyling.bold14
                                    .copyWith(color: AppColors.primary),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.grey, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
