import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartModel {
  final String day;
  final DateTime checkInTime;
  final String attendstatus;

  BarChartModel({
    required this.day,
    required this.checkInTime,
    required this.attendstatus,
  });
}

class HomePage extends StatelessWidget {
  final List<BarChartModel> data;
  final DateTime? end;

  HomePage({Key? key, required this.data, required this.end}) : super(key: key);

  final DateTime startTime = DateFormat('HH:mm').parse('08:00');

  Color _getColor(String status) {
    if (status == "On Time") {
      return Colors.green;
    } else if (status == "Late") {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  String _formatMinutesToTime(int minutes) {
    final time = startTime.add(Duration(minutes: minutes));
    return DateFormat('HH:mm').format(time);
  }

  void _showCheckInTimeDialog(BuildContext context, BarChartModel model) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Check-In Time', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Day: ${model.day}\nCheck-In: ${DateFormat('HH:mm').format(model.checkInTime)}'),
            SizedBox(height: 10),
            Icon(Icons.access_time, size: 30, color: Colors.blueAccent),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxY = end!.difference(startTime).inMinutes.toDouble();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barGroups: data.asMap().entries.map((entry) {
                final index = entry.key;
                final model = entry.value;
                final minutes = model.checkInTime.difference(startTime).inMinutes.toDouble();

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: minutes,
                      color: _getColor(model.attendstatus),
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    )
                  ],
                  showingTooltipIndicators: [0],
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Text(
                          data[index].day,
                          style: TextStyle(fontSize: 10),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatMinutesToTime(value.toInt()),
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final model = data[group.x.toInt()];
                    return BarTooltipItem(
                      "${model.day}\n${DateFormat('HH:mm').format(model.checkInTime)}",
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
                touchCallback: (event, response) {
                  if (response != null &&
                      response.spot != null &&
                      event is FlTapUpEvent) {
                    final index = response.spot!.touchedBarGroupIndex;
                    if (index >= 0 && index < data.length) {
                      _showCheckInTimeDialog(context, data[index]);
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
