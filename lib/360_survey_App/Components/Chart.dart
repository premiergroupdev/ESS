import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../Models/Result_model.dart';

class Chart extends StatelessWidget {
  final ResultModel data;

  Chart({required this.data});

  // Map response to color (Flutter Colors)
  Color _getColor(String response) {
    switch (response) {
      case 'Strongly Agree':
        return Colors.green;
      case 'Agree':
        return Colors.blue;
      case 'Disagree':
        return Colors.red;
      case 'Strongly Disagree':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare data
    final List<Map<String, dynamic>> chartData = [
      {'response': 'Strongly Agree', 'value': data.stronglyAgree},
      {'response': 'Agree', 'value': data.agree},
      {'response': 'Disagree', 'value': data.disAgree},
      {'response': 'Strongly Disagree', 'value': data.stronglyDisagree},
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: BoxConstraints.expand(),
          child: BarChart(
            BarChartData(
              maxY: chartData
                  .map((e) => int.parse(e['value'].toString()))
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() + 5,
              barGroups: chartData.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: int.parse(item['value'].toString()).toDouble(),
                      color: _getColor(item['response']),
                      width: 32,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < chartData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            chartData[index]['response'],
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 50,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                    },
                    reservedSize: 30,
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = chartData[group.x.toInt()];
                    return BarTooltipItem(
                      '${item['response']}\n${item['value']}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
