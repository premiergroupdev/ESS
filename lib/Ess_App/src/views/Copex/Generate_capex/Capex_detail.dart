import 'package:flutter/material.dart';
import '../../../models/api_response_models/Capex_model.dart';
import '../../../shared/top_app_bar.dart';
import '../../../styles/app_colors.dart';

class CapexDetail extends StatefulWidget {
  final CapexModel data;
  final List<Items> itemlist;

  const CapexDetail({super.key, required this.data, required this.itemlist});

  @override
  State<CapexDetail> createState() => _CapexDetailState();
}

class _CapexDetailState extends State<CapexDetail> {
  late final double _total;

  @override
  void initState() {
    super.initState();
    // Total is calculated from the same list that is displayed
    _total = widget.data.itemList
        .fold<double>(0.0, (sum, item) => sum + (item.total as num));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: AppBarwidget(
                title: "Capex Details",
                onMenuTap: () {},
                onNotificationTap: () {},
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: "General Info",
                      icon: Icons.person_outline,
                      child: Column(
                        children: [
                          _InfoRow(label: "Name", value: d.memberName),
                          _InfoRow(label: "Employee Code", value: d.empCode),
                          _InfoRow(label: "Branch", value: d.branchName),
                          _InfoRow(
                              label: "Capex Type",
                              value: d.capexType,
                              isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: "Approval Status",
                      icon: Icons.verified_outlined,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(label: "Cord.", status: d.cordStatus),
                          _StatusChip(label: "HOD", status: d.hodStatus),
                          _StatusChip(
                              label: "Dept. Head", status: d.deptHeadStatus),
                          _StatusChip(label: "GM", status: d.gmStatus),
                          _StatusChip(label: "CEO", status: d.ceoStatus),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: "Items (${d.itemList.length})",
                      icon: Icons.inventory_2_outlined,
                      child: Column(
                        children: [
                          _buildTableHeader(),
                          const SizedBox(height: 4),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: d.itemList.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                            ),
                            itemBuilder: (context, index) {
                              final item = d.itemList[index];
                              return _buildItemRow(index, item);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTotalCard(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Colors.black54,
      letterSpacing: 0.4,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text("NO.", style: style)),
          Expanded(flex: 5, child: Text("ITEM", style: style)),
          Expanded(
              flex: 2,
              child: Text("QTY", style: style, textAlign: TextAlign.center)),
          Expanded(
              flex: 3,
              child: Text("PRICE", style: style, textAlign: TextAlign.right)),
          Expanded(
              flex: 3,
              child: Text("TOTAL", style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index, dynamic item) {
    const cell = TextStyle(fontSize: 13, color: Colors.black87);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text("${index + 1}",
                style: cell.copyWith(color: Colors.black45)),
          ),
          Expanded(
            flex: 5,
            child: Text(item.itemName,
                style: cell.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text(item.qty.toString(),
                style: cell, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child: Text(item.price.toString(),
                style: cell, textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.total.toString(),
              style: cell.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Grand Total",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "${_total.toStringAsFixed(2)} RS",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// White rounded card with a title row.
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Label on the left, value on the right.
class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool isLast;

  const _InfoRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              (value == null || value!.isEmpty) ? "-" : value!,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Colored pill showing an approval status.
class _StatusChip extends StatelessWidget {
  final String label;
  final String? status;

  const _StatusChip({required this.label, required this.status});

  Color get _color {
    switch (status?.toLowerCase()) {
      case "pending":
        return Colors.blue;
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get _icon {
    switch (status?.toLowerCase()) {
      case "pending":
        return Icons.schedule;
      case "approved":
        return Icons.check_circle;
      case "rejected":
        return Icons.cancel;
      default:
        return Icons.remove_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = (status == null || status!.isEmpty)
        ? "N/A"
        : status![0].toUpperCase() + status!.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16, color: _color),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: _color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}