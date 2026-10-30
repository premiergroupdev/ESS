import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:flutter/material.dart';

class VisitsTableData {
  final String location;
  final String reason;
  final String appliedDate;
  final String visitsDate;
  final Color statusColor;
  final String status;
  final String approvedBy;

  VisitsTableData({
    required this.location,
    required this.reason,
    required this.approvedBy,
    required this.appliedDate,
    required this.visitsDate,
    required this.statusColor,
    required this.status,
  });
}

/// Card list of visits. Same constructor as before.
class VisitsDataTable extends StatelessWidget {
  final VisitsTableData heading;
  final List<VisitsTableData> data;
  final ValueChanged<int> onTap;

  const VisitsDataTable({
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
        subtitle: 'No visits have been applied yet.',
        icon: Icons.directions_walk_rounded,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
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
                      color: item.statusColor,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(18),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(item.visitsDate,
                                    style: TextStyling.bold14),
                              ),
                              StatusChip(
                                label: item.status,
                                color: item.statusColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.reason,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyling.body,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined,
                                  size: 15, color: AppColors.darkGrey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyling.caption,
                                ),
                              ),
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