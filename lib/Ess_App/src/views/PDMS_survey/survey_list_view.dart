import 'package:ess/Ess_App/src/views/PDMS_survey/survey_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../configs/app_setup.locator.dart';
import '../../models/api_form_data_models/pdms_survey_form_model.dart';
import '../../services/local/auth_service.dart';
import '../../services/remote/api_service.dart';
import '../../shared/loading_indicator.dart';
import '../../styles/app_colors.dart';


class SurveyListScreen extends StatefulWidget {
  const SurveyListScreen({Key? key}) : super(key: key);

  @override
  State<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = locator<AuthService>();

  List<SurveyModel> allSurveys = [];
  List<SurveyModel> filteredSurveys = [];
  bool isLoading = false;
  String? errorMessage;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _authService.user?.userId?.toString();
    fetchSurveys();
  }

  Future<void> fetchSurveys() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _apiService.getSurveyList();

      result.when(
        success: (data) {
          if (data['status'] == true && data['data'] != null) {
            final List<dynamic> surveyData = data['data'];

            // Convert all surveys
            allSurveys = surveyData
                .map((item) => SurveyModel.fromJson(item))
                .toList();

            // Filter by current user
            filteredSurveys = allSurveys
                .where((survey) => survey.userId == currentUserId)
                .toList();

            print("Found ${allSurveys.length} total surveys");
            print("Found ${filteredSurveys.length} surveys for user $currentUserId");
          } else {
            setState(() {
              errorMessage = "No survey data found";
            });
          }
        },
        failure: (error) {
          setState(() {
            errorMessage = error.toString();
          });
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load surveys: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildSurveyCard(SurveyModel survey) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurveyDetailScreen(survey: survey),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Survey ID and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Survey #${survey.surveyId}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    _formatDate(survey.postedDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // User Info
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      survey.displayUserInfo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Product Info
              // Text(
              //   survey.displayTitle,
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w600,
              //   ),
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),

              SizedBox(height: 4),

              Text(
                survey.displaySubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 8),

              // Product Code
              Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 16,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Product Code: ${survey.productCode}",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Registration No
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 16,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Registration: ${survey.registrationNo}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),

                  // SizedBox(width: 40,),
                  Spacer(),
                  // View Details Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "View Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // SizedBox(height: 12),


            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 20),
          Text(
            "No Surveys Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 10),
          Text(
            currentUserId != null
                ? "No surveys found for your account ($currentUserId)"
                : "Please log in to view surveys",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          if (currentUserId != null)
            ElevatedButton(
              onPressed: fetchSurveys,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  "Refresh",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          SizedBox(height: 20),
          Text(
            "Error Loading Surveys",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? "Unknown error occurred",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchSurveys,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                "Try Again",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Center(
            child: Text(
                "My Surveys",
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ),
          leading: IconButton(

            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
        ),
      body: Center(
        child: isLoading
            ? LoadingIndicator()
            : errorMessage != null
            ? _buildErrorState()
            : filteredSurveys.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
          onRefresh: fetchSurveys,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16),
            itemCount: filteredSurveys.length,
            itemBuilder: (context, index) {
              return _buildSurveyCard(filteredSurveys[index]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchSurveys,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}