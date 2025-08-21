import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../Department_head_approval_detail/Department_head_approval_detail_view.dart';
import 'Department_head_approval_view_model.dart';


class Department_head_Capex_approval extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return

      ViewModelBuilder<Department_head_approval_viewmodel>.reactive(
          builder: (viewModelContext, model, child) => Scaffold(
            body:
            Column(
              children: [
                SizedBox(height: 10,),
                GeneralAppBar(title: "Department Head Approval", onMenuTap: (){}, onNotificationTap: (){}),
                (model.isBusy == true)
                    ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                    :
                Expanded(
                  child: ListView.builder(
                    itemCount: model.datalist.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      final item = model.datalist[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "#${item.copexId}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  InkWell(
                                      onTap: (){},
                                      child:
                                      Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.blue.shade50),
                                          child: Text("CAPEX: ${item.capexType}"))
                                    // Chip(
                                    //   label: Text("CAPEX: ${item.capexType}"),
                                    //   backgroundColor: Colors.blue.shade50,
                                    // ),
                                  ),
                                ],
                              ),
                              // SizedBox(height: 2),
                              Text(
                                item.memberName ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item.memberDesignation ?? '',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.branch ?? '',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(item.postedDate ?? '',
                                      style: TextStyle(fontSize: 13)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      model.showApprovalStatusDialog(context, cordStatus: item.cordStatus.toString(), hodStatus: item.hodStatus.toString(), deptHeadStatus: item.deptHeadStatus.toString(), gmStatus: item.gmStatus.toString(),);
                                    },
                                    child: Chip(
                                      label: Text("See Approvals",
                                          style: TextStyle(color: Colors.white)),
                                      backgroundColor: AppColors.primary,

                                    ),
                                  ),
                                  InkWell(
                                    onTap: (){

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Department_head_ExpenseDetailScreen(name: item.memberName.toString(), copex_id:item.copexId.toString(), ),
                                        ),
                                      );
                                    },
                                    child: Chip(


                                      label: Text("See Details" '',
                                          style: TextStyle(color: Colors.white)),
                                      backgroundColor: AppColors.primary,

                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          viewModelBuilder: () => Department_head_approval_viewmodel( ),
          onModelReady: (model) => model.init(context)
      );
  }
}