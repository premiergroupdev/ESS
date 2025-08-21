import 'dart:math';

import 'package:ess/Ess_App/src/configs/app_setup.router.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Learning_management_system/Utilis/colors.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../base/utils/constants.dart';
import '../../models/api_response_models/Traval_Expense.dart';
import '../../services/remote/api_result.dart';
import '../../services/remote/api_service.dart';
import '../../shared/top_app_bar.dart';
import 'package:intl/intl.dart';
import '../Loan/webview.dart';
import 'Expense_approval_view_model.dart';


class Expense_approval extends StatefulWidget {
  @override
  State<Expense_approval> createState() => _Expense_approvalState();
}

class _Expense_approvalState extends State<Expense_approval> {
  final NumberFormat currencyFormat =
  NumberFormat.currency(locale: 'en_PK', symbol: 'PKR ', decimalDigits: 0);

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _showRouteDialog(BuildContext context, List<Routelist> routeList) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            minWidth: 300,
            maxHeight: MediaQuery.of(context).size.height * 0.8, // Limit height for overflow
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Let column take only needed height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    "📍 Route Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              // Route list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(), // Smooth scroll
                  itemCount: routeList.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.grey.shade300,
                    height: 16,
                  ),
                  itemBuilder: (context, index) {
                    final route = routeList[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Route ${index + 1}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 6),
                        _routeRow("Origin", route.origin.toString()),
                        Divider(),
                        _routeRow("Destination", route.destination.toString()),
                        Divider(),
                        _routeRow("Distance", route.distance.toString()),
                        Divider(),
                        _routeRow("Duration Day / Night", route.arrivalStatus.toString()),
                        Divider(),
                        _routeRow("Departure", route.depDate.toString()),
                        Divider(),
                        _routeRow("Arrival", route.arrival_data.toString()),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: 16),

              // Close button
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  label: Text(
                    "Close",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAttachmentsDialog(BuildContext context, List<Attachment> billsAttachments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.white, // Light background for clean design
          child: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: 500, // Set max height for dialog
              minWidth: 350, // Ensure enough space for buttons
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title - Clean and professional look
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Attachments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary, // Using your primary color
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // List of attachments with better spacing and style
                Expanded(
                  child: ListView.separated(
                    itemCount: billsAttachments.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12), // Space between items
                    itemBuilder: (context, i) {
                      final url = billsAttachments[i].attachments ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton.icon(
                          onPressed: url.isNotEmpty
                              ? () {
                            print(url);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(url: url),
                              ),
                            );
                          }
                              : null, // Disable button if URL is empty
                          icon: Icon(Icons.file_present, size: 22, color: Colors.white),
                          label: Text(
                            "File ${i + 1}",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: AppColors.primary, // White icon and text color
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded button corners
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            side: BorderSide(color: Colors.grey.shade300, width: 1), // Subtle border
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Close Button with smooth transition effect
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: AppColors.primary, // Matching the primary color for close button
                        fontSize: 16,

                      ),
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

  void showCommentsDialog(BuildContext context, List<Comment> comments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comments',style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,

          ),
            textAlign: TextAlign.center,),
          content: SizedBox(
            height: 100, // Adjust height as needed
            width: double.maxFinite, // Makes sure it takes up available width
            child: SingleChildScrollView(  // Allows scrolling if content overflows
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comments
                    .asMap()  // Convert to map to access the index
                    .map((index, e) {
                  return MapEntry(
                    index,
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0), // Optional padding between comments
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                              Text("${index + 1}:", style: TextStyle(color: Colors.black,),textAlign: TextAlign.start,),


                          SizedBox(width: 5,),
                          Expanded(
                            child: e.commentsLog != null  // Check if comment is not empty
                                ? Text.rich(
                              TextSpan(
                                text: "${e.commentsLog} ",  // The comment text
                                style: TextStyle(fontStyle: FontStyle.italic),
                                children: [
                                  TextSpan(
                                    text: "Commented by: ${e.commentsby}",  // The "Commented by" text
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                                : Text("Null"),  // If comment is empty, render nothing
                          ),

                          // Text("Commented by:")
                        ],
                      ),
                    ),
                  );
                })
                    .values
                    .toList(),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showApprovalStatusDialog(BuildContext context, List<ApprovalStatus> approvalStatusList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Approval Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            height: 100, // Adjust height based on your content
            width: double.maxFinite, // Makes sure the dialog takes available width
            child: SingleChildScrollView( // Allows scrolling if the content overflows
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: approvalStatusList
                    .map((status) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user, size: 16, color: AppColors.primary),
                      SizedBox(width: 5),
                      Flexible(  // Use Flexible to allow text wrapping
                        child: Text(
                          status.status ?? "No Status",
                          style: TextStyle(fontSize: 14),
                          softWrap: true,  // Ensure text wraps
                        ),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showExpenseDetailsDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Expense Details',style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
            textAlign: TextAlign.center,),
          content: SizedBox(
           // height: 200, // Adjust height as needed
            width: double.maxFinite, // Makes sure the dialog takes available width
            child: SingleChildScrollView( // Allows scrolling if content overflows
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      _routeRow("Daily Allowance ",  currencyFormat.format(int.tryParse(expense.dailyAllowance.toString()) ?? 0)),
                          _routeRow("Conveyance ",  currencyFormat.format(int.tryParse(expense.convExpense.toString()) ?? 0)),
                  _routeRow("Toll Tax ",  currencyFormat.format(int.tryParse(expense.tollTax.toString()) ?? 0)),

                  _routeRow("Bike Allowance ",  currencyFormat.format(int.tryParse(expense.bikeAllowance.toString()) ?? 0)),

                  _routeRow("Courier Allowance ",  currencyFormat.format(int.tryParse(expense.courierAllowance.toString()) ?? 0)),

                  _routeRow("Photo Allow ",  currencyFormat.format(int.tryParse(expense.photoAllow.toString()) ?? 0)),

                  _routeRow("Stationary Allow ",  currencyFormat.format(int.tryParse(expense.stationaryAllow.toString()) ?? 0)),
                  Divider(color: Colors.grey.shade300,),
                  _routetotal("Total", currencyFormat.format(expense.totalExpense ?? 0)),





                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showTravelDetailsDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Travel Details',style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
            textAlign: TextAlign.center,),
          content: SizedBox(
            // height: 200, // Adjust height as needed
            width: double.maxFinite, // Makes sure the dialog takes available width
            child: SingleChildScrollView( // Allows scrolling if content overflows
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _routeRow("Travel Id", expense.travelId.toString() ?? '0'),
                  _routeRow("Total Travel", "${expense.totalTravel.toString()} Km" ?? '0'),
                  _routeRow("Total Km Rate",  "${currencyFormat.format(int.tryParse(expense.totalKmRate.toString()) ?? 0)} Rs" ?? '0'),
                  _routeRow("Travel Type",  expense.travelType.toString()),
                  _routeRow("Reason of Travel",  expense.reasonOfTravel.toString()),





                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _routeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child:  Text(
                "$label:",
                style: TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              ),

          ),
          Expanded(
            flex: 1,
            child:  Text(
                value.isNotEmpty ? value : "-",
                textAlign: TextAlign.start,
              ),

          ),
        ],
      ),
    );
  }

  Widget _routetotal(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child:  Text(
              "$label:",
              style: TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.start,
            ),

          ),
          Expanded(
            flex: 1,
            child:  Text(
              value.isNotEmpty ? value : "-",
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),

            ),

          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<Expense_travel_viewmodel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        body: Column(
          children: [
            SizedBox(height: 20),
            GeneralAppBar(title: "Travel Expenses", onMenuTap: () {}, onNotificationTap: () {}),
            (model.isBusy == true)
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : Expanded(
              child: ListView.builder(
                itemCount: model.datalist.length ?? 0,
                padding: EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final expense = model.datalist[index];
                  final attachments = ((expense.billsAttachments ?? []) as List)
                      .map((e) => expense.billsAttachments.toString())
                      .toList();
                  final approvalStatus = ((expense.approvalStatus ?? []) as List).isNotEmpty
                      ? expense.approvalStatus
                      : "No Status";
                  final comments = ((expense.comments ?? []) as List).isNotEmpty
                      ? expense.comments
                      : null;
                  final routeList = (expense.route??[]) as List;
                  final route = routeList.isNotEmpty ? routeList[0] : null;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.3),
                          offset: Offset(0, 6),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Employee Header

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text( expense.empName.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                              Text(expense.grade.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 12))
                            ],
                          ),
                          SizedBox(height: 5),

                        Row(children: [
                          CircularIconAvatar(icon: Icons.person),

                          // Icon(Icons.directions_bus, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text("Emp Code: ${expense.empCode}", style: TextStyle(fontSize: 14)),
                        ]),


                        SizedBox(height: 5),
                          Row(
                            children: [
                              CircularIconAvatar(icon: Icons.apartment),
                             // Icon(Icons.apartment, size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text("Dept: ${expense.dept}", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              CircularIconAvatar(icon: Icons.receipt_long_rounded),
                              // Icon(Icons.apartment, size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text("Total Expense: ${currencyFormat.format(int.tryParse(expense.totalExpense.toString()) ?? 0)}", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        //  SizedBox(height: 5),
                          // Row(
                          //   children: [
                          //     CircularIconAvatar(icon: Icons.calendar_today),
                          //
                          //     //Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          //     SizedBox(width: 4),
                          //     Text("Posted: ${expense.postedDate}",
                          //         style: TextStyle(fontSize: 14, color: AppColors.primary)),
                          //   ],
                          // ),


                          /// Travel Info
                         //  Row(children: [
                         //    CircularIconAvatar(icon: Icons.directions_bus),
                         //
                         //   // Icon(Icons.directions_bus, size: 16, color: AppColors.primary),
                         //    SizedBox(width: 6),
                         //    Text("Travel Type: ${expense.travelType}", style: TextStyle(fontSize: 14)),
                         //  ]),
                         //  SizedBox(height: 5),
                         //  Row(children: [
                         //    CircularIconAvatar(icon: Icons.flight),
                         //
                         //    // Icon(Icons.directions_bus, size: 16, color: AppColors.primary),
                         //    SizedBox(width: 6),
                         //    Text("Total Traval: ${expense.totalTravel} Km", style: TextStyle(fontSize: 14)),
                         //  ]),
                         //
                         //  Row(children: [
                         //    CircularIconAvatar(icon: Icons.info_outline),
                         //
                         // //   Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                         //    SizedBox(width: 6),
                         //    Flexible(
                         //        child: Text("Reason: ${expense.reasonOfTravel}",
                         //            style: TextStyle(fontSize: 14))),
                         //  ]),
                         //
                         //  SizedBox(height: 20,),
                          /// Amounts
                          // Row(
                          //   children: [
                          //     Text(
                          //       "Total: ",
                          //       style: TextStyle(fontSize: 14),
                          //     ),
                          //     RichText(
                          //       text: TextSpan(
                          //         children: [
                          //           TextSpan(
                          //             text: currencyFormat.format(expense.totalExpense ?? 0),
                          //             style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 8),
                          // if ((expense.dailyAllowance ?? '').toString().isNotEmpty)
                          //   RichText(
                          //     text: TextSpan(
                          //       style: TextStyle(color: AppColors.primary), // default style for normal text
                          //       children: [
                          //         TextSpan( text:
                          //           "Daily Allowance: ",
                          //           style: TextStyle(fontSize: 13),
                          //         ),
                          //        // TextSpan(text: "Daily Allowance: "),
                          //         TextSpan(
                          //           text: currencyFormat.format(int.tryParse(expense.dailyAllowance.toString()) ?? 0),
                          //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // SizedBox(height: 8),
                          // if ((expense.convExpense ?? '').toString().isNotEmpty)
                          //   RichText(
                          //     text: TextSpan(
                          //       style: TextStyle(color: AppColors.primary),
                          //       children: [
                          //         TextSpan( text:
                          //         "Conveyance: ",
                          //           style: TextStyle(fontSize: 13, ),
                          //         ),
                          //         //TextSpan(text: "Conveyance: "),
                          //         TextSpan(
                          //           text: currencyFormat.format(int.tryParse(expense.convExpense.toString()) ?? 0),
                          //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          //
                           SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Button(title: 'View Travel Details', onTap: () {
                                  showTravelDetailsDialog(context, expense);
                                }, icon: Icons.account_balance_wallet,),
                              ),
                              SizedBox(width: 5,),
                              Expanded(
                                child:Button(title: 'View Allowances', onTap: () {
                                showExpenseDetailsDialog(context, expense);
                              }, icon: Icons.account_balance_wallet,),
                              )],
                          ),
SizedBox(height: 10,),
                          Row(children: [
                            if(expense.approvalStatus !=null && expense.approvalStatus!.isNotEmpty) ... [
                              Expanded(
                                child: Button(title: 'View Approvals', onTap: () {
                                  showApprovalStatusDialog(context, expense.approvalStatus!);
                                }, icon: Icons.verified_user,),
                              ),
                              SizedBox(width: 5,)
                            ],
                            /// Comments
                            if (comments != null && comments.isNotEmpty) ...[


                  Expanded(
                  child:  Button(title: 'View Comments', onTap: () {
                                showCommentsDialog(context, comments);
                              }, icon: Icons.comment,),
                  ),


                            ],

                            /// Attachments


                          ],),
                          SizedBox(height: 10,),
                          Row(children: [


                            /// Attachments
                            if (attachments.isNotEmpty) ...[


                              Expanded(
                                  child: Button(title: 'View Attanchments', onTap: () {
                                    showAttachmentsDialog(context  , expense.billsAttachments! );
                                  }, icon: Icons.attach_file,)

                              ),
                              SizedBox(width: 5,)],
                            (route != null) ?
                            Expanded(
                                child:Button(title: 'View Routes', onTap: () {
                                  _showRouteDialog(context, expense.route!);
                                }, icon: Icons.map,)): SizedBox(),
                            SizedBox(height: 10),
                          ],),
SizedBox(height: 12,),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
Text("Posted : ${expense.postedDate}", style: TextStyle(color: Colors.black, fontSize: 12),),

                              Align(
                                alignment: Alignment.centerRight,
                                child: PopupMenuButton<String>(
                                  initialValue: model.initial[index],
                                  onSelected: (value) async {
                                    model.initial[index] = value;
                                    print(expense.empCode);
                                    print(value);
                                    setState(() {
                                      // model.datalist.removeAt(index);
                                      // model.initial[index] = "Select Status";
                                    });
                                   String newValue = '';
                                    if(model.initial[index] == "Approve")
                                      {
                                        newValue ="approved";
                                      }
                                    else {
                                      newValue ="rejected";
                                    }
                                    ApiService api = ApiService();
                                    final response = await api.expensesapprovalstatus(newValue,
                                       expense.travelId.toString(),expense.empCode.toString()
                                    );

                                    if (response is Success) {
                                      final jsonResponse = response
                                          .data;

                                      // Check if jsonResponse is not null and contains the "status" property
                                      if (jsonResponse != null && jsonResponse.containsKey("status")) {
                                        final status = jsonResponse["status"];
                                        print("Status: $status");

                                        if (newValue == "approved") {
                                          print(newValue);
                                          Constants.customSuccessSnack(context, "Request is Approved");
                                        } else
                                        if (newValue == "rejected") {
                                          Constants.customSuccessSnack(context, "Request is Rejected");
                                        }

                                        if (newValue == "approved" || newValue == "rejected" || status == "200") {
                                          setState(() {
                                            model.datalist.removeAt(index);
                                            model.initial[index] = "Select Status";
                                          });
                                        }
                                      } else {
                                        // Handle the case where jsonResponse is null or "status" is missing
                                        print(
                                            "JSON response is null or 'status' is missing");
                                      }


                                    }
                                    (context as Element).markNeedsBuild();
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: "Approve",
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green, size: 18),
                                          SizedBox(width: 8),
                                          Text("Approve"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: "Reject",
                                      child: Row(
                                        children: [
                                          Icon(Icons.cancel, color: Colors.red, size: 18),
                                          SizedBox(width: 8),
                                          Text("Reject"),
                                        ],
                                      ),
                                    ),
                                  ],
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: model.initial[index]== null
                                          ? Colors.blue.shade50
                                          : model.initial[index]== "Approve"
                                          ? Colors.green.shade50
                                          : model.initial[index] == "Reject"
                                          ? Colors.red.shade50
                                           : AppColors.primary,
                                      border: Border.all(
                                        color: model.initial[index] == null
                                            ? Colors.blue.shade300
                                            : model.initial[index] == "Approve"
                                            ? Colors.green
                                            : model.initial[index] == "Reject"
                                            ? Colors.red
                                            : Colors.grey.withOpacity(0.4)

                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(

                                      children: [
                                        if(model.initial[index] != "Select Status")
                                        Icon(
                                          model.initial[index] == "Approve"
                                              ? Icons.check_circle
                                              : model.initial[index] == "Reject"
                                              ? Icons.cancel
                                              : null,
                                          color: model.initial[index] == "Approve"
                                              ? Colors.green
                                              : model.initial[index]== "Reject"
                                              ? Colors.red
                                              : AppColors.primary,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          model.initial[index] ?? "Select Status",
                                          style: TextStyle(
                                            color: model.initial[index] == "Approve"
                                                ? Colors.green.shade800
                                                : model.initial[index] == "Reject"
                                                ? Colors.red.shade800
                                                : Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
      viewModelBuilder: () => Expense_travel_viewmodel(),
      onModelReady: (model) => model.init(context),
    );
  }
}



class CircularIconAvatar extends StatelessWidget {
  final IconData icon;
  //final Color iconColor;
  //final Color backgroundColor;
  final double size; // Icon size
  final double radius; // Circle radius

  const CircularIconAvatar({
    Key? key,
    required this.icon,
    //this.iconColor = AppColors.primary,
   // this.backgroundColor = Colors.blue.withOpacity(0),
    this.size = 16,
    this.radius = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade50,
      child: Icon(
        icon,
        color: AppColors.primary,
        size: size,
      ),
    );
  }
}



class Button extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const Button({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
         // mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 17),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.primary,

                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
