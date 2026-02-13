import 'package:flutter/material.dart';
import '../../models/api_form_data_models/pdms_survey_form_model.dart';
import '../../styles/app_colors.dart';


class SurveyDetailScreen extends StatelessWidget {
  final SurveyModel survey;

  const SurveyDetailScreen({Key? key, required this.survey}) : super(key: key);

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.primary),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : "Not Available",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullDetails = survey.fullDetails ?? {};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Center(
          child: Text(
              "Survey Details",
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Survey #${survey.surveyId}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            survey.postedDate.split(" ")[0],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow("Submitted By", survey.displayUserInfo, icon: Icons.person),
                    Divider(height: 24),
                    _buildDetailRow("Product Name", survey.productName, icon: Icons.medical_services),
                    _buildDetailRow("Generic Name", survey.generic, icon: Icons.science),
                    _buildDetailRow("Product Code", survey.productCode, icon: Icons.qr_code),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Registration Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Registration Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow("Registration No", survey.registrationNo, icon: Icons.description),
                    _buildDetailRow("System Code", fullDetails['system_code']?.toString() ?? '', icon: Icons.code),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Product Specifications Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Specifications",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow("Dosage Form", fullDetails['dosage_form']?.toString() ?? '', icon: Icons.medication),
                    _buildDetailRow("Route of Administration", fullDetails['route_admin']?.toString() ?? '', icon: Icons.route),
                    _buildDetailRow("Strength", fullDetails['strength']?.toString() ?? '', icon: Icons.fitness_center),
                    _buildDetailRow("Volume", fullDetails['volume']?.toString() ?? '', icon: Icons.water_drop),
                    _buildDetailRow("Pack Size", fullDetails['pack_size']?.toString() ?? '', icon: Icons.inventory),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Storage & Shelf Life Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Storage & Shelf Life",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow("Storage Temperature", fullDetails['storage_temp']?.toString() ?? '', icon: Icons.thermostat),
                    _buildDetailRow("Shelf Life", fullDetails['shelf_life']?.toString() ?? '', icon: Icons.calendar_today),
                    _buildDetailRow("Carton Size", fullDetails['carton_size']?.toString() ?? '', icon: Icons.shopping_cart),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Pricing Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pricing",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow("Unit Price", fullDetails['price_unit']?.toString() ?? '', icon: Icons.attach_money),
                    _buildDetailRow("Pack Price", fullDetails['price_pack']?.toString() ?? '', icon: Icons.money),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Manufacturer & Distribution Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Manufacturer & Distribution",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow("Manufacturer", fullDetails['manufacturer']?.toString() ?? '', icon: Icons.business),
                    _buildDetailRow("Manufacturer Address", fullDetails['mfr_address']?.toString() ?? '', icon: Icons.location_on),
                    _buildDetailRow("Importer", fullDetails['importer']?.toString() ?? '', icon: Icons.import_export),
                    _buildDetailRow("Importer Address", fullDetails['importer_address']?.toString() ?? '', icon: Icons.location_city),
                    _buildDetailRow("Distributor Name", fullDetails['distributor_name']?.toString() ?? '', icon: Icons.local_shipping),
                    _buildDetailRow("Distributor License No", fullDetails['dist_license_no']?.toString() ?? '', icon: Icons.badge),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Product Classification Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Classification",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow("Product Category", fullDetails['product_category']?.toString() ?? '', icon: Icons.category),
                    _buildDetailRow("Product Classification", fullDetails['product_clasification']?.toString() ?? '', icon: Icons.class_),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}