import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import '../../../models/api_response_models/Stats_model.dart';
import '../../../models/api_response_models/Stats_model.dart';
import '../../../shared/spacing.dart';

class StatsSection extends StatelessWidget {
  Map<String, dynamic> stats_resposne;
  StatsSection({required this.stats_resposne});




  final List<Color> cardColors = [
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFFFF9C4), // Light Yellow
    Color(0xFFE8F5E9), // Light Green
    Color(0xFFFFEBEE), // Light Red
    Color(0xFFEDE7F6), // Light Purple
    Color(0xFFFFF3E0), // Light Orange
  ];


  @override
  Widget build(BuildContext context) {
    var stats = StatsModel.fromJson(stats_resposne);

    List<Map<String, String>> statCards = stats.toCardList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Statistics',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          VerticalSpacing(12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: List.generate(statCards.length, (index) {
              return _buildStatCard(statCards[index], cardColors[index % cardColors.length]);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, String> item, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item['title']!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            item['count']!,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
