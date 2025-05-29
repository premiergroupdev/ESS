import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Components/Circular_progress.dart';
import '../../Components/Custom_App_bar.dart';
import '../../Components/Custom_drawer.dart';
import '../../Components/Table_Values.dart';
import '../../Components/container.dart';
import '../Check_pool/check_poll_view.dart';
import '../Feedback/Feedback_view.dart';
import 'Dashboard_view_model.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen();

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late SurveyDashboardViewModel model;
  @override
  void initState( ) {
    model = SurveyDashboardViewModel();
    model.status();
    model.status1data();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return

      ChangeNotifierProvider<SurveyDashboardViewModel>(
          create: (context) => model,
          child: Consumer<SurveyDashboardViewModel>(
          builder: (context, viewModel, child) {
            return
              Scaffold(
                //appBar: CustomAppBar(title: "Dashboard", islogout: true),
                  drawer: CustomDrawer(),
                  body:
                   Column(
                    children: [
                      CustomBar(
                          title: 'Dashboard', islogout: true, context: context),

                      Expanded(

                        child:
                        viewModel.isLoading
                            ? circular_bar() // Replace with your loading widget
                            :
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(children: [
                              if(model.datalist !=null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                children: [
                                  _buildBox('Your Strongly Agree', model.datalist!.stronglyAgree,
                                      AppColors.primary, Icons.thumb_up),
                                  _buildBox(
                                      'Your Agree', model.datalist!.agree, AppColors.primary,
                                      Icons.check),
                                ],
                              ),
                              SizedBox(height: 20),
                              if(model.datalist !=null)// Add space between rows
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                children: [
                                  _buildBox('Your Disagree', model.datalist!.disAgree, AppColors.primary, Icons.thumb_down),
                                  _buildBox('Your Strongly Disagree', model.datalist!.stronglyDisagree, AppColors.primary, Icons.cancel),
                                ],
                              ),

                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/images/step2.png", height: 100,
                                    width: 100,),
                                  containerwidget(
                                    title: 'Give your feedback',
                                    color: Colors.purple,
                                    Textcolor: Colors.white,
ontap: (){
  Navigator.push(context , MaterialPageRoute(builder: (context)=> Feedbacks()));
},
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/images/check.png", height: 100,
                                    width: 100,),
                                  containerwidget(
                                    title: 'Check your feedback',
                                    color: Colors.green,
                                    Textcolor: Colors.white,
                                    ontap: (){
                                      Navigator.push(context , MaterialPageRoute(builder: (context)=> check_poll()));
                                    },
                                  ),
                                ],
                              ),

                              SizedBox(height: 25),
                              if(model.stats1 !=null)
                              Column(
                                children: [
                                  Text("Summary Of Premier 360 Feedback",
                                    style: TextStyle(color: AppColors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),),
                                  SizedBox(height: 40),
                                  TableValues(title: 'Categories', sa: 'SA', sd: 'SD', d: 'D', a: 'A', titleFontWeight: FontWeight.bold, saFontWeight: FontWeight.bold,dFontWeight: FontWeight.bold,aFontWeight: FontWeight.bold,sdFontWeight: FontWeight.bold,)
                                  ,DynamicDivider()
                                  //,SizedBox(height: 7,),
                                  , TableValues(title: 'Personal Characteristics',  sa: model.stats1!.stronglyAgreeCat1.toString(), sd: model.stats1!.stronglyDisagreeCat1.toString(), d: model.stats1!.disagreeCat1.toString(), a: model.stats1!.agreeCat1.toString(), titleFontWeight: FontWeight.bold, saColor: AppColors.primary,sdColor: AppColors.primary, dColor: AppColors.primary,aColor: AppColors.primary,)
                                  ,DynamicDivider(),
                                  TableValues(title: 'Leadership Skills',  sa: 'SA', sd: 'SD', d: 'D', a: 'A', titleFontWeight: FontWeight.bold, saColor: AppColors.primary,sdColor: AppColors.primary, dColor: AppColors.primary,aColor: AppColors.primary,)
                                  ,DynamicDivider(),
                                  TableValues(title: 'Interpersonal Skills',  sa: 'SA', sd: 'SD', d: 'D', a: 'A', titleFontWeight: FontWeight.bold, saColor: AppColors.primary,sdColor: AppColors.primary, dColor: AppColors.primary,aColor: AppColors.primary,)
                                  ,DynamicDivider(),
                                  TableValues(title: 'Building Talent',  sa: 'SA', sd: 'SD', d: 'D', a: 'A', titleFontWeight: FontWeight.bold, saColor: AppColors.primary,sdColor: AppColors.primary, dColor: AppColors.primary,aColor: AppColors.primary,)
                                  ,DynamicDivider(),
                                ],
                              ),

                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                  );
          }));}
}

Widget _buildBox(String title, String value, Color color, IconData icon) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double width = constraints.maxWidth > 200 ? 180 : constraints.maxWidth * 0.9;
      return Container(
        width: width,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon inside a circular background
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    },
  );
}


