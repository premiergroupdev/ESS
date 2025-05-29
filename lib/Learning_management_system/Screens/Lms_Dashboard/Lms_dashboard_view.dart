import 'package:ess/Ess_App/src/shared/spacing.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:provider/provider.dart';
import '../../../360_survey_App/Components/Circular_progress.dart';
import '../../Components/Drawer.dart';
import '../../Components/Lms_home_page_appbar.dart';
import '../../Components/Slider.dart';
import '../Course_details.dart';
import 'Lms_dashboard_view_model.dart';

class lms_Dashboard extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<lms_Dashboard> {
  final _advancedDrawerController = AdvancedDrawerController();
  late LmsDashboardViewModel model;
 bool? isDrawerOpen;
  @override
  void initState() {
    model = LmsDashboardViewModel();
    model.courses();
    _advancedDrawerController.addListener(() {
      setState(() {
        isDrawerOpen = _advancedDrawerController.value == AdvancedDrawerValue.visible();

      });

    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider<LmsDashboardViewModel>(
        create: (context) => model,
    child: Consumer<LmsDashboardViewModel>(
    builder: (context, viewModel, child) {
    return

      AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Colors.black],
          ),
        ),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child:
      model.isLoading ?
      circular_bar():
       Container(
         color: Colors.white,
          child: Column(
                  children: [
                    //VerticalSpacing(20),
                    Lms_homapge_bar(
                      title: "Premier Smart Learning Academy",
                      context: context,
                      adcontroller: _advancedDrawerController,
                      islogout: false,
                    ),


                    Expanded( // Use Expanded to take the remaining space
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),// Enable scrolling for the rest of the content
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 250,
                                child: SliderWithDots(),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Explore Courses",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                              SizedBox(height: 10),
                              GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Two cards per row
                                  childAspectRatio: 1, // Aspect ratio of each card
                                  crossAxisSpacing: 10.0, // Spacing between columns
                                  mainAxisSpacing: 10.0, // Spacing between rows
                                ),
                                itemCount: model.datalist.length,

                                // Total number of cards
                                shrinkWrap: true, // Ensure GridView doesn't take infinite height
                                physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling
                                itemBuilder: (context, index) {
                                  var data=model.datalist[index];
                                  return InkWell(

                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CourseDetailsScreen(

                                        data: model.datalist[index],

                                      )));

                                    },


                                    child:
                                  Container(

height: 200,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15.0),
                                            color: Colors.grey.shade100,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min, // 👈 Use minimum vertical space
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                // Top Image with Duration
                                                Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(15.0),
                                                      child: Image.network(
                                                        data.featureImage,
                                                        width: double.infinity,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Container(
                                                            height: 100,
                                                            color: Colors.grey,
                                                            alignment: Alignment.center,
                                                            child: Text('Failed to load image'),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 10,
                                                      right: 5,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(8),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.2),
                                                              spreadRadius: 2,
                                                              blurRadius: 5,
                                                              offset: Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                        child: RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'Duration: ',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 10,
                                                                  color: AppColors.primary,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: '${data.duration}',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 10,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 6), // 👈 Small gap after image
                                                // Title Text
                                                Text(
                                                  data.title,
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4), // 👈 Minimal spacing

                                                // Author Info
                                                Center(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Author: ',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 10,
                                                            color: AppColors.primary,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: '${data.author}',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 10,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),





                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),




      drawer: CustomSidebar(drawer: _advancedDrawerController,)
      );}) );
  }


}
