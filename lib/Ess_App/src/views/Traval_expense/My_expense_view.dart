import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../shared/top_app_bar.dart';
import '../../styles/app_colors.dart';
import 'My_expense_view_model.dart';

class TravelListScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return
      ViewModelBuilder<My_Expense_viewmodel>.reactive(
          builder: (viewModelContext, model, child) =>
      Scaffold(

      body:

      Column(
        children: [
          SizedBox(height: 13,),
          GeneralAppBar(title: "My Expenses", onMenuTap: () {}, onNotificationTap: () {}),
          (model.isBusy == true)
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              :
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: model.datalist.length,
              itemBuilder: (context, index) {
                final data = model.datalist[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor:  Colors.blue.shade50,
                      child: Text(
                        data['case_id'],
                        style: TextStyle(color: AppColors.primary, fontSize: 12),
                      ),
                    ),
                    title: Text(
                      data['visitor_name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text("Visitor Code: ${data['visitor_code']}"),
                        RichText(
                          text: TextSpan(
                            text: 'Travel: ',
                            style: TextStyle(color: AppColors.primary, fontSize: 13),
                            children: [
                              TextSpan(
                                text: model.formatTravelDistance(data['total_travel']),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
SizedBox(height: 8,),
InkWell(
  onTap: (){
    final expense = data['expense_detail'][0]; // get first detail

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Center(
                    child: Text(
                      'Travel Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildRow('From:', expense['origin']),
                  _buildRow('To:', expense['destination']),
                  _buildRow('Distance:', model.formatTravelDistance(expense['distance'])),
                  _buildRow('Departure Date/Time:', "${expense['depart_date']} / ${expense['dep_time'] != "" ? expense['dep_time'] : 'N/A'}"),
                  _buildRow('Arrival Date/Time:', "${expense['arrival_date']} / ${expense['arr_time'] != "" ? expense['arr_time'] : 'N/A'}"),
            //      _buildRow('Arrival Time:', expense['arr_time'] != "" ? expense['arr_time'] : 'N/A'),
                  _buildRow('Duration:', '${expense['duration_days']} / ${expense['duration_night']}'),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Close'),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

  },
  child: Container(
    decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6)),
    padding: EdgeInsets.all(5),
    child: Text("View Details", style: TextStyle(color: Colors.white, fontSize: 10),),),
)
                      ],
                    ),
                    trailing: Icon(Icons.directions_walk, color: Colors.indigo),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    viewModelBuilder: () => My_Expense_viewmodel(),
    onModelReady: (model) => model.init(context));
  }
}
Widget _buildRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
