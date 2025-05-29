import 'package:ess/Ess_App/generated/assets.dart';
import 'package:ess/Ess_App/src/views/dashboard/widget/Stats_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Ess_App/src/shared/loading_indicator.dart';
import 'package:ess/Ess_App/src/shared/spacing.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:ess/Ess_App/src/views/dashboard/widget/br.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';
import '../../models/api_response_models/My_smart_goals.dart';
import '../local_db.dart';
import '../menu/menu_view.dart';
import '../your_attandence/widget/Attendance_widget.dart';
import '../your_attandence/widget/attendence_data_table.dart';
import 'dashboard_view_model.dart';


class DashboardView extends StatefulWidget {
  DashboardView({Key? key}) : super(key: key);



  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String status = "";
  DatabaseHelper db = DatabaseHelper();
  final ScrollController scrollController = ScrollController();

  DateTime? parseMaxCheckInTime(String? timeString) {
    if (timeString == null) {
      return null;
    }
    return DateFormat('HH:mm').parse(timeString);
  }
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard!'),
        ),
      );
    });
  }

@override
  void initState() {

    super.initState();
  }

  @override

  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
      builder: (viewModelContext, model, child) => model.isBusy
          ?
      Scaffold(
           body: Center(
        child: Padding(
            padding:  EdgeInsets.all(8.0),
            child: LoadingIndicator(),
        ),
      ),
          )
          :
          Scaffold(
            drawer: MenuView(),
            body:

              SingleChildScrollView(

                child: Column(
                children: [
                  CustomHeader(
                    title: model.currentUser?.userName ??
                        model.currentUser?.email ??
                        "null",
                    onMenuTap: () {
                      Scaffold.of(context).openDrawer();

                    },
                    onNotificationTap: () {   NavService.notification();  },),




                Column(

                        children: [

                                  if(model.dataMap.isNotEmpty)

                                VerticalSpacing(30),
                          Padding(
                            padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(

                                children: [
                                  Text(
                                    'Leaves Balance',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  VerticalSpacing(12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      leavesCart(
                                        context,
                                        "Annual Leaves",
                                        model.dashboard?.annualLeaves.toString() ?? "0",
                                        Assets.imagesAnnual,
                                      ),
                                      SizedBox(width: 10),
                                      leavesCart(
                                        context,
                                        "Casual Leaves",
                                        model.dashboard?.casualLeaves.toString() ?? "0",
                                        Assets.imagesCasual,
                                      ),
                                      SizedBox(width: 10),
                                      leavesCart(
                                        context,
                                        "Sick Leaves",
                                        model.dashboard?.sickLeaves.toString() ?? "0",
                                        Assets.imagesSick,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          if(model.stats_status == "yes")
                          StatsSection(stats_resposne: model.response,),

                          // Check-in Time (Last 7 Days)
                          _buildCheckInTime(model.all),

                                                       // Container(
                                                       //   height: 300,
                                                       //   child: HomePage(
                                                       //     data: model.check,
                                                       //     end: parseMaxCheckInTime(model.maxCheckInFormatted),
                                                       //   ),
                                                       // ),

                                                       InkWell(
                                                         onTap: () {
                                                           NavService.applyVisit();
                                                         },
                                                         child: Row(
                                                           mainAxisAlignment: MainAxisAlignment.center,
                                                           children: [
                                                             Image.asset(
                                                               "assets/images/r.png",
                                                               height: 150,
                                                               width: 90,
                                                             ),
                                                             Container(
                                                               height: 50,

                                                               margin: EdgeInsets.symmetric(horizontal: 50),
                                                               decoration: BoxDecoration(
                                                                 gradient: LinearGradient(
                                                                   colors: [
                                                                     AppColors.primary,
                                                                     AppColors.primary
                                                                   ],
                                                                   begin: Alignment.topLeft,
                                                                   end: Alignment.bottomRight,
                                                                 ),
                                                                 boxShadow: [
                                                                   BoxShadow(
                                                                     color: AppColors.primary.withOpacity(0.5),
                                                                     spreadRadius: 1,
                                                                     blurRadius: 4,
                                                                     offset: Offset(0, 3),
                                                                   )
                                                                 ],
                                                                 borderRadius: BorderRadius.circular(16),
                                                               ),
                                                               padding: EdgeInsets.all(6),
                                                               child: Row(
                                                                   mainAxisAlignment: MainAxisAlignment.center,
                                                                   children: [
                                                                     Text(
                                                                       "APPLY VISIT",
                                                                       style: TextStyle(
                                                                           color: AppColors.white,
                                                                           fontSize: 13,
                                                                           fontWeight: FontWeight.bold),
                                                                     ),
                                                                     Image.asset("assets/images/arrow.png"),
                                                                   ],
                                                                 ),
                                                               ),

                                                           ],
                                                         ),
                                                       ),
                                                       Padding(
                                                         padding: const EdgeInsets.symmetric(horizontal: 20),
                                                         child:
                                                         Row(

                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                           children: [
                                                             Text(""),
                                                             Text(
                                                               "MY GOALS",
                                                               style: GoogleFonts.poppins(
                                                                 color: AppColors.primary,
                                                                 fontSize: 20,
                                                                 fontWeight: FontWeight.bold,
                                                               ),
                                                             ),
                                                             InkWell(
                                                               onTap: () {
                                                                 NavService.smartgoal();
                                                               },
                                                               child: Container(
                                                                 decoration: BoxDecoration(
                                                                   boxShadow: [
                                                                     BoxShadow(
                                                                       color: AppColors.primary.withOpacity(0.5),
                                                                       spreadRadius: 1,
                                                                       blurRadius: 4,
                                                                       offset: Offset(0, 3),
                                                                     )
                                                                   ],
                                                                   color: AppColors.white,
                                                                   borderRadius: BorderRadius.circular(10),
                                                                 ),
                                                                 padding: EdgeInsets.all(6),
                                                                 child: Text(
                                                                   "See All",
                                                                   style: TextStyle(
                                                                       color: AppColors.primary,
                                                                       fontSize: 12,
                                                                       fontWeight: FontWeight.bold),
                                                                 ),
                                                               ),
                                                             ),
                                                           ],
                                                         ),
                                                       ),
                                                       VerticalSpacing(10),
                                                       if (model.Goal != null)
                                                         SingleBox(data: model.Goal),
                                VerticalSpacing(25),

                          Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 19),
                            child: Text(
                              "LAST 30 DAYS ATTENDANCE",
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                          ),
                                SizedBox(height: 15,),
                                // Container(
                                //   padding:EdgeInsets.symmetric(horizontal: 10),
                                //
                                //
                                //     child:
                          Container(
                            height: 40,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: ListView.builder(

                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              itemCount: model.statuses.length,
                              itemBuilder: (context, index) {
                                var data = model.statuses[index];

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      model.selectedIndex = index;
                                      model.filterDataByStatus(data);
                                    });
                                  },
                                  child:
                                  data !='' ?
                                  Container(
                                    alignment: Alignment.center,
                                    width: 100, // Set a fixed width for each item
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: model.selectedIndex == index ? AppColors.primary : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        data,
                                        style: TextStyle(
                                          color: model.selectedIndex == index ? AppColors.white : Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                      :Container()
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 15),
                          if (model.filteredData.isNotEmpty)


                               Container(
                                 height: 500,
                                 child: ListView.builder(
                                  shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    itemCount: model.filteredData.length,
                                    itemBuilder: (context, index) {
                                      var datalist = model.filteredData[index];


                                      String checkIn = (datalist.checkIn is List) ? datalist.checkIn[0] : datalist.checkIn;
                                      String checkOut = (datalist.checkOut is List) ? datalist.checkOut[0] : datalist.checkOut;
                                      int hoursDifference = model.calculateHourDifference(checkIn, checkOut);
                                      if(hoursDifference <0 )
                                      {
                                        hoursDifference =0;
                                      }

                                      return
                                        Slidable(
                                            enabled: (datalist.statusColor == Colors.orange && datalist.day != "Sun"),
                                            key: ValueKey(datalist.date.toString()),
                                            endActionPane: ActionPane(
                                              motion: ScrollMotion(),
                                              children: [
                                                SlidableAction(
                                                  flex: 2,
                                                  onPressed: (_) {
                                                    NavService.applyLeave();
                                                  },
                                                  backgroundColor: AppColors.primary,
                                                  foregroundColor: Colors.white,
                                                  label: 'Apply Leave',
                                                  padding: EdgeInsets.symmetric(vertical: 15),
                                                ),


                                              ],
                                            ),
                                            child:


                                            Container(

                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Colors.blue.withOpacity(0.1),

                                              ),
                                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height:  datalist.Attendstatus != "Absent"  ? 62 : 74,
                                                      margin: EdgeInsets.only(right: 12),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary,
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(16),
                                                          bottomLeft: Radius.circular(16),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(
                                                                  datalist.date,
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      "Work hours: ",
                                                                      style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: AppColors.primary,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      hoursDifference.toString(),
                                                                      style: TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        color: AppColors.primary,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 8),
                                                            Row(

                                                              children: [
                                                                Icon(Icons.arrow_downward, size: 14, color: AppColors.primary,),
                                                                Text("${datalist.checkIn }", style: TextStyle(color: Colors.grey, fontSize: 12),),
                                                                HorizontalSpacing(7),
                                                                Icon(Icons.arrow_upward, size: 14 , color: AppColors.primary),
                                                                Text("${datalist.checkOut}", style: TextStyle(color: Colors.grey, fontSize: 12),),
                                                                Spacer(),
                                                                if(datalist.Attendstatus == "Absent" && datalist.day != "Sun")

                                                                  Lottie.asset(Assets.imagesSwapLottie, height:28, width: 30,)
                                                                ,                                     Row(
                                                                  children: [
                                                                    if( datalist.day != "Sun")
                                                                    Container(
                                                                      padding: const EdgeInsets.all(3.0),
                                                                      decoration: BoxDecoration(
                                                                        color: datalist.statusColor,
                                                                        borderRadius: BorderRadius.circular(
                                                                            4
                                                                        ),
                                                                      ),
                                                                      child: Text(
                                                                        datalist.Attendstatus.toString(),
                                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400 ,fontSize: 10),
                                                                      ),
                                                                    ),
                                                                    if( datalist.day == "Sun")
                                                                    Container(
                                                                      padding: const EdgeInsets.all(3.0),
                                                                      decoration: BoxDecoration(
                                                                        color: AppColors.primary,
                                                                        borderRadius: BorderRadius.circular(
                                                                            4
                                                                        ),
                                                                      ),
                                                                      child: Text(
                                                                        "Weekend",
                                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400 ,fontSize: 10),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),

                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ));
                                    },
                                  ),
                               ),


                          if (model.filteredData.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Data Not Available",
                                style: TextStyling.bold18.copyWith(color: AppColors.darkGrey),
                              ),
                            ),


                        ],
                      ),

                ],
        ),
              ),








          ),
      viewModelBuilder: () => DashboardViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}























Widget leavesCart(BuildContext context, String title, String count, String icon) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        width: screenWidth * 0.28, // adjust as per design
        height: screenHeight * 0.16, // relative height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: screenHeight * 0.06,
              width: screenHeight * 0.06,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: screenWidth * 0.03,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              count,
              style: TextStyling.text14.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}

class SingleBox extends StatefulWidget {
   List<goal>? data;

  SingleBox({Key? key, required this.data}) : super(key: key);
  @override
  State<SingleBox> createState() => _SingleBoxState();
}
class _SingleBoxState extends State<SingleBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: List.generate(widget.data!.length, (index) {
          goal mygoal = widget.data![index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
//color: AppColors.primary,
                gradient: LinearGradient(
                  colors: [ AppColors.primary, AppColors.secondary ],
                  // Replace with your gradient colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),

              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),

                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset("assets/images/goal.png",
                            height: 40,
                            width: 40,

                          ),
                        ),
                      ),

                      SizedBox(width: 5,),
                      Expanded(
                        child: Text(
                        mygoal.goal_name,
                          style: GoogleFonts.poppins(

          color: AppColors.white,
          fontSize: 14,

          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${mygoal.weightage}%', // Percentage sign
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontSize: 16,

                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        ),
      ),
    );
  }
}
class CustomHeader extends StatelessWidget {
  final String title;  // Title parameter
  final VoidCallback onMenuTap;  // Callback for menu tap
  final VoidCallback onNotificationTap;  // Callback for notification tap

  const CustomHeader({
    Key? key,
    required this.title,
    required this.onMenuTap,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Transform.translate(
          offset: Offset(0, 0), // Move upward to fill gap
          child: Transform.rotate(
            angle: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(4, 4),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
        ),

        // Header content
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // Menu icon with onTap action
                  InkWell(
                    onTap: onMenuTap,
                    child: Icon(Icons.menu, color: Colors.white),
                  ),
                  // Title text (passed as a parameter)
                  Text(
                    "Dashboard",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Notification icon with onTap action
                  InkWell(
                    onTap: onNotificationTap,
                    child: Icon(Icons.notification_add, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 12,),
              Text(
                "Hello,\n ${title}",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Welcome back! Here’s your summary.',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }
}
Widget _buildCheckInTime(List<AttendenceTableData> data) {
  return
Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Check-in Time (Last 7 Days)',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: data.length > 7 ? 7 : data.length,
              itemBuilder: (context, index) {
                var datalist= data[index];
                return

                  Container(

                  width: 90,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Text(
                        datalist.day.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,

                          ),
                        ),
                        VerticalSpacing(5),
                        Text(
                          datalist.checkIn != "12:00 AM" ? '${datalist.checkIn}' : "OFF",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

  );
}
class ChartData {
  final String label;
  final int value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}
class AttendanceHorizontalList extends StatelessWidget {
  final List<Map<String, dynamic>> attendanceData = List.generate(30, (index) {
    DateTime date = DateTime.now().subtract(Duration(days: index));
    return {
      "date": "${date.day}-${date.month}-${date.year}",
      "status": index % 5 == 0 ? "Absent" : "Present"
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Last 30 Days Attendance"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: attendanceData.map((item) {
              return Container(
                width: 120,
                margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item['status'] == "Present" ? Colors.green[200] : Colors.red[200],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(3, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['date'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Icon(
                      item['status'] == "Present" ? Icons.check_circle : Icons.cancel,
                      color: item['status'] == "Present" ? Colors.green : Colors.red,
                      size: 35,
                    ),
                    SizedBox(height: 8),
                    Text(
                      item['status'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
