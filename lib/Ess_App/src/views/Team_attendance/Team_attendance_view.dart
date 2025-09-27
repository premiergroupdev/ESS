import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../shared/loading_indicator.dart';
import '../../shared/top_app_bar.dart';
import '../your_attandence/your_attandence_view.dart';
import 'Team_attendance_view_model.dart';

class Team_attendance_view extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return
      ViewModelBuilder<Team_attendance_ViewModel>.reactive(
        builder: (viewModelContext, model, child) =>

      Scaffold(
      // appBar: AppBar(
      //   title: Text('Employee Attendance List'),
      //   backgroundColor: Colors.deepPurple,
      // ),
      body:

      model.isBusy
          ? Center(child: LoadingIndicator())
          :
      Column(
        children: [
          SizedBox(height: 10,),

          GeneralAppBar(
              title: "Team Attendance",
              onMenuTap: () {
                Scaffold.of(context).openDrawer();
              },
              onNotificationTap: () {}),

          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: model.datalist.length,
              itemBuilder: (context, index) {
                return _buildEmployeeCard(model.datalist[index], context);

              },
            ),
          ),

        ],
      ),
    ),
          viewModelBuilder: () => Team_attendance_ViewModel(),
    onModelReady: (model) => model.init(context));
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employeeData, BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Email
            Center(
              child: Column(
                children: [
                  Text(
                    employeeData['emp_name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    employeeData['emp_email'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Divider(thickness: 1),

            // Attendance Stats
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard("On Time", employeeData['on_time'].toString(), Icons.check_circle, Colors.green),
                  //SizedBox(width: 20,),
                  _buildStatCard("Late", employeeData['late'].toString(), Icons.access_time, Colors.orange),
                  //SizedBox(width: 20,),
                  _buildStatCard("Absent", employeeData['absent'].toString(), Icons.cancel, Colors.red),
                ],
              ),
            ),

            Divider(thickness: 1),
            //SizedBox(height: 10),

            // Attendance Summary
            Text(
              "📊 Attendance Summary",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            _buildPercentageRow("On-Time %", employeeData['ontime_percentage'], Icons.trending_up, Colors.green),
            _buildPercentageRow("Late %", employeeData['late_percentage'], Icons.trending_down, Colors.orange),
            _buildPercentageRow("Weekends", employeeData['weekend'].toString(), Icons.weekend, Colors.blueGrey),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YourAttendanceView(check: "2",
                           code:   employeeData['emp_code']),
                    ),
                  );
                },
                child: Container(

                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Soft black shadow
                          offset: Offset(0, 3), // Horizontal and vertical offset
                          blurRadius: 6, // How soft the shadow is
                          spreadRadius: 1, // How far it spreads
                        ),
                      ],
                      borderRadius:   BorderRadius.circular(10)),
                  child: Text("View Attendance", style: TextStyle(color: Colors.white, fontSize: 12),),

                ),
              )
            ],)
          ],

        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 22,
          child: Icon(icon, color: color, size: 22),
        ),
        SizedBox(height: 6),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

}
