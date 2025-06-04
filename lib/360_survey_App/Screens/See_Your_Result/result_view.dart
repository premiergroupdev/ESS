import 'package:ess/360_survey_App/Screens/See_Your_Result/result_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Ess_App/src/base/utils/constants.dart';
import '../../../Ess_App/src/styles/app_colors.dart';
import '../../../Ess_App/src/views/dashboard/widget/available_leaves_chart.dart';
import '../../Components/Chart.dart';
import '../../Components/Circular_progress.dart';
import '../../Components/Custom_App_bar.dart';
import '../../Components/Custom_drawer.dart';
import '../../Components/container.dart';

class Result extends StatefulWidget {
  //final List<Question> question;
  const Result();

  @override
  State<Result> createState() => _Given_FeedbackState();
}

class _Given_FeedbackState extends State<Result> {


  late final List<int?> selectedOptions = List.filled(model.questions.length, null);
  List<String> options=['Strongly Agree', 'Agree', 'Disagree', 'Strongly Disagree'];
  late final List<String?> comments = List.filled(model.questions.length, null);

  final TextEditingController commentController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0; // To track the current page
  late ResultViewModel model;
  @override
  void initState() {
    model = ResultViewModel();
    model.fetchquestions();
    model.resultdata("1");
    super.initState();
  }
  // @override
  // void dispose() {
  //   _pageController.dispose(); // Clean up controller
  //   super.dispose();
  // }
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ResultViewModel>(
      create: (context) => model,
      child: Consumer<ResultViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            drawer: CustomDrawer(),
            body: Column(
              children: [
                CustomBar(title: 'Results', context: context),
                viewModel.isLoading
                    ? Expanded(child: circular_bar())
                    : Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: model.questions.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        model.questions[index].category.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Q${index + 1}: ${model.questions[index].question}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    if (model.resultlist != null)
                                      Container(
                                        height: 200,
                                        child: Chart(data: model.resultlist!),
                                      ),
                                    SizedBox(height: 20),
                                    if (viewModel.resultlist?.comments != null)
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: viewModel.resultlist!.comments.length,
                                        itemBuilder: (context, commentIndex) {
                                          var data = viewModel.resultlist!.comments[commentIndex];
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "Comments: ",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: data,
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (index == 0)
                                          SizedBox()
                                        else
                                          containerwidget(
                                            title: "Previous",
                                            color: Colors.red,
                                            Textcolor: Colors.white,
                                            ontap: () async {
                                              await model.resultdata1(model.questions[index - 1].id);
                                              _pageController.previousPage(
                                                duration: Duration(milliseconds: 300),
                                                curve: Curves.easeIn,
                                              );
                                            },
                                          ),
                                        if (index < model.questions.length - 1)
                                          containerwidget(
                                            title: "Next",
                                            color: AppColors.primary,
                                            Textcolor: Colors.white,
                                            ontap: () async {
                                              await model.resultdata1(model.questions[index + 1].id);
                                              if (_pageController.hasClients) {
                                                _pageController.nextPage(
                                                  duration: Duration(milliseconds: 300),
                                                  curve: Curves.easeIn,
                                                );
                                              }
                                            },
                                          )
                                        else
                                          containerwidget(
                                            title: "Submit",
                                            color: Colors.green,
                                            Textcolor: Colors.white,
                                            ontap: _submitFeedback,
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    if (model.resultlist != null)
                                      Container(
                                        height: 100,
                                        child: PieChartSample(
                                          dataMap: {
                                            "Strongly Agree": double.tryParse(
                                                model.resultlist!.stronglyAgree.toString()) ??
                                                0.0,
                                            "Agree": double.tryParse(
                                                model.resultlist!.agree.toString()) ??
                                                0.0,
                                            "Disagree": double.tryParse(
                                                model.resultlist!.disAgree.toString()) ??
                                                0.0,
                                            "Strongly Disagree": double.tryParse(
                                                model.resultlist!.stronglyDisagree.toString()) ??
                                                0.0,
                                          },
                                        ),
                                      ),
                                    SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Page Indicator Dots
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(model.questions.length, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }



  void _submitFeedback() {


    // Handle feedback submission logic here
    // print("Feedback submitted!");
    // print("Selected Options: $selectedOptions");
    //
    // print("Comments: ${comments}");
    // Clear the form or navigate to a different screen
    //Navigator.pop(context); // or clear the form
    Constants.customSuccessSnack(context, 'Feedback Submitted Successfully.');
  }
}
