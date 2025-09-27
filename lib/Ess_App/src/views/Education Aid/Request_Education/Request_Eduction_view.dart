import 'package:ess/360_survey_App/Components/Custom_App_bar.dart';
import 'package:ess/Ess_App/src/shared/spacing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../../base/utils/constants.dart';
import '../../../shared/top_app_bar.dart';
import '../../../styles/app_colors.dart';

class EducationalAidRequestScreen extends StatefulWidget {
  const EducationalAidRequestScreen({Key? key}) : super(key: key);

  @override
  State<EducationalAidRequestScreen> createState() => _EducationalAidRequestScreenState();
}

class _EducationalAidRequestScreenState extends State<EducationalAidRequestScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers for Employee Details
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _employeeCodeController = TextEditingController();
  final _groupController = TextEditingController();
  final _departmentController = TextEditingController();
  final _cnicController = TextEditingController();
  final _dobController = TextEditingController();
  final _dojController = TextEditingController();
  final _salaryController = TextEditingController();
  final _dependentsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  // Controllers for Personal & Educational Details
  final _studentNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _currentInstitutionController = TextEditingController();
  final _gradesController = TextEditingController();
  final _degreeController = TextEditingController();
  final _tenureController = TextEditingController();
  final _feesController = TextEditingController();

  String _selectedType = 'self';
  int _currentPage = 0;
  File? _selectedFiles;
  String _fileName = '';
  bool _isSubmitting = false;

  // API Configuration
  static const String _apiUrl = 'https://premierspulse.com/ess/scripts/apply_education_aid.php';
  static const String _authHeader = 'Basic RVNTOngyRnN0VnN5eg==';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    // Dispose all controllers
    _nameController.dispose();
    _designationController.dispose();
    _employeeCodeController.dispose();
    _groupController.dispose();
    _departmentController.dispose();
    _cnicController.dispose();
    _dobController.dispose();
    _dojController.dispose();
    _salaryController.dispose();
    _dependentsController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _studentNameController.dispose();
    _ageController.dispose();
    _currentInstitutionController.dispose();
    _gradesController.dispose();
    _degreeController.dispose();
    _tenureController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _validateEmployeeForm()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateEmployeeForm() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorMessage('Name is required');
      return false;
    }
    if (_designationController.text.trim().isEmpty) {
      _showErrorMessage('Designation is required');
      return false;
    }
    if (_employeeCodeController.text.trim().isEmpty) {
      _showErrorMessage('Employee Code is required');
      return false;
    }
    if (_groupController.text.trim().isEmpty) {
      _showErrorMessage('Group is required');
      return false;
    }
    if (_departmentController.text.trim().isEmpty) {
      _showErrorMessage('Department is required');
      return false;
    }
    if (_cnicController.text.trim().isEmpty) {
      _showErrorMessage('CNIC is required');
      return false;
    }
    if (_cnicController.text.length != 15) {
      _showErrorMessage('CNIC must be 15 characters (XXXXX-XXXXXXX-X)');
      return false;
    }
    if (_dojController.text.trim().isEmpty) {
      _showErrorMessage('Date of Joining is required');
      return false;
    }
    if (_dobController.text.trim().isEmpty) {
      _showErrorMessage('Date of Birth is required');
      return false;
    }
    if (_salaryController.text.trim().isEmpty) {
      _showErrorMessage('Last Drawn Salary is required');
      return false;
    }
    if (_dependentsController.text.trim().isEmpty) {
      _showErrorMessage('Number of Dependents is required');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showErrorMessage('Phone number is required');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showErrorMessage('Address is required');
      return false;
    }
    return true;
  }


  bool _validateEducationalForm() {
    if (_studentNameController.text.trim().isEmpty) {
      _showErrorMessage('Student name is required');
      return false;
    }
    if (_ageController.text.trim().isEmpty) {
      _showErrorMessage('Age is required');
      return false;
    }
    if (_currentInstitutionController.text.trim().isEmpty) {
      _showErrorMessage('Current institution is required');
      return false;
    }
    if (_gradesController.text.trim().isEmpty) {
      _showErrorMessage('Grades are required');
      return false;
    }
    if (_degreeController.text.trim().isEmpty) {
      _showErrorMessage('Degree is required');
      return false;
    }
    if (_tenureController.text.trim().isEmpty) {
      _showErrorMessage('Tenure is required');
      return false;
    }
    if (_feesController.text.trim().isEmpty) {
      _showErrorMessage('Fees information is required');
      return false;
    }
    if (_selectedFiles == null) {
      _showErrorMessage('Please upload student document');
      return false;
    }

    return true;
  }


  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _selectFiles() async {
    try {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Files',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildFileOptionButton(
                      'Camera',
                      Icons.camera_alt,
                          () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFileOptionButton(
                      'Gallery',
                      Icons.photo_library,
                          () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _buildFileOptionButton(
                  'Documents',
                  Icons.folder,
                  _pickDocument,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _showErrorMessage('Error selecting files: $e');
    }
  }

  Widget _buildFileOptionButton(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        onTap();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor:  AppColors.primary,
        elevation: 0,
        side:  BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFiles = File(image.path);
          _fileName = image.name;
        });
        _showSuccessMessage('Image selected successfully!');
      }
    } catch (e) {
      _showErrorMessage('Error selecting image: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false, // ✅ sirf ek file
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFiles = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
        _showSuccessMessage('File selected successfully!');
      }
    } catch (e) {
      _showErrorMessage('Error selecting document: $e');
    }
  }


  // void _removeFile(int index) {
  //   setState(() {
  //     _selectedFiles.removeAt(index);
  //     _fileNames.removeAt(index);
  //   });
  // }



  Future<void> _submitForm() async {
    if (!_validateEducationalForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String baseUrl =
          "https://premierspulse.com/ess/scripts/apply_education_aid.php";

      final String url =
          "$baseUrl?login_user_code=${Uri.encodeComponent(_employeeCodeController.text.trim())}"
          "&employee_name=${Uri.encodeComponent(_nameController.text.trim())}"
          "&designation=${Uri.encodeComponent(_designationController.text.trim())}"
          "&employee_code=${Uri.encodeComponent(_employeeCodeController.text.trim())}"
          "&group=${Uri.encodeComponent(_groupController.text.trim())}"
          "&department=${Uri.encodeComponent(_departmentController.text.trim())}"
          "&cnic=${Uri.encodeComponent(_cnicController.text.trim())}"
          "&date_of_joining=${Uri.encodeComponent(_dojController.text.trim())}"
          "&date_of_birth=${Uri.encodeComponent(_dobController.text.trim())}"
          "&last_drawn_salary=${Uri.encodeComponent(_salaryController.text.trim())}"
          "&number_of_dependents=${Uri.encodeComponent(_dependentsController.text.trim())}"
          "&address=${Uri.encodeComponent(_addressController.text.trim())}"
          "&phone=${Uri.encodeComponent(_phoneController.text.trim())}"
          "&city=${Uri.encodeComponent(_cityController.text.trim())}"
          "&student_name=${Uri.encodeComponent(_studentNameController.text.trim())}"
          "&age=${Uri.encodeComponent(_ageController.text.trim())}"
          "&current_institution=${Uri.encodeComponent(_currentInstitutionController.text.trim())}"
          "&grades=${Uri.encodeComponent(_gradesController.text.trim())}"
          "&degree_name=${Uri.encodeComponent(_degreeController.text.trim())}"
          "&total_tenure=${Uri.encodeComponent(_tenureController.text.trim())}"
          "&fees=${Uri.encodeComponent(_feesController.text.trim())}"
          "&case_type=${Uri.encodeComponent(_selectedType.toString())}"; // 👈 image as Base64 string
print(url);
      final response = await http.MultipartRequest('POST', Uri.parse(url),

      );

      response.headers['Authorization'] = "Basic RVNTOngyRnN0VnN5eg==";

      if (_selectedFiles != null) {
        response.files.add(
          await http.MultipartFile.fromPath(
            'file', // API field
            _selectedFiles!.path,
          ),
        );
      }

      var myRequest = await response.send();
      var respons = await http.Response.fromStream(myRequest);
      print("${respons.statusCode}");
      http.Client().close();

      if (respons.statusCode == 200) {
        print("✅ Success: ${respons.body}");
        var data = jsonDecode(respons.body);
        if(data['status'] == "200")
          {
            Constants.customSuccessSnack(context, data['status_message']);
            Navigator.pop(context);
          }
        else {
          Constants.customErrorSnack(context, data['status_message']);

        }
      } else {
        print("❌ Error: ${respons.statusCode}");
      }
    } catch (e, stack) {
      _showErrorMessage('Network error: ');
      print("Stack: $stack");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }


  void _clearForm() {
    // Clear all controllers
    _nameController.clear();
    _designationController.clear();
    _employeeCodeController.clear();
    _groupController.clear();
    _departmentController.clear();
    _cnicController.clear();
    _dobController.clear();
    _dojController.clear();
    _salaryController.clear();
    _dependentsController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _studentNameController.clear();
    _ageController.clear();
    _currentInstitutionController.clear();
    _gradesController.clear();
    _degreeController.clear();
    _tenureController.clear();
    _feesController.clear();

    setState(() {
      _selectedType = 'self';
      _currentPage = 0;
      _selectedFiles = null;
      _fileName ='';
    });

    // Navigate back to first page
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body:
      Column( children: [
        VerticalSpacing(10),
        GeneralAppBar(
            title: "Request Education Aid",
            onMenuTap: () {
              Scaffold.of(context).openDrawer();
            },
            onNotificationTap: () {}),
      Expanded(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Progress Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      _buildProgressStep(0, 'Employee Details', _currentPage >= 0),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: _currentPage >= 1 ?  AppColors.primary : Colors.grey[300],
                        ),
                      ),
                      _buildProgressStep(1, 'Educational Details', _currentPage >= 1),
                    ],
                  ),
                ),

                // Form Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildEmployeeDetailsForm(),
                      _buildEducationalDetailsForm(),
                    ],
                  ),
                ),

                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: _buildButton(
                            'Previous',
                            _isSubmitting ? () {} : _previousPage,
                            isSecondary: true,
                            isDisabled: _isSubmitting,
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        child: _buildButton(
                          _currentPage == 0 ? 'Next' : (_isSubmitting ? 'Submitting...' : 'Submit Application'),
                          _isSubmitting ? () {} : (_currentPage == 0 ? _nextPage : _submitForm),
                          isLoading: _isSubmitting,
                          isDisabled: _isSubmitting,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]
      )
    );
  }

  Widget _buildProgressStep(int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ?  AppColors.primary : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primary : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeDetailsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Employee Details'),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildDropdownField(
                    'Type',
                    _selectedType,
                    ['self', 'spouse', 'child'],
                        (value) => setState(() => _selectedType = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildTextField('Name', _nameController, isRequired: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildTextField('Designation', _designationController, isRequired: true),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Employee Code', _employeeCodeController, isRequired: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Group', _groupController, isRequired: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Department', _departmentController, isRequired: true),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('CNIC', _cnicController, isRequired: true, inputType: TextInputType.number),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField('Date of Joining (DOJ)', _dojController),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField('Date of Birth (DOB)', _dobController, ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Last Drawn Salary (Last Month)', _salaryController, inputType: TextInputType.number, isRequired: true),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Number of Dependents', _dependentsController, inputType: TextInputType.number, isRequired: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Address', _addressController, isRequired: true),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Phone / Cell No', _phoneController, isRequired: true, inputType: TextInputType.phone),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('City', _cityController, isRequired: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalDetailsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal & Educational Details'),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildTextField('Student Name', _studentNameController, isRequired: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Age', _ageController, isRequired: true, inputType: TextInputType.number),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Current (School / College / University)', _currentInstitutionController, isRequired: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Grades / Division (Last Achieved)', _gradesController, isRequired: true),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Pursuing for (Degree Name)', _degreeController, isRequired: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Total Tenure', _tenureController, isRequired: true),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildTextField('Enter Monthly/Yearly Fees', _feesController, isRequired: true, inputType: TextInputType.number),

          const SizedBox(height: 24),
          _buildFileUploadSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {
    bool isRequired = false,
    TextInputType inputType = TextInputType.text
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          validator: isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:  BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
          },
          decoration: InputDecoration(
            hintText: 'YYYY-MM-DD',
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:  BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:  BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option.toUpperCase()),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Attachments *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                 Text(
                  'Choose Files',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _fileName.isEmpty ? 'No files chosen' : '${_fileName.length} file(s) selected',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_fileName != '')
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color:  AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  _getFileIcon(_fileName!),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fileName!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFiles = null;
                      _fileName = '';
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }

  Widget _buildButton(String text, VoidCallback onPressed, {
    bool isSecondary = false,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return Container(
      height: 56,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : AppColors.primary,
          foregroundColor: isSecondary ? const Color(0xFF374151) : Colors.white,
          elevation: 0,
          side: isSecondary ? BorderSide(color: Colors.grey[300]!) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

