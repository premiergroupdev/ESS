import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:ess/Ess_App/src/base/utils/constants.dart';
import 'package:ess/Ess_App/src/models/api_response_models/Stats_model.dart';
import 'package:ess/Ess_App/src/models/api_response_models/dashboard.dart';
import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:ess/Ess_App/src/services/remote/notification/local_notification.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/views/dashboard/widget/br.dart';
import 'package:ess/Ess_App/src/views/login/login_view_model.dart';
import 'package:ess/Ess_App/src/views/your_attandence/widget/attendence_data_table.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import '../../configs/app_setup.locator.dart';
import '../../models/api_response_models/My_smart_goals.dart';
import '../../models/api_response_models/Notification.dart';
import '../../models/api_response_models/attendence.dart';
import '../../services/local/auth_service.dart';
import '../../services/local/navigation_service.dart';
import '../local_db.dart';
import '../login/local/local_db.dart';

class Dependent {
  final String type;
  final String name;
  final String dob;
  final String packageType;

  Dependent({
    required this.type,
    required this.name,
    required this.dob,
    required this.packageType,
  });

  factory Dependent.fromJson(Map<String, dynamic> json) {
    print('📝 Parsing dependent JSON: $json');

    return Dependent(
      // Use the actual field names from API response
      type: json['dep_type']?.toString() ?? '',
      name: json['dep_name']?.toString() ?? '',
      dob: json['dep_dob']?.toString() ?? '',
      packageType: json['package_type']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Dependent{type: $type, name: $name, dob: $dob, packageType: $packageType}';
  }
}


class DashboardViewModel extends ReactiveViewModel with AuthViewModel, ApiViewModel {
  LoginViewModel login = LoginViewModel();
  Dashboard? dashboard;

  // ADD THESE PROPERTIES FOR FAB CONTROL
  bool isButtonVisible = false;
  String buttonText = "Default Text";

  DatabaseHelpe databaseHelper = DatabaseHelpe();
  String currentTime = DateTime.now().toIso8601String().substring(11, 16);
  String today = DateTime.now().toIso8601String().split('T')[0];
  DatabaseHelper database = DatabaseHelper();
  AttendenceTableData heading = AttendenceTableData(
    date: 'Date',
    checkIn: 'Check In',
    checkOut: 'Check Out',
    Attendstatus: 'attend_status',
    formetedDate: DateTime.now(),
  );

  List<AttendenceTableData> all = [];
  List<BarChartModel> check = [];
  List<goal> Goal = [];
  List<AttendenceTableData> alldata = [];
  List<AttendenceTableData> onTimeList = [];
  List<AttendenceTableData> lateList = [];
  List<AttendenceTableData> weekendList = [];
  List<AttendenceTableData> halfDayList = [];
  List<AttendenceTableData> AbsentList = [];
  List<Forms> storeAttendanceData = [];
  StatsModel? statsdata;
  String selectedTitle = "";
  DateTime? maxCheckInTime;
  DateTime? formattedMaxCheckInTime;
  String? maxCheckInFormatted;
  bool? isBirthdayShown;
  Map<String, dynamic> stats_data = {};
  String stats_status = '';
  Map<String, dynamic> response = {};
  StreamSubscription? _buttonSettingsSubscription;

  // ADD DEPENDENT PROPERTIES HERE INSIDE THE CLASS
  List<Dependent> dependents = [];
  bool loadingDependents = false;

  Map<String, double> dataMap = {
    "On Time": 0.0,
    "Late": 0.0,
  };
  String? tokens;

  void token() async {
    tokens = await FirebaseMessaging.instance.getToken();
    notifyListeners();
  }

  // ADD THIS METHOD FOR FAB SETTINGS
  Future<void> fetchButtonSettings() async {
    try {
      _buttonSettingsSubscription = FirebaseFirestore.instance
          .collection('app_settings')
          .doc('button_controls')
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          isButtonVisible = data['button_visible'] ?? false;
          buttonText = data['button_text'] ?? 'Default Text';
          notifyListeners();
          print('✅ FAB Settings updated - Visible: $isButtonVisible, Text: $buttonText');
        }
      });
    } catch (e) {
      print('❌ Error setting up button settings listener: $e');
    }
  }

  // Don't forget to cancel in dispose
  @override
  void dispose() {
    _buttonSettingsSubscription?.cancel();
    super.dispose();
  }

  double targetLatitude = 0.0;
  double targetLongitude = 0.0;
  double targetDistance = 0.0;
  AuthService _authService = locator<AuthService>();
  int selectedIndex = 0;
  List<String> statuses = [];
  List<AttendenceTableData> filteredData = [];

  // ADD DEPENDENT METHOD INSIDE THE CLASS
  Future<void> fetchDependents() async {
    try {
      loadingDependents = true;
      notifyListeners();

      String empCode = '';

      // Method 1: Use the actual logged-in user's userId
      if (authService.user?.userId != null) {
        empCode = authService.user!.userId!.toString();
        print('✅ Using logged-in user ID: $empCode');
      }

      // Method 2: Fallback (shouldn't be needed)
      if (empCode.isEmpty) {
        empCode = "99963052"; // Current user's ID
        print('⚠️ Using fallback: $empCode');
      }

      print('🔄 FETCHING DEPENDENTS for employee: $empCode');

      final response = await http.get(
        Uri.parse('https://premierspulse.com/ess/scripts/fetch_dependent_list.php?emp_code=$empCode'),
      );

      print('📡 API Status Code: ${response.statusCode}');
      print('📦 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        print('✅ API Response received');

        dependents = [];

        if (data is Map && data.containsKey('dependent_list')) {
          List<dynamic> dependentList = data['dependent_list'];
          print('📊 Number of dependents found: ${dependentList.length}');

          for (var item in dependentList) {
            if (item is Map) {
              final Map<String, dynamic> jsonMap = item.map<String, dynamic>((key, value) {
                return MapEntry(key.toString(), value);
              });

              Dependent dependent = Dependent.fromJson(jsonMap);
              dependents.add(dependent);
              print('✅ Added dependent: ${dependent.name}');
            }
          }
        } else {
          print('❌ No dependent_list found in response');
          print('Response structure: $data');
        }

        print('🎉 Successfully loaded ${dependents.length} dependents');

      } else {
        print('❌ Failed to load dependents. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        dependents = [];
      }
    } catch (e) {
      print('💥 Error fetching dependents: $e');
      dependents = [];
    } finally {
      loadingDependents = false;
      notifyListeners();
    }
  }

  // void debugCurrentUser() {
  //   print('=== CURRENT USER DEBUG ===');
  //   print('Current User: $currentUser');
  //   print('Current User Type: ${currentUser?.runtimeType}');
  //   print('Auth Service User: ${authService.user}');
  //   print('Auth Service User Type: ${authService.user?.runtimeType}');
  //
  //   if (currentUser != null) {
  //     print('Current User Properties:');
  //     // Try to access common properties
  //     try {
  //       if ((currentUser as dynamic).empCode != null) {
  //         print('  empCode: ${(currentUser as dynamic).empCode}');
  //       }
  //       if ((currentUser as dynamic).employeeCode != null) {
  //         print('  employeeCode: ${(currentUser as dynamic).employeeCode}');
  //       }
  //       if ((currentUser as dynamic).code != null) {
  //         print('  code: ${(currentUser as dynamic).code}');
  //       }
  //       if ((currentUser as dynamic).empId != null) {
  //         print('  empId: ${(currentUser as dynamic).empId}');
  //       }
  //     } catch (e) {
  //       print('Error accessing properties: $e');
  //     }
  //   }
  //   print('==========================');
  // }
  // Add this method to manually test the dependents API
  // void testDependentsAPI() async {
  //   print('🧪 TESTING DEPENDENTS API...');
  //   await fetchDependents();
  // }

  Future<void> locations(double Latitude, double Longitude, double distatnce) async {
    if (currentUser != null) {
      Latitude = double.parse(currentUser!.att_lon.toString());
      Longitude = double.parse(currentUser!.att_lat.toString());
      distatnce = double.parse(currentUser!.radius.toString());
      notifyListeners();
    }

    print("latitude: ${targetLatitude}");
    print("Longitude: ${targetLongitude}");
    print("targetDistance: ${targetDistance}");
  }

  Future<void> Fetch_stats(BuildContext context) async {
    try {
      response = await runBusyFuture(apiService.fetchStats());

      print("Stats: ${response}");
      stats_status = response["statSection"];
      if (response["statSection"] == "yes") {
        statsdata = StatsModel.fromJson(response);

        print("Travel Count: ${statsdata?.travelCount}");
      } else {
        print("statSection is not yes");
      }
    } catch (e, stacktrace) {
      print("Error in Fetch_stats: $e");
      print("StackTrace: $stacktrace");
    }
  }

  void showBirthdayDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.pink[50],
          child: Container(
            padding: EdgeInsets.all(20),
            width: 300,
            height: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/images/cake.png"),
                SizedBox(height: 20),
                Text(
                  ' Happy Birthday',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[800],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  ' ${authService.user!.userName} 🎉 🎂',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[800],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20),
                Text(
                  'May your day be filled with love, joy, and happiness!',
                  style: TextStyle(fontSize: 16, color: Colors.pink[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // Button color
                    foregroundColor: Colors.white,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Let\'s Celebrate!'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  init(BuildContext context) async {
    WidgetsFlutterBinding.ensureInitialized();
    setBusy(true);
    token();

    // ADD THIS LINE - Fetch FAB settings from Firebase
    await fetchButtonSettings();


    //pushNotificationInstant();
    login.subscribeToken(context);
    await _checkVersion(context);
    await getDashboardData(context);
    await getgoal(context);
    await getAttendanceData(context, 'All');

    // ADD DEPENDENTS FETCH HERE
    /*await fetchDependents();*/

    SharedPreferences prefs = await SharedPreferences.getInstance();
    double lat = prefs.getDouble('lat') ?? 0.0;

    for (int i = 0; i < check.length; i++) {
      if (maxCheckInTime == null || check[i].checkInTime.isAfter(maxCheckInTime!)) {
        maxCheckInTime = check[i].checkInTime;
      }
    }
    if (maxCheckInTime != null) {
      maxCheckInFormatted = DateFormat('HH:mm').format(maxCheckInTime!);
    }

    dataMap = {
      "On Time": double.parse(dashboard?.totalOntime.toString() ?? "0"),
      "Late": double.parse(dashboard?.totalLates.toString() ?? "0"),
    };

    setBusy(false);

    //debugCurrentUser(); // Add this

    checkbirthday(context);
    filteredData = alldata;
    statuses = alldata.map((e) => e.Attendstatus!).toSet().toList();

    statuses.insert(0, "All");
    statuses.insert(statuses.length, "Weekend");
    print("Statuss ${statuses}");
    // await _requestNotificationPermission(context);
    await Fetch_stats(context);
  }

  int calculateHourDifference(String checkInTime, String checkOutTime) {
    try {
      DateFormat format = DateFormat("h:mm a");
      DateTime timeIn = format.parse(checkInTime);
      DateTime timeOut = format.parse(checkOutTime);
      Duration difference = timeOut.difference(timeIn);
      return difference.inHours;
    } catch (e) {
      print("Error parsing time: $e");
      return 0;
    }
  }

  void filterDataByStatus(String status) {
    if (status == "All") {
      filteredData = alldata;
    } else if (status == "Absent") {
      filteredData = alldata.where((item) => item.Attendstatus == status && item.day != "Sun").toList();
    } else if (status == "Weekend") {
      filteredData = alldata.where((e) => e.day == "Sun").toList();
    } else {
      filteredData = alldata.where((item) => item.Attendstatus == status).toList();
    }
    notifyListeners();
  }

  void checkbirthday(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    if (authService.user!.dob == formattedDate) {
      showBirthdayDialog(context);
    }
  }

  Future<void> clearCoordinates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('lat');
    await prefs.remove('long');
    await prefs.remove('radius');
    notifyListeners();
    print("Coordinates cleared.");
  }

  Future<void> requestPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print("Location permission granted");
    } else if (status.isDenied) {
      print("Location permission denied");
    } else if (status.isPermanentlyDenied) {
      print("Location permission permanently denied");
      openAppSettings();
    }
  }

  getAttendanceData(BuildContext context, String Status) async {
    alldata.clear();
    all.clear();
    var newsResponse = await runBusyFuture(apiService.attendance(context, "1"));
    newsResponse.when(success: (dataNew) async {
      if ((dataNew.forms?.length ?? 0) > 0) {
        dataNew.forms?.forEach((element) {
          var timeInputFormat = DateFormat('hh:mm a');
          var datedInputFormat = DateFormat('EE dd/MM');
          var day = DateFormat('EE');
          var attendstatus = element.attendStatus.toString();
          print("Attendance status: $attendstatus");
          DateTime inTime = DateTime.parse("2020-01-02 ${element.checkIn.toString()}");
          var checkIn = timeInputFormat.format(inTime);
          DateTime outTime = DateTime.parse("2020-01-02 ${element.checkOut.toString()}");
          var checkOut = timeInputFormat.format(outTime);
          var date = datedInputFormat.format(DateTime.parse(element.attendDate.toString()));
          var days = day.format(DateTime.parse(element.attendDate.toString()));
          all.add(AttendenceTableData(
            day: days,
            date: date,
            checkIn: checkIn,
            checkOut: checkOut,
            Attendstatus: attendstatus,
            formetedDate: DateTime.parse(element.attendDate.toString()),
            statusColor: colorSelection(element.attendStatus.toString()),));

          alldata.add(
              AttendenceTableData(
                day: days,
                date: date,
                checkIn: checkIn,
                checkOut: checkOut,
                Attendstatus: attendstatus,
                formetedDate: DateTime.parse(element.attendDate.toString()),
                statusColor: colorSelection(element.attendStatus.toString()),
              )
          );

          if (element.attendStatus == "On Time" || element.attendStatus == "Late") {
            if (check.length < 7) {
              final DateTime checkInTime = DateFormat('HH:mm').parse(checkIn);

              check.add(BarChartModel(day: date, checkInTime: checkInTime, attendstatus: element.attendStatus!));
            }
          }
        });
      } else {
        Constants.customWarningSnack(context, "Attendance not found");
      }
    }, failure: (error) {
      Constants.customErrorSnack(context, error.toString());
    });
  }

  void filterListsByStatus(BuildContext context, String status) {
    setBusy(true);
    alldata.clear();

    if (status.trim() == "All") {
      for (int i = 0; i < all.length; i++) {
        alldata.add(AttendenceTableData(
            date: all[i].date,
            checkIn: all[i].checkIn,
            checkOut: all[i].checkOut,
            Attendstatus: all[i].Attendstatus,
            formetedDate: DateTime.now(),
            statusColor: colorSelection(all[i].Attendstatus.toString(),
            ))
        );
      }
    } else {
      for (int i = 0; i < all.length; i++) {
        if (all[i].Attendstatus == "${status}") {
          alldata.add
            (
              AttendenceTableData(
                  date: all[i].date,
                  day: all[i].day,
                  checkIn: all[i].checkIn,
                  checkOut: all[i].checkOut,
                  Attendstatus: all[i].Attendstatus,
                  formetedDate: DateTime.now(),
                  statusColor: colorSelection(
                    all[i].Attendstatus.toString(),
                  )
              )
          );
        }
      }
      print("${alldata.length}");
    }
    setBusy(false);
  }

  Color colorSelection(String title) {
    switch (title) {
      case "Late":
        {
          return Colors.red;
        }
      case "Half Day":
        {
          return Colors.purple;
        }

      case "Absent":
        {
          return Colors.orange;
        }
      case "On Time":
        {
          return Colors.green;
        }

      case "Weekend":
        {
          return AppColors.primary;
        }

      default:
        {
          return AppColors.primary;
        }
    }
  }

  Future<void> getCoordinates(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var newsResponse = await runBusyFuture(apiService.getcordinantes());

    newsResponse.when(success: (data) async {
      if (data != null) {
        double lat = prefs.getDouble('lat') ?? 0.0;
        double long = prefs.getDouble('long') ?? 0.0;
        double radius = prefs.getDouble('radius') ?? 0.0;
        String userId = prefs.getString('userid') ?? '';

        double? attLat;
        if (data['att_lat'] is String) {
          attLat = double.tryParse(data['att_lat']);
        } else if (data['att_lat'] is num) {
          attLat = data['att_lat'].toDouble();
        }

        double? attLon;
        if (data['att_lon'] is String) {
          attLon = double.tryParse(data['att_lon']);
        } else if (data['att_lon'] is num) {
          attLon = data['att_lon'].toDouble();
        }

        double? attradius;
        if (data['radius'] is String) {
          attradius = double.tryParse(data['radius']);
        } else if (data['radius'] is num) {
          attradius = data['radius'].toDouble();
        }

        bool isLatEqual = lat == attLat;
        bool isLonEqual = long == attLon;
        bool isRadiusEqual = radius == attradius;
        //bool checkin = await FlutterBackgroundService().isServiceRunning();
        // if (isLatEqual && isLonEqual && isRadiusEqual && checkin ) {
        //   print("All values are equal.");
        // } else
        //
        // {
        //  // FlutterBackgroundService().sendData({"action": "stopService"});
        //   SharedPreferences sp = await SharedPreferences.getInstance();
        //   //await sp.clear();
        //   Scaffold.of(context).closeDrawer();
        //   authService.user = null;
        //   Navigator.pop(context);
        //   authService.logout();
        //   print(authService.user);
        //   String message = "Kindly restart your App. ";
        //   NavService.appmenu();
        //   Constants.customSuccessSnack(context, "Please restart your app. your location has been changed ");
        //   print("Values are not equal:");
        //   if (!isLatEqual) print("Latitude does not match.");
        //   if (!isLonEqual) print("Longitude does not match.");
        //   if (!isRadiusEqual) print("Radius does not match.");
        //
        // }
      }

      print("data: ${data}");
    }, failure: (error) {
      Constants.customErrorSnack(context, error.toString());
    });
  }

  getDashboardData(BuildContext context) async {
    var newsResponse = await runBusyFuture(apiService.dashboard(context));
    newsResponse.when(success: (data) async {
      if (data.email != null) {
        dashboard = data;
      } else {
        Constants.customWarningSnack(context, data.loginMsg.toString());
      }
    }, failure: (error) {
      Constants.customErrorSnack(context, error.toString());
    });
  }

  getgoal(BuildContext context,) async {
    var newsResponse = await runBusyFuture(apiService.mygoal(context));
    newsResponse.when(success: (data) async {
      Goal = data.approvalListvisit.toList();
    }, failure: (error) {
      Constants.customErrorSnack(context, error.toString());
    });
  }

  Future<void> _checkVersion(BuildContext context) async {
    try {
      var status = await InAppUpdate.checkForUpdate();
      if (status.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      } else {

      }
    } catch (e) {
      print(e);
    }
  }

  void pushNotificationInstant() async {
    FirebaseMessaging.instance.getInitialMessage().then(
          (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        print("New Notification Navigator");
      },
    );
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      String? type = initialMessage.data['type'];
      if (type == "final_advance") {
        NavService.Final_advance();
      } else if (type == "attendence") {
        NavService.yourAttendance();
      }
    }
    // Future<void> backgroundMessageHandler(RemoteMessage message) async {
    //   try {
    //     print("Handling a background message: ${message.messageId}");
    //
    //     if (message.notification != null) {
    //       print('Notification Title: ${message.notification!.title}');
    //       print('Notification Body: ${message.notification!.body}');
    //
    //       Notification_model notification = Notification_model(
    //         title: message.notification!.title,
    //         body: message.notification!.body,
    //         timestamp: message.sentTime ?? DateTime.now(), // Use sentTime or current time
    //       );
    //
    //       // Access your database helper instance
    //       await databaseHelper.insertnotification(notification);
    //     }
    //
    //     print('Payload data: ${message.data}');
    //   } catch (e) {
    //     print('Error handling background message: $e');
    //     // Handle the exception as needed, such as logging it or reporting it.
    //   }
    // }
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          LocalNotificationService.createAndDisplayNotification(message);
          Notification_model notification = Notification_model(
            title: message.notification!.title,
            body: message.notification!.body,
            timestamp: message.sentTime ?? DateTime.now(), // Use sentTime or current time
          );

          await databaseHelper.insertnotification(notification);
          if (message.data.containsKey('type')) {
            String? type = message.data['type'];
            if (type == "final_advance") {
              NavService.Final_advance();
            } else if (type == "attendence") {
              NavService.yourAttendance();
            } else {
              print("Unknown notification type: $type");
            }
          } else {
            print("No type key in notification data");
          }
        }
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) async {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data");
          Notification_model notification = Notification_model(
            title: message.notification!.title,
            body: message.notification!.body,
            timestamp: message.sentTime ?? DateTime.now(), // Use sentTime or current time
          );

          // Access your database helper instance
          await databaseHelper.insertnotification(notification);
          if (message.data.containsKey('type')) {
            String? type = message.data['type'];

            if (type == "final_advance") {
              NavService.Final_advance();
            } else if (type == "attendence") {
              NavService.yourAttendance();
            } else {
              print("Unknown notification type: $type");
            }
          } else {
            print("No type key in notification data");
          }
        }
      },
    );
  }

  Future<void> _requestNotificationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      bool userAccepted = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enable Notifications'),
            content: Text(
                'To stay updated with the latest information, please enable notifications in the app settings.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('Open Settings'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (userAccepted) {
        await openAppSettings();
      }
    }
  }

  void getLocation(double attLat, double attLon, double distancce) {
    if (currentUser != null) {
      attLat = double.tryParse(currentUser!.att_lat.toString()) ?? 0.0;
      attLon = double.tryParse(currentUser!.att_lon.toString()) ?? 0.0;
      distancce = double.tryParse(currentUser!.radius.toString()) ?? 0.0;
      print("Longitude: $attLon");
      print("Latitude: $attLat");
      print("Distance: $distancce");
      notifyListeners();
    } else {
      print("Current User is null");
    }
  }

  updatenumber(BuildContext context, String number) async {
    try {
      var newsResponse = await runBusyFuture(apiService.changephonenumber(context, number));

      newsResponse.when(
        success: (data) {
          Constants.customSuccessSnack(context, data ?? 'Number Updated Successfully');
        },
        failure: (error) {
          // If there's a failure, show the error message
          Constants.customErrorSnack(context, error?.toString() ?? 'An error occurred');
        },
      );
    } catch (error) {
      Constants.customErrorSnack(context, error.toString());
    }
  }
}