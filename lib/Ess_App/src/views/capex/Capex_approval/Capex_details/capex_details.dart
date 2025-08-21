import 'package:ess/Ess_App/src/models/api_response_models/Capex_details.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../base/utils/constants.dart';
import '../../../../services/remote/api_result.dart';
import '../../../../services/remote/api_service.dart';
import '../../../../styles/app_colors.dart';
import 'capex_details_view_model.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Learning_management_system/Utilis/colors.dart';
import 'package:intl/intl.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String name;
  final String copex_id;
  ExpenseDetailScreen({super.key,required this.name,required this.copex_id});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}




class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {

  @override
  Widget build(BuildContext context) {

    return
      ViewModelBuilder<Capex_detail_view_viewmodel>.reactive(
          builder: (viewModelContext, model, child) =>

          model.copex_detailslist.isNotEmpty ?
          Scaffold(
              body: SingleChildScrollView(child: Column(children: [
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered Title
                      Center(
                        child: Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Back Button Positioned to Left
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor("#FAFAFA"),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: HexColor("#F3F3F3"),
                            ),
                          ),
                          height: 40,
                          width: 40,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: AppColors.primary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
////body
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                        children: [
                          ////header
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HeadingTextRow(
                                  heading: "Copex id",
                                  value: model.copex_detailslist[0].copexId,
                                ),
                                // Title section
                                HeadingTextRow(
                                  heading: "Employee Name",
                                  value: model.copex_detailslist[0].memberName,
                                ),
                                HeadingTextRow(
                                  heading: "Employee Code",
                                  value: model.copex_detailslist[0].empCode,
                                ),
                                HeadingTextRow(
                                  heading: "Employee Designation",
                                  value: model.copex_detailslist[0].memberDesignation,
                                ),
                                HeadingTextRow(
                                  heading: "Capex type",
                                  value: model.copex_detailslist[0].capexType,
                                ),
                                HeadingTextRow(
                                  heading: "Phone Number",
                                  value: model.copex_detailslist[0].phonenumber,
                                ),

                                HeadingTextRow(
                                  heading: "Posted",
                                  value: model.copex_detailslist[0].postedDate,
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [

                                    Container(

                                      child: InkWell(
                                        onTap: () {
                                          var quo = model.copex_detailslist[0].copexLogs;
                                          showCopexLogsDialog(context,quo);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "See History",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),


                                  ],
                                ),


                                SizedBox(height: 16),
                              ]),
                          ///approvals
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                InkWell(

                                    child: approvalStage("Coordinator", model.copex_detailslist[0].cordStatus.toString())),
                                approvalStage("HO Price Verification", model.copex_detailslist[0].priceVerification.toString()),
                                approvalStage("HOD", model.copex_detailslist[0].hodStatus.toString()),
                                approvalStage("Dept. Head", model.copex_detailslist[0].deptHeadStatus.toString()),
                                approvalStage("GM/DD", model.copex_detailslist[0].gmStatus.toString()),
                                approvalStage("CEO/FINAL", model.copex_detailslist[0].ceoStatus.toString()),
                                // Text(model.copex_detailslist[0].grandtotal.toString())
                              ],
                            ),
                          ),

                          ////title
                          Container(

                            // width: context.screenSize().width,
                            // height:600 ,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(color: AppColors.grey, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                "Item Name",
                                                style: TextStyle(color: Colors.white),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            // VerticalDivider(color: Colors.white, thickness: 1),
                                            // Expanded(
                                            //   flex: 2,
                                            //   child: Text(
                                            //     "Branch",
                                            //     style: TextStyle(color: Colors.white),
                                            //   ),
                                            // ),
                                            VerticalDivider(color: Colors.white, thickness: 1),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Qty",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            VerticalDivider(color: Colors.white, thickness: 1),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Price",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            VerticalDivider(color: Colors.white, thickness: 1),
                                            //////   model.copex_detailslist[0]
                                            Expanded(
                                              flex:2,
                                              child: Text(
                                                "Total",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Qoute",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  ])),
                          ////Listview
                          //SizedBox(height: 8,),
                          (model.copex_detailslist.length > 0)
                              ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: model.copex_detailslist[0].copexItems.length,
                              itemBuilder: (context, index) {
                                var data = model.copex_detailslist[0].copexItems[index];
                                return InkWell(
                                  onTap: () {
                                    // Handle onTap logic
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Padding(
                                                padding: EdgeInsets.only(right: 0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      data.itemName,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                                    Text(data.specs),
                                                    SizedBox(height: 6,),
                                                    Text(data.branchRequested, style:
                                                    TextStyle(color: Colors.grey),),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // VerticalDivider(color: Colors.grey, thickness: 1),
                                            // Expanded(
                                            //   flex: 2,
                                            //   child: Text(
                                            //     data.branchRequested,
                                            //     textAlign: TextAlign.start,
                                            //   ),
                                            // ),
                                            VerticalDivider(color: Colors.grey, thickness: 1),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                data.qty,
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            VerticalDivider(color: Colors.grey, thickness: 1),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                (data.price != null && data.price != "null")
                                                    ? NumberFormat.decimalPattern('en_IN')
                                                    .format(int.tryParse(data.price) ?? 0)
                                                    : "0",
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            VerticalDivider(color: Colors.grey, thickness: 1),
                                            // data.quotationsArr.isNotEmpty ?
                                            Expanded(
                                                flex: 2,

                                                child:

                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,

                                                    children: [


                                                      Text(
                                                        NumberFormat.decimalPattern('en_IN').format(data.totalPriceApproved),
                                                      )




                                                    ]),

                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: InkWell(
                                                onTap: () {
                                                  var quo = data.quotationsArr;
                                                  showQuotationListDialog(context: context, quotations: quo,);
                                                },
                                                child:
                                                Container(
                                                  // width: 45,
                                                  // height: 20,
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "See Quote",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Expanded(
                                            //     flex: 2,
                                            //     child: Text("Null"))

                                          ],

                                        ),
                                      //  VerticalSpacing(10),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: Divider(
                                            color: AppColors.darkGrey,
                                            thickness: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                              : Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Data Not Available"),
                          ),







                        ])


                ),

              ],)),

              bottomNavigationBar:
              model.copex_detailslist[0].grandtotal.isNotEmpty ?
              SafeArea(child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Remarks TextField
                          Expanded(
                            flex:5,
                            child: Container(
                              // width: 180,
                              child: TextField(
                                controller: model.remarkscontroller,
                                maxLines: null,
                                minLines: 1,
                                decoration: InputDecoration(
                                  labelText: 'Add Remarks',
                                  labelStyle: TextStyle(color: Colors.blueGrey),
                                  hintText: 'Type here...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blueGrey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                style: TextStyle(fontSize: 16, color: Colors.black),
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          /// Status Dropdown
                          Expanded(
                            flex:5,
                            child: Container(
                              height: 50,
                              // width: 110,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: model.initial == null
                                    ? Colors.blue.shade50
                                    : model.initial == "Approve"
                                    ? Colors.green.shade50
                                    : model.initial == "Reject"
                                    ? Colors.red.shade50
                                    : model.initial == "Revert"
                                    ? Colors.orange.shade50
                                    : AppColors.primary,
                                border: Border.all(
                                  color: model.initial == null
                                      ? Colors.blue.shade300
                                      : model.initial == "Approve"
                                      ? Colors.green
                                      : model.initial == "Reject"
                                      ? Colors.red
                                      : model.initial == "Revert"
                                      ? Colors.orange
                                      : Colors.grey.withOpacity(0.4),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: model.initial == "Select Status" ? null : model.initial,
                                hint: Row(
                                  children: [
                                    Icon(Icons.arrow_drop_down, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      "Select Status",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                underline: SizedBox(),
                                icon: SizedBox.shrink(),
                                items: [
                                  DropdownMenuItem(
                                    value: "Approve",
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                                        SizedBox(width: 8),
                                        Text("Approved",  style: TextStyle(fontSize: 14),
                                          softWrap: true,
                                          maxLines: null,
                                          overflow: TextOverflow.visible,),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "Reject",
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel, color: Colors.red, size: 18),
                                        SizedBox(width: 8),
                                        Text("Reject", style: TextStyle(fontSize: 14),
                                          softWrap: true,
                                          maxLines: null,
                                          overflow: TextOverflow.visible,),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "Revert",
                                    child: SizedBox(
                                      width: 200,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.restart_alt, color: Colors.orange, size: 18),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Revert to Department Head",
                                              style: TextStyle(fontSize: 14),
                                              softWrap: true,
                                              maxLines: null,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) async
                                {
                                  if (value == null) return;

                                  setState(() {
                                    model.initial = value;
                                  });

                                  String newValue = value == "Approve"
                                      ? "approved"
                                      : value == "Reject"
                                      ? "rejected"
                                      : value == "Revert"
                                      ? "revert"
                                      : "";
                                  print("Selected: $newValue");
                                  ApiService api = ApiService();
                                  final response = await api.update_final_copex_status(
                                      newValue,
                                     model.copex_detailslist[0].copexId,
                                      model.remarkscontroller.text,
                                     // model.copex_detailslist[0].capexType
                                  );
                                  print(response);
                                  if (response is Success) {
                                    final jsonResponse = response.data;
                                    if (jsonResponse != null && jsonResponse.containsKey("status")) {
                                      final status = jsonResponse["status"];
                                      final msg = jsonResponse["status_message"];

                                      if (status == 200 && newValue == "approved" || newValue == "rejected" || newValue == "revert" ) {
                                        Constants.customSuccessSnack(context, msg);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        NavService.capex_approval();
                                      }
                                      else {
                                        Constants.customErrorSnack(context, msg);
                                        setState(() {
                                          value = "Select Status";
                                        });


                                      }

                                      // if (status == 200) {
                                      //   Navigator.pop(context);
                                      // } else {
                                      //   print("Unexpected status code: $status");
                                      //   Constants.customErrorSnack(context, msg);
                                      // }

                                    } else {
                                      print("JSON response is null or 'status' is missing");
                                      Constants.customErrorSnack(context, "Something went wrong. Please try again.");
                                    }
                                  } else {
                                    if (response is Failure) {
                                      final errorMsg = response.error.toString(); // Or whatever your error object contains
                                      print("API Failure: $errorMsg");
                                      Constants.customErrorSnack(context, "Failed to update status. $errorMsg");
                                    } else {
                                      print("Unknown error in response: $response");
                                      Constants.customErrorSnack(context, "Unexpected error occurred.");
                                    }
                                  }


                                  (context as Element).markNeedsBuild();
                                },
                              ),
                            ),
                          ),
                        ],
                      )

                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12) ),
                      color: AppColors.primary, ),

                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:  [
                        Text(
                          "Total: ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),

                        Text(
                          'RS ${model.copex_detailslist[0].grandtotal}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )

                      ],
                    ),
                  )
                ],
              ),
              ):
              Container()
          ):
          Scaffold(body:

          Center(child: CircularProgressIndicator(color: AppColors.primary,),)),

          viewModelBuilder: () => Capex_detail_view_viewmodel(),
          onModelReady: (model) => model.init(context,widget.copex_id)
      );
  }
}




Widget approvalStage(String title, String status) {
  Color bgColor;
  Color textColor;
  IconData iconData;
  Color iconColor;

  switch (status.toLowerCase()) {
    case "approved":
      bgColor = Colors.green.shade50;
      textColor = Colors.green;
      iconData = Icons.check_circle;
      iconColor = Colors.green;
      break;

    case "rejected":
      bgColor = Colors.red.shade50;
      textColor = Colors.red;
      iconData = Icons.cancel;
      iconColor = Colors.red;
      break;

    case "pending":  // ← Added case for pending
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      iconData = Icons.hourglass_top;
      iconColor = Colors.orange.shade800;
      break;

    default:
      bgColor = Colors.grey.shade300;
      textColor = Colors.black54;
      iconData = Icons.radio_button_unchecked;
      iconColor = Colors.grey.shade600;
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(
          iconData,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(color: textColor, fontSize: 14),
        ),
      ],
    ),
  );
}


Widget buildExpenseItem({
  required String title,
  required String subtitle,
  required String branch,
  required List<Widget> quotations,
  required double rate,
  required int qty,
}) {
  return
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            offset: Offset(0, 6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0, // We handle shadow in BoxDecoration
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(subtitle),
              const SizedBox(height: 4),
              if(branch.isNotEmpty)
                Text("Branch Requested For: $branch",
                    style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),

              // Quotations Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: quotations),
              ),
              const SizedBox(height: 12),

              // Rate, Qty, Total, Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  columnItem("Rate", "${rate.toStringAsFixed(0)} Rs"),
                  columnItem("Qty", "$qty"),

                  columnItem(
                    "Total",
                    "${NumberFormat.decimalPattern('en_IN').format(rate * qty)} Rs",
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );

}



class HeadingTextRow extends StatelessWidget {
  final String heading;
  final String value;
  final Color headingColor;
  final Color valueColor;
  final double spacing;
  final double headingFontSize;
  final double valueFontSize;
  final FontWeight headingWeight;
  final FontWeight valueWeight;

  const HeadingTextRow({
    Key? key,
    required this.heading,
    required this.value,
    this.headingColor = Colors.black54,
    this.valueColor = AppColor.primary,
    this.spacing = 8.0,
    this.headingFontSize = 14,
    this.valueFontSize = 14,
    this.headingWeight = FontWeight.w400,
    this.valueWeight = FontWeight.w500,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$heading:",
          style: TextStyle(
            color: headingColor,
            fontSize: headingFontSize,
            fontWeight: headingWeight,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: valueFontSize,
              fontWeight: valueWeight,
            ),
          ),
        ),
      ],
    );
  }
}

void showCopexLogsDialog(BuildContext context, List<CopexLog> copexLogs) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child:
          copexLogs.isNotEmpty ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: copexLogs.map((log) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: 500,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Remarks: ${log.remarks}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text("Posted by: ${log.username}"),
                      SizedBox(height: 4),
                      Text("Date: ${log.postedDate}"),
                    ],
                  ),
                ),
              );
            }).toList(),
          ) : Text("No History Found")
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Close"),
          ),
        ],
      );
    },
  );
}

void showQuotationDialog({
  required BuildContext context,
  required String vendor,
  required String description,
  required double price,
  required int qty,
  required bool isSelected,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// Top Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vendor,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: Colors.green, size: 22),
                ],
              ),

              const SizedBox(height: 16),

              /// Quotation URL (Clickable)
              InkWell(
                onTap: () async {
                  final Uri uri = Uri.parse(description);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch URL')),
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.link, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Price & Quantity Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Price: ₹${price.toStringAsFixed(0)}    |    Qty: $qty",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Close Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.redAccent),
                  label: Text(
                    "Close",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}





void showQuotationListDialog({
  //required String copex_id,
  // required String copex_product_id,
  required BuildContext context,
  required List<Quotation> quotations,
}) {
  showDialog(
    context: context,
    builder: (context) {
      int selectedValue = -1; // default: no selection

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(maxHeight: 350, minWidth: 300),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Vendor Quotations",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  quotations.isNotEmpty
                      ? Expanded(
                    child: ListView.separated(
                      itemCount: quotations.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final quo = quotations[index];

                        return quotationTile(
                          vendor: quo.vendorName,
                          description: quo.fileUrl ?? "",
                          price: double.tryParse(quo.vendorPrice.toString()) ?? 0.0,
                          qty: int.tryParse(quo.qty.toString()) ?? 0,
                          total: quo.totalPrice.toString(),
                          isSelected: quo.quoteStatus == "1" ? true: false,
                          radioValue: index,
                          groupValue: selectedValue,
                          onChanged: (val) {
                            setState(() {
                              selectedValue = val!;
                         //     print("copex_id: ${copex_id}");
                              print("quot_id: ${quo.quot_id}");
                              print("quot_id: ${quo.vendorPrice}");
                           //   print("copex product id: ${copex_product_id}");

                            });
                          },
                        );
                      },
                    ),
                  )
                      : Center(child: Text("No Data Found")),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}



Widget quotationTile({
  required String vendor,
  required String description,
  required double price,
  required String total,
  required int qty,
  required bool isSelected,
  required int radioValue,
  required int groupValue,
  required ValueChanged<int?> onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: isSelected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.primary,
        width: 1,
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isSelected ?
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "$vendor:",
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

      ],
    ) :
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                "$vendor:",
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<int>(
                  value: radioValue,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  splashRadius: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  'Select',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ) ,
        /// LINK TEXT
        InkWell(
          onTap: () async {
            try {
              final Uri uri = Uri.parse(description);
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            } catch (_) {}
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Text(
              "See Quotations",
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),

        /// PRICE & TOTAL
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text(
              "Price: ${NumberFormat.decimalPattern('en_IN')
      .format(price)} | Qty: $qty",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            Text(
              "Total: ${
                NumberFormat.decimalPattern('en_IN')
                    .format(int.parse(total))}",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget columnItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }


