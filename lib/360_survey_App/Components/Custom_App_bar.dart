import 'package:ess/360_survey_App/Api_services/data/Local_services/Session.dart';
import 'package:ess/Ess_App/src/services/local/navigation_service.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
   bool islogout;


  CustomAppBar({required this.title, this.islogout=false}); // Constructor ke through title ko initialize karna

  @override
  Widget build(BuildContext context) {
    return AppBar(
backgroundColor: AppColors.primary,
        centerTitle: true,
        title: Text(title, style: TextStyle(color: AppColors.white),), // Title ko use karna
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(

            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8)),

            child: IconButton(
              icon: Icon(Icons.menu, color: AppColors.primary,),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        actions: [
          islogout==true ?
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon: Icon(Icons.logout, color: Colors.white,), // Logout icon
                onPressed: () {

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            print("object");
                            SharedPreferences sp= await SharedPreferences.getInstance();
sp.clear();
UserData.clearUserData();
                            Navigator.of(context).pop(); // Close dialog
                            NavService.appmenu();
                         //   Navigator.push(context, MaterialPageRoute(builder: (context)=>AppMenu()));
                            // Navigator.of(context).pushAndRemoveUntil(
                            //   MaterialPageRoute(builder: (context) => AppMenu()),
                            //       (Route<dynamic> route) => false, // Remove all previous routes
                            // );

                          },
                          child: Text('Logout'),
                        ),

                      ],
                    ),
                  );
                },
              ),
            ),
          ) : SizedBox()
        ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)), // Set border radius
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}




class CustomBar extends StatelessWidget {
  final String title;
  final bool islogout;
  final BuildContext context;

  CustomBar({required this.title, this.islogout = false, required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Menu Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.menu, color: AppColors.primary),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),

            // Title Centered
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Logout Button (if applicable)
            if (islogout)
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    _showLogoutDialog(this.context);
                  },
                ),
              )
            else
              SizedBox(width: 48), // Placeholder to balance the row
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        backgroundColor: AppColors.primary,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              SharedPreferences sp = await SharedPreferences.getInstance();
              await sp.clear();
              UserData.clearUserData();
              Navigator.of(context).pop();
              NavService.appmenu(); // Navigate to app menu
            },
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}




class GenenralBar extends StatelessWidget {
  final String title;
  bool islogout;
  BuildContext context;

  GenenralBar({required this.title, this.islogout=false, required this.context}); // Constructor without islogout

  @override
  Widget build( context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 1.0), // Add some padding
          decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color
                  offset: Offset(0, 4), // Position of the shadow
                  blurRadius: 6, // Blur effect
                  spreadRadius: 0,
                )
              ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                     // Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
              ),
              Center(
                child: Text(
                  title,
                  style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold), // Title text style
                ),
              ),

              islogout==true ?
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    icon: Icon(Icons.logout, color: Colors.white,), // Logout icon
                    onPressed: () {

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Set title text color to white
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to logout?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white, // Set content text color to white
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: AppColors.primary, // Set the background color to your primary color
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                print("Logging out...");
                                SharedPreferences sp = await SharedPreferences.getInstance();
                                await sp.clear();
                                UserData.clearUserData();
                                Navigator.of(context).pop(); // Close dialog
                                NavService.appmenu(); // Navigate to app menu
                              },
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                    },
                  ),
                ),
              ) : Text(""),
              if(islogout==false)
                Text('')
              // SizedBox(width: 48),
              // Placeholder for alignment
            ],
          ),
        ),
        SizedBox(height: 13,)
        // You can add more widgets below the AppBar if needed
      ],
    );
  }
}








class GeneAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isLogout;

  // Constructor to initialize title and isLogout
  GeneAppBar({required this.title, this.isLogout = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(color: Colors.white), // Set title text color to white
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white), // Back icon color
        onPressed: () {
          Navigator.pop(context); // Pop the current route
        },
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)), // Set border radius
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

