// import 'package:ess/Ess_App/generated/assets.dart';
// import 'package:ess/Ess_App/src/base/utils/utils.dart';
// import 'package:ess/Ess_App/src/shared/spacing.dart';
// import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
// import 'package:ess/Ess_App/src/styles/app_colors.dart';
// import 'package:ess/Ess_App/src/styles/text_theme.dart';
// import 'package:ess/Ess_App/src/views/notification/notification_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:stacked/stacked.dart';
//
// import '../../models/api_response_models/Notification.dart';
//
// class NotificationView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ViewModelBuilder<NotificationViewModel>.reactive(
//       builder: (context, model, child) => SafeArea(
//         child:
//         Scaffold(
//           backgroundColor: Colors.grey[100],
//           body: SafeArea(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   notiAppBar(
//                     title: "Notifications",
//                     onMenuTap: () {
//                       Navigator.pop(context);
//                     },
//                     onNotificationTap: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//
//                   model.data.isEmpty
//                       ? Container(
//                     height: context.screenSize().height - 110,
//                     width: context.screenSize().width,
//                     alignment: Alignment.center,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           Assets.imagesNothingHere,
//                           height: 200,
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           "Data Not Available",
//                           style: TextStyling.bold18.copyWith(
//                             color: AppColors.primary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                       : Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: model.data.length,
//                       itemBuilder: (BuildContext context, index) {
//                         final noti = model.data[index];
//                         final formattedDate = DateFormat.yMMMd().format(noti.timestamp!);
//                         final formattedTime = DateFormat.jm().format(noti.timestamp!);
//
//                         return AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(12),
//                               onTap: () => model.toggleExpand(index),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Icon(Icons.notifications_none, color: AppColors.primary),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             noti.title ?? 'No Title',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 16,
//                                               color: AppColors.primary,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 6),
//                                           AnimatedSize(
//                                             duration: const Duration(milliseconds: 300),
//                                             curve: Curves.easeInOut,
//                                             child: ConstrainedBox(
//                                               constraints: model.expandedList[index]
//                                                   ? const BoxConstraints()
//                                                   : const BoxConstraints(maxHeight: 40),
//                                               child: Text(
//                                                 noti.body ?? '',
//                                                 style: const TextStyle(
//                                                   fontSize: 13,
//                                                   color: Colors.black87,
//                                                 ),
//                                                 softWrap: true,
//                                                 overflow: TextOverflow.fade,
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(height: 10),
//                                           Row(
//                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(
//                                                 formattedTime,
//                                                 style: const TextStyle(
//                                                   fontSize: 11,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 formattedDate,
//                                                 style: const TextStyle(
//                                                   fontSize: 11,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         )
//
//       ),
//       viewModelBuilder: () => NotificationViewModel(),
//       onModelReady: (model) => model.init(context),
//     );
//   }
// }



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
          child:
          Scaffold(
            backgroundColor: Colors.grey[100],
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => model.init(context),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 2,
                      centerTitle: true,
                      title: Text(
                        'Notifications',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      leading:
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                          child:
                          IconButton(
                            icon: Icon(

                                Icons.arrow_back, color: AppColors.primary),
                            onPressed: () => Navigator.pop(context),
                          ),
                          // actions: [
                          //
                          // ],
                        ),
                      ),
                    ),

                    model.data.isEmpty
                        ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(Assets.imagesNothingHere, height: 200),
                              const SizedBox(height: 24),
                              Text(
                                'No Notifications Yet',
                                style: TextStyling.bold18.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pull down to refresh',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final noti = model.data[index];
                            final date = DateFormat.yMMMd().format(noti.timestamp!);
                            final time = DateFormat.jm().format(noti.timestamp!);
                            final isExpanded = model.expandedList[index];

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => model.toggleExpand(index),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.notifications, color: AppColors.primary),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                noti.title ?? 'Notification',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        AnimatedSize(
                                          duration: const Duration(milliseconds: 300),
                                          child: ConstrainedBox(
                                            constraints: isExpanded
                                                ? BoxConstraints()
                                                : BoxConstraints(maxHeight: 50),
                                            child: Text(
                                              noti.body ?? '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              time,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              date,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: model.data.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )


      ),
      viewModelBuilder: () => NotificationViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}