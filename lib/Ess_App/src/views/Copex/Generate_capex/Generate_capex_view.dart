import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../models/api_response_models/Capex_model.dart';
import 'Capex_detail.dart';
import 'Generate_capex_view_model.dart';

// Same class name, same imports and same navigation target as the original,
// so the router and every other screen keep working untouched.
class GenerateCapex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GenerateCapexViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "Generate Capex",
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  onNotificationTap: () {}),
              Expanded(child: _buildBody(context, model)),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => GenerateCapexViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }

  Widget _buildBody(BuildContext context, GenerateCapexViewModel model) {
    if (model.isBusy == true) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (model.capexlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              "No Capex requests found",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: model.capexlist.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        CapexModel data = model.capexlist[index];
        return _CapexCard(
          data: data,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // Original detail screen class, unchanged
                builder: (context) =>
                    CapexDetail(itemlist: data.itemList, data: data),
              ),
            );
          },
        );
      },
    );
  }
}

class _CapexCard extends StatelessWidget {
  final CapexModel data;
  final VoidCallback onTap;

  _CapexCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statuses = <String, String?>{
      "Cord": data.cordStatus,
      "HOD": data.hodStatus,
      "Dept": data.deptHeadStatus,
      "GM": data.gmStatus,
      "CEO": data.ceoStatus,
    };
    final String type = (data.capexType ?? "").toString();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_long_outlined,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (data.capexId ?? "-").toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          (data.postedDate ?? "").toString(),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                    if (type.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: statuses.entries
                          .map((e) =>
                          _MiniStatus(label: e.key, status: e.value))
                          .toList(),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStatus extends StatelessWidget {
  final String label;
  final String? status;

  _MiniStatus({required this.label, required this.status});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}