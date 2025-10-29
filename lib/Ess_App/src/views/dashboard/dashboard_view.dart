import 'dart:math';
import 'package:ess/Ess_App/generated/assets.dart';
import 'package:ess/Ess_App/src/views/dashboard/widget/Stats_card.dart';
import 'package:ess/Ess_App/src/views/notification/notification.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Ess_App/src/shared/loading_indicator.dart';
import 'package:ess/Ess_App/src/shared/spacing.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';
import '../../models/api_response_models/My_smart_goals.dart';
import '../Dependents/dependent_view.dart';
import '../local_db.dart';
import '../menu/menu_view.dart';
import '../your_attandence/widget/attendence_data_table.dart';
import 'dashboard_view_model.dart';

class DashboardView extends StatefulWidget {
  DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  String status = "";
  DatabaseHelper db = DatabaseHelper();
  final ScrollController scrollController = ScrollController();
  late AnimationController _applyVisitController;
  late Animation<double> _scaleAnimation;
  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;
  late Animation<double> _swipeOpacityAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Swipe tracking variables
  double _swipeStartX = 0.0;
  double _swipeCurrentX = 0.0;
  bool _isSwipeActive = false;
  double _swipeThreshold = 50.0; // Minimum distance for swipe

// >>> SWIPE STATE RESET METHOD START >>>
  void _resetSwipeState() {
    setState(() {
      _swipeStartX = 0.0;
      _swipeCurrentX = 0.0;
      _isSwipeActive = false;
    });
    _swipeController.reverse();
  }
// <<< SWIPE STATE RESET METHOD END <<<

  Widget _buildFloatingActionButton(DashboardViewModel model) {
    // Check if button should be visible from Firebase
    if (!model.isButtonVisible) {
      return SizedBox.shrink(); // Hide button
    }

    return Stack(
      children: [
        FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DependentView()));
            print('FAB pressed with text: ${model.buttonText}');
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: Icon(Icons.group, size: 20),
          label: Text(
            model.buttonText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 8,
          hoverElevation: 16,
          highlightElevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Close button (×) on top right
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              // Hide the FAB when close button is tapped
              setState(() {
                model.isButtonVisible = false;
              });
              // If you want to persist this state, you might want to update it in your ViewModel
              // model.hideButton();
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '×',
                  style: TextStyle(
                    color: Colors.amber[100],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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

    _applyVisitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(
      parent: _applyVisitController,
      curve: Curves.easeInOut,
    ));

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _swipeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));

    _swipeOpacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000), // Faster pulse
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      // Wider range
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset swipe state when coming back from other screens
    _resetSwipeState();
  }

  @override
  void dispose() {
    _applyVisitController.dispose();
    _swipeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
      builder: (viewModelContext, model, child) => model.isBusy
          ? Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LoadingIndicator(),
                ),
              ),
            )
          : Scaffold(
              drawer: MenuView(),
              floatingActionButton: _buildFloatingActionButton(model),
              body: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    CustomHeader(
                      title: model.currentUser?.userName ??
                          model.currentUser?.email ??
                          "null",
                      onMenuTap: () async {
                        Scaffold.of(context).openDrawer();
                      },
                      onNotificationTap: () async {
                        NavService.notification();
                      },
                    ),

                    if (model.dataMap.isNotEmpty) VerticalSpacing(30),
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
                                  model.dashboard?.annualLeaves.toString() ??
                                      "0",
                                  Assets.imagesAnnual,
                                ),
                                SizedBox(width: 10),
                                leavesCart(
                                  context,
                                  "Casual Leaves",
                                  model.dashboard?.casualLeaves.toString() ??
                                      "0",
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
                    if (model.stats_status == "yes")
                      StatsSection(
                        stats_resposne: model.response,
                      ),

                    // Check-in Time (Last 7 Days)
                    _buildCheckInTime(model.all),

                    // Container(
                    //   height: 300,
                    //   child: HomePage(
                    //     data: model.check,
                    //     end: parseMaxCheckInTime(model.maxCheckInFormatted),
                    //   ),
                    // ),

// >>> APPLY VISIT BUTTON - IMAGE AND BUTTON IN ONE LINE >>>
// >>> APPLY VISIT BUTTON - IMAGE INSIDE BUTTON (ANIMATIONS PRESERVED) >>>
                    Material(
                      color: Colors.transparent,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: GestureDetector(
                          onPanStart: (details) {
                            setState(() {
                              _swipeStartX = details.localPosition.dx;
                              _swipeCurrentX = details.localPosition.dx;
                              _isSwipeActive = true;
                            });
                          },
                          onPanUpdate: (details) {
                            if (_isSwipeActive) {
                              setState(() {
                                _swipeCurrentX = details.localPosition.dx;
                              });

                              double swipeDistance =
                                  _swipeCurrentX - _swipeStartX;
                              double progress =
                                  (swipeDistance / _swipeThreshold)
                                      .clamp(0.0, 1.0);

                              if (swipeDistance > 0) {
                                _swipeController.value = progress;
                              }
                            }
                          },
                          onPanEnd: (details) {
                            if (_isSwipeActive) {
                              double swipeDistance =
                                  _swipeCurrentX - _swipeStartX;

                              final requiredSwipeDistance = 250.0;

                              if (swipeDistance >= requiredSwipeDistance) {
                                _swipeController.forward().then((_) {
                                  HapticFeedback.mediumImpact();
                                  _resetSwipeState();
                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    NavService.applyVisit();
                                  });
                                });
                              } else {
                                _resetSwipeState();
                              }
                            }
                          },
                          onPanCancel: () {
                            if (_isSwipeActive) {
                              _resetSwipeState();
                            }
                          },
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4 + (sin(_pulseAnimation.value * pi * 2) * 0.2 + 0.2)), // Smooth sine wave
                                      blurRadius: 20 + (sin(_pulseAnimation.value * pi * 2) * 5 + 5), // Smooth breathing
                                      spreadRadius: (sin(_pulseAnimation.value * pi * 2) * 1.5 + 1.5), // Smooth expansion
                                      offset: Offset(0, 8 + (sin(_pulseAnimation.value * pi * 2) * 2 + 2)),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Swipe progress
                                    if (_isSwipeActive)
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 100),
                                        width: (_swipeCurrentX - _swipeStartX).clamp(0.0, double.infinity),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),

                                    // Button content
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          // Your existing image WITHOUT GLOW EFFECTS
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.asset(
                                                "assets/images/r.png",
                                                height: 50,
                                                width: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          SizedBox(width: 16),

                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    AnimatedBuilder(
                                                      animation: _pulseAnimation,
                                                      builder: (context, child) {
                                                        return Text(
                                                          "APPLY VISIT",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                            shadows: [
                                                              Shadow(
                                                                color: Colors.white.withOpacity(0.5 * _pulseAnimation.value),
                                                                blurRadius: 15,
                                                                offset: Offset(0, 0),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    Text(
                                                      "Swipe fully to apply →",
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.8),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                AnimatedBuilder(
                                                  animation: _pulseAnimation,
                                                  builder: (context, child) {
                                                    // Use sine wave for smooth continuous pulse without reset feeling
                                                    double pulseValue = (sin(_pulseAnimation.value * pi * 2 - pi / 2) + 1) / 2;
                                                    return Container(
                                                      padding: EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2 + (_pulseAnimation.value * 0.2)),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(
                                                          color: Colors.white.withOpacity(0.4 + (_pulseAnimation.value * 0.3)),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.arrow_forward_rounded,
                                                        color: Colors.white,
                                                        size: 24 + (_pulseAnimation.value * 2),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
// <<< APPLY VISIT BUTTON - IMAGE INSIDE BUTTON END <<<,
// <<< APPLY VISIT BUTTON - IMAGE AND BUTTON IN ONE LINE END <<<,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
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
                    if (model.Goal != null) SingleBox(data: model.Goal),
                    VerticalSpacing(25),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19),
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
                    SizedBox(height: 15),
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
                              child: data != ''
                                  ? Container(
                                      alignment: Alignment.center,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: model.selectedIndex == index
                                            ? AppColors.primary
                                            : null,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          data,
                                          style: TextStyle(
                                            color: model.selectedIndex == index
                                                ? AppColors.white
                                                : Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Container());
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

                            String checkIn = (datalist.checkIn is List)
                                ? datalist.checkIn[0]
                                : datalist.checkIn;
                            String checkOut = (datalist.checkOut is List)
                                ? datalist.checkOut[0]
                                : datalist.checkOut;
                            int hoursDifference = model.calculateHourDifference(
                                checkIn, checkOut);
                            if (hoursDifference < 0) {
                              hoursDifference = 0;
                            }

                            return Slidable(
                                enabled:
                                    (datalist.statusColor == Colors.orange &&
                                        datalist.day != "Sun"),
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blue.withOpacity(0.1),
                                  ),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Padding(
                                    padding: EdgeInsets.all(0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height:
                                              datalist.Attendstatus != "Absent"
                                                  ? 62
                                                  : 74,
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      datalist.date,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Work hours: ",
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ),
                                                        Text(
                                                          hoursDifference
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_downward,
                                                      size: 14,
                                                      color: AppColors.primary,
                                                    ),
                                                    Text(
                                                      "${datalist.checkIn}",
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    ),
                                                    HorizontalSpacing(7),
                                                    Icon(Icons.arrow_upward,
                                                        size: 14,
                                                        color:
                                                            AppColors.primary),
                                                    Text(
                                                      "${datalist.checkOut}",
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    ),
                                                    Spacer(),
                                                    if (datalist.Attendstatus ==
                                                            "Absent" &&
                                                        datalist.day != "Sun")
                                                      Lottie.asset(
                                                        Assets.imagesSwapLottie,
                                                        height: 28,
                                                        width: 30,
                                                      ),
                                                    Row(
                                                      children: [
                                                        if (datalist.day !=
                                                            "Sun")
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: datalist
                                                                  .statusColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Text(
                                                              datalist.Attendstatus
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 10),
                                                            ),
                                                          ),
                                                        if (datalist.day == "Sun")
                                                          Container(
                                                            padding: const EdgeInsets.all(3.0),
                                                            decoration: BoxDecoration(
                                                              color: AppColors.primary,
                                                              borderRadius:BorderRadius.circular(4),
                                                            ),
                                                            child: Text(
                                                              "Weekend",
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: 10
                                                              ),
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
                          style: TextStyling.bold18
                              .copyWith(color: AppColors.darkGrey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      viewModelBuilder: () => DashboardViewModel(),
      onViewModelReady: (model) => model.init(context),
    );
  }
}

Widget leavesCart(
    BuildContext context, String title, String count, String icon) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        width: screenWidth * 0.28, // adjust as per design
        //height: screenHeight * 0.16, // relative height
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
                  colors: [AppColors.primary, AppColors.secondary],
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
                          child: Image.asset(
                            "assets/images/goal.png",
                            height: 40,
                            width: 40,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
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
        }),
      ),
    );
  }
}

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;

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
        Container(
          width: double.infinity, // This ensures it takes full width
          height: 220,
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
                blurRadius: 13,
                offset: Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: onMenuTap,
                    child: Icon(Icons.menu, color: Colors.white),
                  ),
                  Text(
                    "Dashboard",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ValueListenableBuilder<int?>(
                    valueListenable: NotiCount.count,
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: onNotificationTap,
                        child: badges.Badge(
                          showBadge: NotiCount.count.value! > 0,
                          badgeContent: Text(
                            NotiCount.count.value.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.red,
                            padding: EdgeInsets.all(6),
                          ),
                          child: Icon(Icons.notifications, color: Colors.white),
                        ),
                      );
                    },
                  )
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Hello,\n$title",
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
  return Padding(
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
              var datalist = data[index];
              return Container(
                width: 120,
                padding: EdgeInsets.all(8),
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
                        datalist.checkIn != "12:00 AM"
                            ? '${datalist.checkIn}'
                            : "OFF",
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
        padding: EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: attendanceData.map((item) {
              return Container(
                width: 120,
                margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item['status'] == "Present"
                      ? Colors.green[200]
                      : Colors.red[200],
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
                      item['status'] == "Present"
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: item['status'] == "Present"
                          ? Colors.green
                          : Colors.red,
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
