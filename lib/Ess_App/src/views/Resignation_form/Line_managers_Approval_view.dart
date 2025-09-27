import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../base/utils/constants.dart';
import '../../services/remote/api_result.dart';
import '../../services/remote/api_service.dart';
import '../../shared/loading_indicator.dart';
import '../../shared/top_app_bar.dart';
import 'Hod_approval_view_model.dart';
import 'Line_manager_Approval_view_model.dart';



class LineManagersApprovalView extends StatefulWidget {


  @override
  State<LineManagersApprovalView> createState() => _HodApprovalViewState();
}

class _HodApprovalViewState extends State<LineManagersApprovalView> {
  @override
  Widget build(BuildContext context) {
    return
      ViewModelBuilder<LineManagerApprovalViewModel>.reactive(
        builder: (viewModelContext, model, child) =>

            Scaffold(

              body:
              model.isBusy
                  ? Center(child: LoadingIndicator())
                  :
              Column(
                children: [
                  SizedBox(height: 15,),
                  GeneralAppBar(
                    title: "Line Manager Approval",
                    onMenuTap: () => Scaffold.of(context).openDrawer(),
                    onNotificationTap: () {},
                  ),
                  Expanded(
                    child:
                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: model.datalist.length,
                      itemBuilder: (context, index) {
                        final item = model.datalist[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item['emp_name'] ?? '',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.indigo[900],
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(item['designation'] ?? ''),
                                      backgroundColor: Colors.indigo.shade50,
                                      labelStyle: TextStyle(color: Colors.indigo, fontSize: 12),
                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                                /// --- Two Column Layout
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    /// Left Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          _infoRow(Icons.apartment, "${item['emp_dept']} • ${item['branch']} (${item['region']})"),
                                          SizedBox(height: 8),
                                          _infoRow(Icons.phone_android, item['contact']),
                                          SizedBox(height: 8),
                                          _infoRow(Icons.badge, "CNIC: ${item['cnic']}"),
                                          SizedBox(height: 8),
                                          _infoRow(Icons.person, "Father: ${item['father_name']}"),
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 16),

                                    /// Right Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _infoRow(Icons.calendar_today, "Joined: ${item['date_of_joining']}"),
                                          SizedBox(height: 8),
                                          _infoRow(Icons.exit_to_app, "Resigned: ${item['date_of_resign']}"),
                                          SizedBox(height: 8),
                                          _infoRow(Icons.timelapse, "Notice Period: ${item['notice_period']} days"),
                                          SizedBox(height: 8),
                                          _infoRow(Icons.event_busy, "Last Working Day: ${item['last_day']}"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12),
                                Divider(),

                                /// --- Reason for Leaving
                                _infoRow(
                                  Icons.info_outline,
                                  item['reason'] ?? '',
                                  italic: true,
                                  maxLines: 3,
                                ),

                                /// --- Attachment Button
                                if ((item['attachment'] ?? '').isNotEmpty)
                                // Align(
                                //   alignment: Alignment.centerLeft,
                                //   child: TextButton.icon(
                                //     onPressed: () => _launchURL(item['attachment']!),
                                //     icon: Icon(Icons.picture_as_pdf, size: 18),
                                //     label: Text("View PDF"),
                                //     style: TextButton.styleFrom(
                                //       foregroundColor: Colors.indigo,
                                //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                //       textStyle: TextStyle(fontSize: 13),
                                //     ),
                                //   ),
                                // ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                    children: [
                                      if ((item['attachment'] ?? '').isNotEmpty)
                                        Expanded(
                                          // flex: 6,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton.icon(
                                              onPressed: () async
                        {
                          try {
                            final Uri uri = Uri.parse(item['attachment']);
                            final bool launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!launched) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                    content:
                                    Text('Could not launch URL')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error launching URL: $e')),
                            );
                          }
                        },
                                              icon: Icon(Icons.picture_as_pdf, size: 18),
                                              label: Text("View PDF"),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.indigo,
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                textStyle: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          ),
                                        ),

                                      //SizedBox(width: 10,),
                                      /// Status Dropdown
                                      Container(
                                        width: 90, // Reduced from 70
                                        height: 40, // Reduced from 50
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0), // Less padding
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
                                          borderRadius: BorderRadius.circular(16), // Slightly smaller radius
                                        ),
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: model.initial == "Select Status" ? null : model.initial,
                                          hint: Row(
                                            children: [
                                              Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                "Select",
                                                style: TextStyle(color: Colors.white, fontSize: 12),
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
                                                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                                                  SizedBox(width: 6),
                                                  Text("Approved", style: TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: "Reject",
                                              child: Row(
                                                children: [
                                                  Icon(Icons.cancel, color: Colors.red, size: 16),
                                                  SizedBox(width: 6),
                                                  Text("Reject", style: TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: "Revert",
                                              child: Row(
                                                children: [
                                                  Icon(Icons.restart_alt, color: Colors.orange, size: 16),
                                                  SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      "Revert",
                                                      style: TextStyle(fontSize: 12),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) async {
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
                                            final response = await api.resignation_approval(
                                              item['fnf_id'],
                                              newValue,
                                              "line_manager",

                                            );

                                            if (response is Success) {
                                              final jsonResponse = response.data;
                                              if (jsonResponse != null && jsonResponse.containsKey("status")) {
                                                final status = jsonResponse["status"];
                                                final msg = jsonResponse["status_message"];

                                                if (status == 200 &&
                                                    (newValue == "approved" ||
                                                        newValue == "rejected" ||
                                                        newValue == "revert")) {
                                                  Constants.customSuccessSnack(context, msg);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                } else {
                                                  Constants.customErrorSnack(context, msg);
                                                  setState(() {
                                                    value = "Select Status";
                                                  });
                                                }
                                              } else {
                                                Constants.customErrorSnack(context, "Something went wrong.");
                                              }
                                            } else if (response is Failure) {
                                              Constants.customErrorSnack(context, "Failed: ${response.error}");
                                            } else {
                                              Constants.customErrorSnack(context, "Unexpected error occurred.");
                                            }

                                            (context as Element).markNeedsBuild();
                                          },
                                        ),
                                      )


                                      //   Align(
                                      //   alignment: Alignment.centerRight,
                                      //   child: TextButton.icon(
                                      //     onPressed: () {
                                      //
                                      //
                                      //     },
                                      //     icon: Icon(Icons.approval, size: 18),
                                      //     label: Text("Approval"),
                                      //     style: TextButton.styleFrom(
                                      //       backgroundColor: AppColors.primary,
                                      //       foregroundColor: Colors.white,
                                      //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      //       textStyle: TextStyle(fontSize: 13),
                                      //     ),
                                      //   ),
                                      // ),
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

        viewModelBuilder: () => LineManagerApprovalViewModel(),
        onModelReady: (model) => model.init(context),
      );
  }

  void _launchURL(String url) async {
    print(url);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url),
      ),
    );
  }

  Widget _infoRow(IconData icon, String? text, {bool italic = false, int? maxLines}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text ?? '',
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
            style: TextStyle(
              fontSize: 13,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}


class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Web Page"),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
