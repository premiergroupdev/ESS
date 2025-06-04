import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ess/360_survey_App/Screens/Login/Login_screen_view.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Learning_management_system/Screens/Lms_Dashboard/Lms_dashboard_view.dart';
import 'package:ess/Learning_management_system/Utilis/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:slide_digital_clock/slide_digital_clock.dart';
import '360_survey_App/Api_services/data/Local_services/Session.dart';
import '360_survey_App/Screens/Dashboard/Dashboard_view.dart';
import 'Ess_App/src/configs/app_setup.locator.dart';
import 'Ess_App/src/services/local/auth_service.dart';
import 'Ess_App/src/services/remote/api_service.dart';
import 'Ess_App/src/styles/text_theme.dart';
import 'package:http/http.dart' as http;
import 'Ess_App/src/models/api_response_models/user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Ess_App/src/views/dashboard/dashboard_view.dart';
import 'Ess_App/src/views/local_db.dart';
import 'Ess_App/src/views/login/login_view.dart';
import 'Timer.dart';


class AppMenu extends StatefulWidget {
  AppMenu({Key? key}) : super(key: key);

  @override
  State<AppMenu> createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> {
  AuthService? authService;
  AuthService _authService = locator<AuthService>();
  User? get currentUser => _authService.user;
  DateTime? lastApiCallTime;
  DatabaseHelper database = DatabaseHelper();
  ApiService api = ApiService();
  DateTime? lastLocationUpdateTime;
  String? userid;
  final currentTimes = DateTime.now();
  String currentTime = DateTime.now().toIso8601String().substring(11, 16);
  List data = [];
  bool isloading = false;
  bool isDialogShown = false;
  bool? isDialogShownPref;
  String version='';

  Future<List> Api() async {
    var response = await http.get(Uri.parse("https://premierspulse.com/ess/scripts/dashboard_script.php"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['Forms'] as List<dynamic>;
    }
    return [];
  }

  Future<void> fetchdata() async {
    setState(() {
      isloading = true;
    });
    data = await Api();
    setState(() {
      isloading = false;
    });
  }

  Future<void> Dialogbox(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDialogShownPref = prefs.getBool('isDialogShown');

    if (isDialogShownPref == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(
                'Background Location Permission',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: Text(
              'We use your background location to mark your check-in when you arrive at the premises. '
                  'Your data is secure and used solely for this purpose.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await prefs.setBool('isDialogShown', true);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdata();
    version_no();
  }
  void version_no() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version.split('-').first.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: Colors.blue.shade50,
      drawerEnableOpenDragGesture: false,
      body: isloading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
            children: [
              Container(
                height: 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 2,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset("assets/images/loho.png", height: 130, width: 130),
                    ),



                    Container(
                        height: 100,
                        child: TimerScreen()),
                    Text(
                      "All Apps",
                    style: GoogleFonts.poppins(
                      color: AppColors.white,

                      fontSize: 18,
                    ),
                    ),
                  ],
                ),
              ),

              Column(

                    children: [
            // 🔷 Top Header (was previously in Positioned)

            // SizedBox(height: 20,),
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(12),
            //   child: Image.asset("assets/images/loho.png", height: 130, width: 130),
            // ),
            SizedBox(height: 270,),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Text("All Apps", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 22),),
            //   ],
            // ),
            // 🔷 GridView in Expanded (below header)
            Expanded(
              child: GridView.builder(
                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                padding: const EdgeInsets.all(16),
                physics: NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  var datalist = data[index];
                  return GestureDetector(
                    onTap: () async {
                      // Your onTap logic
                      if (datalist['menu_name'] == "ESS") {
                        FirebaseFirestore firestore = FirebaseFirestore.instance;
                        PackageInfo packageInfo = await PackageInfo.fromPlatform();
                        DocumentSnapshot doc = await firestore.collection('version_controlling').doc('G27Xr3d0efCHgf2QUSYW').get();
                        String version = packageInfo.version.split('-').first.trim();
                        String firebaseversion = Platform.isAndroid ? doc['andriod'] : doc['ios'];

                        if (version == firebaseversion) {
                          if (currentUser?.userName == null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginView()));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardView()));
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              title: Text(
                                "Update Application",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              content: Text(
                                "Latest Version is available at Store\nNew App Version: ($firebaseversion)",
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Update Now", style: TextStyle(color: Colors.white)),
                                  onPressed: () async {
                                    String url ='';
                                    if(Platform.isAndroid) {
                                       url = "https://play.google.com/store/apps/details?id=com.premiergroup.ess";
                                    }
                                    else {
                                       url = "https://apps.apple.com/app/id6746352124";
                                    }
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                    } else {
                                      print("Could not launch $url");
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      }

                      if (datalist['menu_name'] == "360 Feedback") {
                        if (UserData.username == null) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Login_servey_app()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
                        }
                      }

                      if (datalist['menu_name'] == "LMS") {
                        Sharedprefrence sp = Sharedprefrence();
                        await sp.getlmsdata();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => lms_Dashboard()));
                      }

                      if (datalist['menu_name'] == "CHATBOT") {
                        final url = 'https://wa.me/03348788282?text=Hi';
                        await launch(url);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(datalist['menu_logo'], height: 110, width: 110),
                            SizedBox(height: 8),
                            SizedBox(height: 8),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text("Version: ${version}",style: GoogleFonts.poppins(
                          color: AppColors.primary,

                          fontSize: 14,
                        ),),
                      )

                    ],
                  ),


            ]
          ),
    );
  }
}
