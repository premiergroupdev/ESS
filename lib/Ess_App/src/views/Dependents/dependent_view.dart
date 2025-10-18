import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../services/local/navigation_service.dart';
import '../../shared/loading_indicator.dart';
import '../../shared/spacing.dart';
import '../../shared/top_app_bar.dart'; // Import your custom app bar
import '../../styles/app_colors.dart';
import '../dashboard/dashboard_view_model.dart';

class DependentView extends StatelessWidget {
  const DependentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                title: "Your Dependents",
                onMenuTap: () {
                  // This will use NavService.back() from the GeneralAppBar
                },
                onNotificationTap: () {
                  // Handle notification if needed
                },
              ),
              Expanded(
                child: _buildDependentsContent(model),
              ),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => DashboardViewModel(),
      onViewModelReady: (model) => model.fetchDependents(),
    );
  }

  Widget _buildDependentsContent(DashboardViewModel model) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee Info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.primary),
                HorizontalSpacing(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee Code',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      model.currentUser?.userId ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          VerticalSpacing(20),

          // Dependents List
          Expanded(
            child: _buildDependentsList(model),
          ),
        ],
      ),
    );
  }

  Widget _buildDependentsList(DashboardViewModel model) {
    if (model.loadingDependents) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(),
            VerticalSpacing(16),
            Text(
              'Loading dependents...',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (!model.loadingDependents && model.dependents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            VerticalSpacing(16),
            Text(
              'No Dependents Found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            VerticalSpacing(8),
            Text(
              'No dependents registered for this employee',
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        Text(
          'Dependents (${model.dependents.length})',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        VerticalSpacing(16),
        ...model.dependents.map((dependent) => _buildDependentCard(dependent)).toList(),
      ],
    );
  }

  Widget _buildDependentCard(Dependent dependent) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Type Badge
            Container(
              width: 80,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _getTypeColor(dependent.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getTypeColor(dependent.type).withOpacity(0.3),
                ),
              ),
              child: Text(
                dependent.type.isNotEmpty ? dependent.type : 'N/A',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getTypeColor(dependent.type),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            HorizontalSpacing(16),

            // Dependent Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dependent.name.isNotEmpty ? dependent.name : 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  VerticalSpacing(4),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.secondary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dependent.packageType.isNotEmpty ? dependent.packageType : 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'wife':
      case 'spouse':
        return Colors.pink;
      case 'son':
      case 'daughter':
      case 'child':
        return Colors.blue;
      case 'mother':
      case 'father':
      case 'parent':
        return Colors.green;
      case 'brother':
      case 'sister':
      case 'sibling':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}