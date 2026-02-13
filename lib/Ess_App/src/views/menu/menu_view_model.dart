import 'package:ess/Ess_App/src/services/local/base/auth_view_model.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Ess_App/src/services/remote/base/api_view_model.dart';
import 'package:ess/Ess_App/src/views/Resignation_form/Hr_one_view.dart';
import 'package:ess/Ess_App/src/views/Resignation_form/Hr_two_view.dart';
import 'package:ess/Ess_App/src/views/Resignation_form/fnf_submission_view.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:stacked/stacked.dart';
import '../Advance/Advance_list_view.dart';
import '../Dependents/dependent_view.dart';
import '../Education Aid/Department_head_approval.dart';
import '../Education Aid/Final_approval.dart';
import '../Education Aid/Hr_approval.dart';
import '../Education Aid/Payment_issuance.dart';
import '../Education Aid/Personal Details/Perosnal_details_view.dart';
import '../Education Aid/Request_Education/Request_Eduction_view.dart';
import '../Education Aid/hod_approval.dart';
import '../PDMS_survey/survey_form_view.dart';
import '../PDMS_survey/survey_list_view.dart';
import '../Resignation_form/Account_Approval_view.dart';
import '../Resignation_form/All_Resignation_view.dart';
import '../Resignation_form/Hod_approval_view.dart';
import '../Resignation_form/IT_approval_view.dart';
import '../Resignation_form/Line_managers_Approval_view.dart';
import '../Traval_expense/My_expense_view.dart';
import '../dashboard/dashboard_view.dart';
import '../login/local/local_db.dart';
import '../your_attandence/your_attandence_view.dart';

class CustomMenuItem {
  final String label;
  final GestureTapCallback onPress;
  final bool isParent;
  final List<CustomMenuItem>? children;

  CustomMenuItem({
    required this.label,
    required this.onPress,
    required this.isParent,
    this.children,
  });
}

class MenuViewModel extends ReactiveViewModel with ApiViewModel, AuthViewModel {
  final BuildContext context;

  MenuViewModel(this.context);
  int collapsedIndex = -1;
  bool? checktabledata;
  String version='';
  final dbHelper = DatabaseHelpe();

  Future<void> checktable() async {
    checktabledata = await  dbHelper.checkTable();
    print("table data: ${checktabledata}");
    notifyListeners();
  }
  void init(BuildContext context){
    checktable();
    version_no();
    debugCurrentUser();
  }

  void debugCurrentUser() {
    print('=== MENU VIEW MODEL USER DEBUG ===');
    if (authService.user != null) {
      print('User Object: ${authService.user}');
      print('User Type: ${authService.user.runtimeType}');
      print('User Name: ${authService.user?.userName}');
      print('User ID: ${authService.user?.userId}');
      print('AdvFinApp: ${authService.user?.AdvFinApp}');
      print('is_qms: ${authService.user?.is_qms}');
      print('is_pdms: ${authService.user?.is_pdms}'); // Added this
      print('memberAccess: ${authService.user?.memberAccess}');

      // Try to see all properties using toJson() if available
      try {
        var userJson = (authService.user as dynamic).toJson();
        print('User JSON properties:');
        userJson.forEach((key, value) {
          print('  $key: $value');
        });
      } catch (e) {
        print('Cannot convert user to JSON: $e');
      }
    } else {
      print('User is null in authService');
    }
    print('==================================');
  }

  changeIndex(int index) {
    if (collapsedIndex == index) {
      collapsedIndex = -1;
    } else {
      collapsedIndex = index;
    }
    notifyListeners();
  }

  onLogout() async {
    // FlutterBackgroundService().sendData({"action": "stopService"});
    Scaffold.of(context).closeDrawer();
    authService.user = null;
    authService.logout();
    print(authService.user);
    NavService.appmenu();
  }

  void version_no() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version.split('-').first.trim();
  }

  List<CustomMenuItem> get menuItems => [
    CustomMenuItem(
      label: "Dashboard",
      isParent: true,
      onPress: () {
        changeIndex(-1);
        NavService.dashboard();
        Scaffold.of(context).closeDrawer();
      },
    ),
    CustomMenuItem(
        label: "Attendance",
        isParent: true,
        onPress: () {
          changeIndex(1);
        },
        children: [
          CustomMenuItem(
            label: "Your Attendance",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => YourAttendanceView(check: "1"),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Team Attendance",
            isParent: false,
            onPress: () {
              Scaffold.of(context).closeDrawer();
              NavService.team_attendance();
            },
          ),
        ]),
    CustomMenuItem(
        label: "Leaves / Visits",
        isParent: true,
        onPress: () {
          changeIndex(2);
        },
        children: [
          CustomMenuItem(
            label: "Leaves Form",
            isParent: false,
            onPress: () {
              NavService.applyLeave();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Annual Leave Planner",
            isParent: false,
            onPress: () {
              NavService.annaul_leave();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "My Annual Plan",
            isParent: false,
            onPress: () {
              NavService.annaul_leave_applications();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Annual Plan Approval",
            isParent: false,
            onPress: () {
              NavService.plan_approval();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Pending Leave Approval",
            isParent: false,
            onPress: () {
              NavService.Pendingapproval();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Your Leave Applications",
            isParent: false,
            onPress: () {
              NavService.leaveApplications();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Visit Form",
            isParent: false,
            onPress: () {
              NavService.applyVisit();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Pending Visit Approval",
            isParent: false,
            onPress: () {
              NavService.Pendingvisitapproval();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Your All Visits",
            isParent: false,
            onPress: () {
              NavService.visits();
              Scaffold.of(context).closeDrawer();
            },
          ),
        ]
    ),
    CustomMenuItem(
        label: "Reservation",
        isParent: true,
        onPress: () {
          changeIndex(3);
        },
        children: [
          CustomMenuItem(
            label: "Reserve Board Room",
            isParent: false,
            onPress: () {
              NavService.reserveBoardRoom();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "See All Reservation",
            isParent: false,
            onPress: () {NavService.allReservations();Scaffold.of(context).closeDrawer();},
          ),
        ]
    ),
    CustomMenuItem(
        label: "Advance",
        isParent: true,
        onPress: () {
          changeIndex(4);
        },
        children: [
          if(authService.user?.AdvFinApp == 'yes')
            CustomMenuItem(
              label: "Final Advance Approval",
              isParent: false,
              onPress: () {NavService.Final_advance();Scaffold.of(context).closeDrawer();},
            ),
          CustomMenuItem(
            label: "Request Advance",
            isParent: false,
            onPress: () {NavService.Request_advance();Scaffold.of(context).closeDrawer();},
          ),
          CustomMenuItem(
            label: "Advance List",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Advance_list_view(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Line Manager / HOD Approval",
            isParent: false,
            onPress: () {NavService.line_manager();Scaffold.of(context).closeDrawer();},
          ),
        ]
    ),
    CustomMenuItem(
        label: "Loan",
        isParent: true,
        onPress: () {
          changeIndex(5);
        },
        children: [
          CustomMenuItem(
            label: "Apply Loan",
            isParent: false,
            onPress: () {NavService.loan();Scaffold.of(context).closeDrawer();},
          ),
          CustomMenuItem(
            label: "See All Loan",
            isParent: false,
            onPress: () {
              NavService.allloan();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Pending Guarantees",
            isParent: false,
            onPress: () {NavService.pending_guarantees();Scaffold.of(context).closeDrawer();},
          ),
          CustomMenuItem(
            label: "Pending HOD Approvals",
            isParent: false,
            onPress: () {
              NavService.pending_hod_approval();
              Scaffold.of(context).closeDrawer();
            },
          ),
          if(authService.user?.userId == '99917864' || authService.user?.userId == '99938' || authService.user?.userId == '999850' || authService.user?.userId == '99946879' )
            CustomMenuItem(
              label: "Director Loan Approvals",
              isParent: false,
              onPress: () {
                NavService.director_approval();
                Scaffold.of(context).closeDrawer();
              },
            ),
          if(authService.user?.userId == '99938')
            CustomMenuItem(
              label: "CEO Approvals",
              isParent: false,
              onPress: () {NavService.ceo_approval();Scaffold.of(context).closeDrawer();},
            ),
        ]
    ),
    CustomMenuItem(
        label: "Copex",
        isParent: true,
        onPress: () {
          changeIndex(6);
        },
        children: [
          CustomMenuItem(
            label: "Capex Form",
            isParent: false,
            onPress: () {
              NavService.capexform();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Generate Capex",
            isParent: false,
            onPress: () {
              NavService.Generatecapex();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "HOD Approval",
            isParent: false,
            onPress: () {
              NavService.hod_approval();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Department Head Approval",
            isParent: false,
            onPress: () {
              NavService.head_of_department_approval();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "GM Capex Approval",
            isParent: false,
            onPress: () {
              NavService.gm_capex_approval();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Final Capex Approval",
            isParent: false,
            onPress: () {
              NavService.capex_approval();
              Scaffold.of(context).closeDrawer();
            },
          ),
        ]
    ),

    // QMS Menu - Only shown when is_qms == 1
    if(authService.user?.is_qms == 1)
      CustomMenuItem(
          label: "QMS",
          isParent: true,
          onPress: () {
            changeIndex(7);
          },
          children: [
            CustomMenuItem(
              label: "My Records",
              isParent: false,
              onPress: () {
                NavService.my_records();
                Scaffold.of(context).closeDrawer();
              },
            ),
            CustomMenuItem(
              label: "Create new sheet",
              isParent: false,
              onPress: () {
                NavService.createsheet();
                Scaffold.of(context).closeDrawer();
              },
            ),
            CustomMenuItem(
              label: "Add temperature",
              isParent: false,
              onPress: () {
                NavService.tempurature_list_view();
                Scaffold.of(context).closeDrawer();
              },
            ),
            CustomMenuItem(
              label: "Store Incharge Approval",
              isParent: false,
              onPress: () {
                NavService.view_sheet();
                Scaffold.of(context).closeDrawer();
              },
            ),
            CustomMenuItem(
              label: "Pharmacist Approval",
              isParent: false,
              onPress: () {
                NavService.pharmacist_approval();
                Scaffold.of(context).closeDrawer();
              },
            ),
          ]
      ),

    CustomMenuItem(
        label: "Performance Section",
        isParent: true,
        onPress: () {
          int index = 7; // Base index (after fixed menus)
          if(authService.user?.is_qms == 1) {
            index += 1;
          }
          changeIndex(index);
        },
        children: [
          CustomMenuItem(
            label: "Add Smart Goals",
            isParent: false,
            onPress: () {
              NavService.editsmartgoal();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "My Smart Goals",
            isParent: false,
            onPress: () {
              NavService.smartgoal();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "My Training",
            isParent: false,
            onPress: () {
              NavService.training();
              Scaffold.of(context).closeDrawer();
            },
          ),
        ]
    ),

    CustomMenuItem(
        label: "Whistle Blowing",
        isParent: true,
        onPress: () {
          int index = 8; // Base index (after Performance Section)
          if(authService.user?.is_qms == 1) {
            index += 1;
          }
          changeIndex(index);
        },
        children: [
          CustomMenuItem(
            label: "Blow A Whistle",
            isParent: false,
            onPress: () {
              NavService.whistle();
              Scaffold.of(context).closeDrawer();
            },
          ),
        ]
    ),

    CustomMenuItem(
        label: "Resignation",
        isParent: true,
        onPress: () {
          int index = 9; // Base index (after Whistle Blowing)
          if(authService.user?.is_qms == 1) {
            index += 1;
          }
          changeIndex(index);
        },
        children: [
          CustomMenuItem(
            label: "All Resignations",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllResignationView(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
          if(authService.user?.userId == "99917864" || authService.user?.userId == "99914719"|| authService.user?.userId == "99925048")
            CustomMenuItem(
              label: "Resignation form",
              isParent: false,
              onPress: () {
                NavService.Resignation();
                Scaffold.of(context).closeDrawer();
              },
            ),
          CustomMenuItem(
            label: "FNF Submission",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FnfSubmissionView(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "HOD Approval",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HodApprovalView(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Line Manager Approval",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LineManagersApprovalView(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "HR Level 1",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HrOneView(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "HR Level 2",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HrTwoView(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "IT Approval",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItApprovalView(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Accounts Approval",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountApprovalView(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
        ]
    ),

    if(authService.user?.memberAccess=='yes')
      CustomMenuItem(
          label: "Members",
          isParent: true,
          onPress: () {
            int index = 10; // Base index (after Resignation)
            if(authService.user?.is_qms == 1) {
              index += 1;
            }
            changeIndex(index);
          },
          children: [
            CustomMenuItem(
              label: "Member List",
              isParent: false,
              onPress: () {
                NavService.member();
                Scaffold.of(context).closeDrawer();
              },
            ),
          ]
      ),

    CustomMenuItem(
        label: "Travel Expense",
        isParent: true,
        onPress: () {
          int index = 10; // Base index (after Resignation/Members)
          if(authService.user?.is_qms == 1) {
            index += 1;
          }
          if(authService.user?.memberAccess == 'yes') {
            index += 1;
          }
          changeIndex(index);
        },
        children: [
          CustomMenuItem(
            label: "Expense Approval",
            isParent: false,
            onPress: () {
              NavService.expense_approval();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "My Expense",
            isParent: false,
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TravelListScreen(),
                ),
              );
              Scaffold.of(context).closeDrawer();
            },
          ),
        ]
    ),

    CustomMenuItem(
        label: "Education Aid",
        isParent: true,
        onPress: () {
          int index = 11; // Base index (after Travel Expense)
          if(authService.user?.is_qms == 1) {
            index += 1;
          }
          if(authService.user?.memberAccess == 'yes') {
            index += 1;
          }
          changeIndex(index);
        },
        children: [
          CustomMenuItem(
            label: "Request Education Aid",
            isParent: false,
            onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EducationalAidRequestScreen()));
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "My Educational details",
            isParent: false,
            onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AidDataScreen()));
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "HR Approval",
            isParent: false,
            onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HrAidDataScreen()));
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "HOD Approval",
            isParent: false,
            onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HodAidDataScreen()));
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Department Head Approval",
            isParent: false,
            onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DepartmentHeadAidDataScreen()));
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Final Approval",
            isParent: false,
            onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FinalAidDataScreen()));
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Payment issuance",
            isParent: false,
            onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Payment_issuranceAidDataScreen()));
              Scaffold.of(context).closeDrawer();
            },
          ),
        ]
    ),

    // PDMS SURVEY MENU ITEM - Only shown when is_pdms == 1
    if(authService.user?.is_pdms == 1)
      CustomMenuItem(
          label: "PDMS Survey",
          isParent: true,
          onPress: () {
            int index = 12; // Base index (after Education Aid)
            if(authService.user?.is_qms == 1) {
              index += 1;
            }
            if(authService.user?.memberAccess == 'yes') {
              index += 1;
            }
            changeIndex(index);
          },
          children: [
            CustomMenuItem(
              label: "Survey Form",
              isParent: false,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurveyFormView(),
                  ),
                );
                Scaffold.of(context).closeDrawer();
              },
            ),
            CustomMenuItem(
              label: "Survey List",
              isParent: false,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurveyListScreen(),
                  ),
                );
                Scaffold.of(context).closeDrawer();
              },
            ),
          ]
      ),

    CustomMenuItem(
        label: "Profile",
        isParent: true,
        onPress: () {
          int index = 12; // Base index (after Education Aid)
          if(authService.user?.is_qms == 1) {
            index += 1;
          }
          if(authService.user?.memberAccess == 'yes') {
            index += 1;
          }
          if(authService.user?.is_pdms == 1) {
            index += 1;
          }
          changeIndex(index);
        },
        children: [
          CustomMenuItem(
            label: "Change Password",
            isParent: false,
            onPress: () {
              NavService.profile();
              Scaffold.of(context).closeDrawer();
            },
          ),
          CustomMenuItem(
            label: "Check Your Dependents",
            isParent: false,
            onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DependentView()));
              Scaffold.of(context).closeDrawer();
            },
          ),
          if(checktabledata == true)
            CustomMenuItem(
              label: "Reset Thumb Recognition",
              isParent: false,
              onPress: () {
                NavService.thumb_recognition();
                Scaffold.of(context).closeDrawer();
              },
            ),
        ]
    ),

    CustomMenuItem(
      label: "All Apps",
      isParent: true,
      onPress: () {
        int index = 13; // Base index (after Profile)
        if(authService.user?.is_qms == 1) {
          index += 1;
        }
        if(authService.user?.memberAccess == 'yes') {
          index += 1;
        }
        if(authService.user?.is_pdms == 1) {
          index += 1;
        }
        changeIndex(index);
        Scaffold.of(context).closeDrawer();
        NavService.appmenu();
      },
    ),
  ];
}