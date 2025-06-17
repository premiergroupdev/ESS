import 'package:ess/Ess_App/generated/assets.dart';
import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:ess/Ess_App/src/shared/spacing.dart';
import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:ess/Ess_App/src/views/notification/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:stacked/stacked.dart';

import '../../models/api_response_models/Notification.dart';

class NotificationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationViewModel>.reactive(
      builder: (context, model, child) => SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(

              children: [
                GeneralAppBar(
                    title: "Notifications",

                    onMenuTap: () {
Navigator.pop(context);
                    },
                    onNotificationTap: () {
                      Navigator.pop(context);
                    }),

                model.data.isEmpty ?
                Container(

                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: context.screenSize().height - 110,
                  width: context.screenSize().width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.imagesNothingHere,
                        height: 200,
                      ),
                      VerticalSpacing(),
                      Text("Data Not Available", style: TextStyling.bold18.copyWith(color: AppColors.primary),)
                    ],
                  ),
                ) :
                 Container(
                 height: 600,
                   child: ListView.builder(
                      itemCount: model.data.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, index) {
                        Notification_model noti = model.data[index];
                        String formattedDate = DateFormat.yMMMd().format(noti.timestamp!); // E.g., 'Jul 23, 2024'
                        String formattedTime = DateFormat.jm().format(noti.timestamp!);

                        return


                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                            child: GestureDetector(
                              onTap: () => model.toggleExpand(index), // Toggle expansion on tap
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.notifications, color: AppColors.primary),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          Text(
                                            noti.title ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis, // Handle overflow
                                          ),
                                          SizedBox(height: 5),
                                          // Body
                                          AnimatedSize(
                                            duration: Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            child: ConstrainedBox(
                                              constraints: model.expandedList[index]
                                                  ? BoxConstraints()
                                                  : BoxConstraints(maxHeight: 40), // Adjust height to fit your needs
                                              child: Text(
                                                noti.body ?? '',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.fade,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          // Formatted Time
                                          Text(
                                            formattedTime,
                                            style: TextStyle(
                                              color: AppColors.black,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    // Formatted Date
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                      },
                    ),
                 ),

              ],
            ),
          ),
        ),
      ),
      viewModelBuilder: () => NotificationViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}
