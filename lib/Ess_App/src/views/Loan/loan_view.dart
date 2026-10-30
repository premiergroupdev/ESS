import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import '../../base/utils/constants.dart';
import '../../models/api_response_models/loan_employee.dart';
import '../../shared/bottons.dart';
import '../../shared/loading_indicator.dart';
import '../../shared/top_app_bar.dart';
import '../../styles/app_colors.dart';
import 'Ceo_loan_approval/Ceo_loan_approval_view.dart'; // CurrencyInputFormatter
import 'customsearchabledropdown.dart';
import 'loan_view_model.dart';

class Loan extends StatefulWidget {
  @override
  State<Loan> createState() => _LoanState();
}

class _LoanState extends State<Loan> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoanViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "Apply Loan",
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  onNotificationTap: () {}),
              Expanded(
                child: model.isBusy
                    ? const Center(child: LoadingIndicator())
                    : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. Applicant ───────────────────────────
                        // NOTE: this Column has a fixed number of children.
                        // Parts that come and go use "cond ? widget :
                        // SizedBox.shrink()" instead of "if (...) ...[ ]", so
                        // the widgets below keep their position (and State,
                        // e.g. the selected label of a dropdown) when they
                        // appear or disappear.
                        _SectionCard(
                          icon: Icons.person_outline_rounded,
                          title: 'Applicant',
                          child: Column(
                            children: [
                              _DropdownField(
                                label: 'Loan Application Type',
                                error: model.applicantDropdownError
                                    ? 'Please select applicant type'
                                    : null,
                                dropdown: _OptionPickerField(
                                  title: 'Applying for',
                                  hint: 'Select applicant type',
                                  icon: Icons.groups_2_outlined,
                                  options: model.loan_applicants,
                                  currentValue: model.loanapplicants,
                                  hasError: model.applicantDropdownError,
                                  onSelected: (value) {
                                    FocusScope.of(context).unfocus();
                                    // clears the applicant fields, then
                                    // autofills (Self) or loads the
                                    // employee list (For Employee)
                                    model.onApplicantTypeChanged(
                                        context, value);
                                  },
                                ),
                              ),

                              // Thin progress bar while an employee API call runs
                              model.isFetchingEmployee
                                  ? const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: LinearProgressIndicator(
                                  minHeight: 2,
                                  color: AppColors.primary,
                                ),
                              )
                                  : const SizedBox.shrink(),

                              // Employee picker (For Employee only)
                              model.loanapplicants == "for_employee"
                                  ? Padding(
                                padding:
                                const EdgeInsets.only(top: 12),
                                child: _DropdownField(
                                  label: 'Employee',
                                  error: model.employeeDropdownError
                                      ? 'Please select an employee'
                                      : null,
                                  dropdown: model
                                      .employeeList.isNotEmpty
                                      ? _EmployeePickerField(
                                    employees: model.employeeList,
                                    selectedCode:
                                    model.selectedEmployeeCode,
                                    hasError:
                                    model.employeeDropdownError,
                                    onSelected: (employee) {
                                      FocusScope.of(context)
                                          .unfocus();
                                      model.onEmployeeSelected(
                                          context, employee);
                                    },
                                  )
                                      : _EmployeeStatusBox(
                                    isLoading: model.isFetchingEmployee,
                                    message: model.employeeListError,
                                  ),
                                ),
                              )
                                  : const SizedBox.shrink(),

                              const SizedBox(height: 12),
                              _Field(
                                label: 'Name',
                                hint: 'Enter name',
                                icon: Icons.badge_outlined,
                                controller: model.namecontroller,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _Field(
                                label: 'Employee code',
                                hint: 'Code',
                                controller: model.empcodecontroller,
                                inputType: TextInputType.number,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Code is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _Pair(
                                left: _Field(
                                  label: 'Position',
                                  hint: 'Position',
                                  controller: model.positioncontroller,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Position is required';
                                    }
                                    return null;
                                  },
                                ),
                                right: _Field(
                                  label: 'Department',
                                  hint: 'Department',
                                  controller: model.departmentcontroller,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Department is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Branch is now plain read-only text, filled
                              // from the employee API.
                              _Field(
                                label: 'Branch',
                                hint: 'Filled automatically',
                                icon: Icons.apartment_rounded,
                                controller: model.branchcontroller,
                                readOnly: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Branch is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _Pair(
                                left: _Field(
                                  label: 'Mobile number',
                                  hint: '03XXXXXXXXX',
                                  controller: model.mobilenumbercontroller,
                                  inputType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Number is required';
                                    }
                                    return null;
                                  },
                                ),
                                right: _Field(
                                  label: 'Date of joining',
                                  hint: 'Select date',
                                  icon: Icons.calendar_month,
                                  controller: model.dateofjoningcontroller,
                                  inputType: TextInputType.datetime,
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? pickedDate =
                                    await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                      firstDate: DateTime(1900),
                                    );

                                    if (pickedDate != null) {
                                      model.bookDateFormat = pickedDate;
                                      String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                      model.dateofjoningcontroller.text =
                                          formattedDate;
                                      model.notifyListeners();
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please select date of joining';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              _Field(
                                label: 'CNIC',
                                hint: '00000-0000000-0',
                                icon: Icons.credit_card_rounded,
                                controller: model.cniccontroller,
                                inputType: TextInputType.number,
                                formatter: [CnicFormatter()],
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'CNIC is required';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── 2. Loan details ────────────────────────
                        _SectionCard(
                          icon: Icons.request_quote_rounded,
                          title: 'Loan details',
                          child: Column(
                            children: [
                              _DropdownField(
                                label: 'Loan type',
                                error: model.loanTypeDropdownError
                                    ? 'Please select loan type'
                                    : null,
                                dropdown: _OptionPickerField(
                                  title: 'Loan type',
                                  hint: 'Select Loan Type',
                                  icon: Icons.request_quote_outlined,
                                  options: model.finalApprovalData
                                      .map<String>(
                                          (item) => '${item.loanTypeName}')
                                      .toList(),
                                  currentValue: model.selectedValue,
                                  hasError: model.loanTypeDropdownError,
                                  onSelected: (name) {
                                    FocusScope.of(context).unfocus();
                                    final item = model.finalApprovalData
                                        .firstWhere((i) =>
                                    '${i.loanTypeName}' == name);
                                    setState(() {
                                      model.selectedValue =
                                          item.loanTypeId.toString();
                                      model.loanTypeDropdownError = false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              _Pair(
                                left: _Field(
                                  label: 'Loan amount (Rs)',
                                  hint: 'Enter amount',
                                  controller: model.loanamountrs,
                                  formatter: [CurrencyInputFormatter()],
                                  inputType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Loan Amount is required';
                                    }
                                    return null;
                                  },
                                ),
                                right: _Field(
                                  label: 'Repay in (months)',
                                  hint: 'Months',
                                  controller:
                                  model.repay_loan_month_controller,
                                  inputType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Repay loan is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              _Field(
                                label: 'Loan amount in words',
                                hint: 'e.g. Fifty thousand rupees',
                                icon: Icons.text_fields_rounded,
                                controller:
                                model.loanamountinwordscontroller,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Loan Amount In Words is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _Field(
                                label: 'Purpose of loan',
                                hint: 'Why do you need this loan?',
                                icon: Icons.notes_rounded,
                                controller: model.purposeofloancontroller,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Purpose is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _InstallmentBox(
                                installment: NumberFormat('#,##0').format(
                                  int.tryParse(
                                      model.resultController.text) ??
                                      0,
                                ),
                                months: model
                                    .repay_loan_month_controller.text
                                    .trim(),
                              ),
                            ],
                          ),
                        ),

                        // ── 3. Guarantors (self applications only) ─
                        if (model.loanapplicants == "for_self") ...[
                          const SizedBox(height: 12),
                          _SectionCard(
                            icon: Icons.verified_user_outlined,
                            title: 'Guarantors',
                            child: Column(
                              children: [
                                _DropdownField(
                                  label: 'Guarantor 1',
                                  error: model.guarantor1DropdownError
                                      ? 'Please select guarantor 1'
                                      : null,
                                  dropdown: CustomSearchableDropDown(
                                    items: model.finalguaranterlist1,
                                    label: 'Select Guarantor 1',
                                    decoration: _dropdownDecoration(
                                        model.guarantor1DropdownError),
                                    prefixIcon: _dropdownIcon(),
                                    dropDownMenuItems: model
                                        .finalguaranterlist1
                                        .map((item) => item.member_name)
                                        .toList(),
                                    onChanged: (value) {
                                      FocusScope.of(context).unfocus();
                                      if (value != null) {
                                        setState(() {
                                          model.selectedgraduatevalue1 =
                                              value.member_code
                                                  .toString();
                                          model.guarantor1DropdownError =
                                          false;
                                        });
                                      } else {
                                        // called while building when the list is empty -> no setState
                                        model.selectedgraduatevalue1 = '';
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _DropdownField(
                                  label: 'Guarantor 2',
                                  error: model.guarantor2DropdownError
                                      ? 'Please select guarantor 2'
                                      : null,
                                  dropdown: CustomSearchableDropDown(
                                    items: model.finalguaranterlist2,
                                    label: 'Select Guarantor 2',
                                    decoration: _dropdownDecoration(
                                        model.guarantor2DropdownError),
                                    prefixIcon: _dropdownIcon(),
                                    dropDownMenuItems: model
                                        .finalguaranterlist2
                                        .map((item) => item.member_name)
                                        .toList(),
                                    onChanged: (value) {
                                      FocusScope.of(context).unfocus();
                                      if (value != null) {
                                        setState(() {
                                          model.selectedgraduatevalue2 =
                                              value.member_code
                                                  .toString();
                                          model.guarantor2DropdownError =
                                          false;
                                        });
                                      } else {
                                        // called while building when the list is empty -> no setState
                                        model.selectedgraduatevalue2 = '';
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ── 4. Attachment ──────────────────────────
                        const SizedBox(height: 12),
                        _SectionCard(
                          icon: Icons.attach_file_rounded,
                          title: 'Attachment',
                          child: _AttachmentTile(
                            path: model.imagepath,
                            showError: model.imageError == true &&
                                model.imagepath.isEmpty,
                            onPick: () async {
                              model.imageError = model.imagepath.isEmpty;
                              model.get_gallery_image();
                            },
                          ),
                        ),

                        // ── Declaration ────────────────────────────
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 20, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'I solemnly affirm that the application of loan is made to meet expenses stated as the purpose already mentioned above.',
                                  style: TextStyling.body.copyWith(
                                      color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        MainButton(
                          text: "Apply Loan",
                          isBusy: model.isBusy,
                          onTap: () {
                            setState(() {
                              model.applicantDropdownError =
                                  (model.loanapplicants ?? '').isEmpty;
                              model.loanTypeDropdownError =
                                  (model.selectedValue ?? '').isEmpty;

                              if (model.loanapplicants == "for_self") {
                                model.guarantor1DropdownError =
                                    (model.selectedgraduatevalue1 ?? '')
                                        .isEmpty;
                                model.guarantor2DropdownError =
                                    (model.selectedgraduatevalue2 ?? '')
                                        .isEmpty;
                              } else {
                                model.guarantor1DropdownError = false;
                                model.guarantor2DropdownError = false;
                              }

                              // For Employee: an employee must be picked
                              model.employeeDropdownError =
                                  model.loanapplicants == "for_employee" &&
                                      (model.selectedEmployeeCode ?? '')
                                          .isEmpty;
                            });

                            if (model.imagepath.isEmpty) {
                              setState(() {
                                model.imageError = true;
                              });
                            } else {
                              model.imageError = false;
                            }

                            // If any dropdown or image error is true, stop here
                            if (model.applicantDropdownError ||
                                model.loanTypeDropdownError ||
                                model.employeeDropdownError ||
                                model.imageError ||
                                (model.loanapplicants == "for_self" &&
                                    (model.guarantor1DropdownError ||
                                        model.guarantor2DropdownError))) {
                              Constants.customErrorSnack(context,
                                  "Please fill in all dropdowns and attachments.");
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              if (model.namecontroller.text.isNotEmpty &&
                                  model.positioncontroller.text
                                      .isNotEmpty &&
                                  model.departmentcontroller.text
                                      .isNotEmpty &&
                                  (model.branchvalue ?? '').isNotEmpty &&
                                  model.imagepath.isNotEmpty &&
                                  model.empcodecontroller.text
                                      .isNotEmpty &&
                                  model.mobilenumbercontroller.text
                                      .isNotEmpty &&
                                  model.dateofjoningcontroller.text
                                      .isNotEmpty &&
                                  model.cniccontroller.text.isNotEmpty &&
                                  model.loanamountrs.text.isNotEmpty &&
                                  model.loanamountinwordscontroller.text
                                      .isNotEmpty &&
                                  model.purposeofloancontroller.text
                                      .isNotEmpty &&
                                  ((model.selectedValue !=
                                      "pf_permanent_withdrawl" &&
                                      model.repay_loan_month_controller
                                          .text.isNotEmpty &&
                                      model.resultController.text
                                          .isNotEmpty) ||
                                      model.selectedValue ==
                                          "pf_permanent_withdrawl")) {
                                if (model.mobilenumbercontroller.text
                                    .length >=
                                    11 &&
                                    model.mobilenumbercontroller.text
                                        .length <=
                                        11) {
                                  model.applyloan(context);
                                } else {
                                  Constants.customErrorSnack(context,
                                      "Please enter a valid mobile number");
                                }
                              } else {
                                Constants.customErrorSnack(
                                    context, "Please fill in all fields");
                              }
                            }
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
      ),
      viewModelBuilder: () => LoanViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────

/// Look of the searchable dropdown's box (matches the theme's text fields).
BoxDecoration _dropdownDecoration(bool hasError) => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(
    color: hasError ? AppColors.danger : AppColors.border,
  ),
);

Widget _dropdownIcon() => const Padding(
  padding: EdgeInsets.only(left: 14, right: 10),
  child: Icon(Icons.search_rounded, size: 20, color: AppColors.darkGrey),
);

/// White card with an icon + title header; groups one part of the form.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, size: 28),
              const SizedBox(width: 8),
              Text(title, style: TextStyling.section),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Label above a themed TextFormField (same look as SecondInputField).
class _Field extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController controller;
  final TextInputType? inputType;
  final List<TextInputFormatter>? formatter;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.inputType,
    this.formatter,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyling.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          inputFormatters: formatter,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          cursorColor: AppColors.primary,
          style: TextStyling.text16.copyWith(color: AppColors.black),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            hintText: hint,
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: 20, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// Label above a searchable dropdown, with its own error line underneath.
class _DropdownField extends StatelessWidget {
  final String label;
  final String? error;
  final Widget dropdown;

  const _DropdownField({
    required this.label,
    required this.dropdown,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyling.label),
        const SizedBox(height: 6),
        dropdown,
        if (error != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              error!,
              style: TextStyling.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ],
    );
  }
}

/// Two fields side by side.
class _Pair extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _Pair({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

/// Shows the computed monthly installment under the repayment field.
class _InstallmentBox extends StatelessWidget {
  final String installment;
  final String months;

  const _InstallmentBox({required this.installment, required this.months});

  @override
  Widget build(BuildContext context) {
    final hasMonths = months.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly installment', style: TextStyling.caption),
          const SizedBox(height: 2),
          Text(
            'Rs. $installment',
            style: TextStyling.title.copyWith(color: AppColors.primary),
          ),
          if (hasMonths) ...[
            const SizedBox(height: 2),
            Text('over $months month${months == '1' ? '' : 's'}',
                style: TextStyling.caption),
          ],
          const SizedBox(height: 6),
          Text(
            'Equal monthly installments of the principal. Mark-up (if opted), as per the employee loan facility rules, is over and above the installment.',
            style: TextStyling.caption.copyWith(fontSize: 11, height: 1.35),
          ),
        ],
      ),
    );
  }
}

/// CNIC upload row: shows what is attached, an error if missing, and a button.
class _AttachmentTile extends StatelessWidget {
  final String path;
  final bool showError;
  final VoidCallback onPick;

  const _AttachmentTile({
    required this.path,
    required this.showError,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final attached = path.isNotEmpty;
    final fileName = attached ? path.split(RegExp(r'[\\/]')).last : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: attached ? AppColors.successSoft : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: showError
                  ? AppColors.danger
                  : (attached ? AppColors.success : AppColors.border),
            ),
          ),
          child: Row(
            children: [
              IconTile(
                icon: attached
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                color: attached ? AppColors.success : AppColors.primary,
                size: 36,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attached ? 'CNIC attached' : 'CNIC copy',
                      style: TextStyling.bold14,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      attached ? fileName : 'Upload a clear photo of your CNIC',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyling.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onPick,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(attached ? 'Change' : 'Upload'),
              ),
            ],
          ),
        ),
        if (showError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Attachment is required',
              style: TextStyling.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ],
    );
  }
}

class CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      if (i == 5 || i == 12) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Employee picker (bottom sheet)
// ─────────────────────────────────────────────────────────────────────────

/// Tappable field that looks like the other inputs and opens a nice
/// searchable bottom sheet to pick an employee.
class _EmployeePickerField extends StatefulWidget {
  final List<LoanEmployee> employees;
  final String? selectedCode;
  final bool hasError;
  final ValueChanged<LoanEmployee> onSelected;

  const _EmployeePickerField({
    required this.employees,
    required this.onSelected,
    this.selectedCode,
    this.hasError = false,
  });

  @override
  State<_EmployeePickerField> createState() => _EmployeePickerFieldState();
}

class _EmployeePickerFieldState extends State<_EmployeePickerField> {
  LoanEmployee? _selected;

  @override
  void didUpdateWidget(covariant _EmployeePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Selection was cleared by the view model (e.g. applicant type changed)
    if ((widget.selectedCode ?? '').isEmpty && _selected != null) {
      _selected = null;
    }
  }

  Future<void> _open() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<LoanEmployee>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmployeeSheet(
        employees: widget.employees,
        selected: _selected,
      ),
    );
    if (picked != null) {
      setState(() => _selected = picked);
      widget.onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = _selected;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _open,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: _dropdownDecoration(widget.hasError),
        child: Row(
          children: [
            const Icon(Icons.person_search_rounded,
                size: 20, color: AppColors.darkGrey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                e == null
                    ? 'Select Employee'
                    : '${e.empName} - ${e.empCode}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyling.text16.copyWith(
                  color: e == null ? AppColors.darkGrey : AppColors.black,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkGrey),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: handle, title, rounded search bar, and a clean list.
class _EmployeeSheet extends StatefulWidget {
  final List<LoanEmployee> employees;
  final LoanEmployee? selected;

  const _EmployeeSheet({required this.employees, this.selected});

  @override
  State<_EmployeeSheet> createState() => _EmployeeSheetState();
}

class _EmployeeSheetState extends State<_EmployeeSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.employees
        : widget.employees.where((e) {
      return '${e.empName}'.toLowerCase().contains(q) ||
          '${e.empCode}'.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.8),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // drag handle
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Select employee',
                            style: TextStyling.section),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.darkGrey,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    cursorColor: AppColors.primary,
                    style: TextStyling.text16.copyWith(color: AppColors.black),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search by name or code',
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 20, color: AppColors.darkGrey),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.cancel_rounded,
                            size: 18, color: AppColors.darkGrey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${filtered.length} employee${filtered.length == 1 ? '' : 's'}',
                      style: TextStyling.caption,
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                // results
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_off_outlined,
                            size: 40, color: AppColors.darkGrey),
                        const SizedBox(height: 8),
                        Text('No employees found',
                            style: TextStyling.caption),
                      ],
                    ),
                  )
                      : ListView.separated(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 72,
                        color: AppColors.border),
                    itemBuilder: (context, i) {
                      final e = filtered[i];
                      final name = '${e.empName}'.trim();
                      final isSelected = widget.selected != null &&
                          '${widget.selected!.empCode}' ==
                              '${e.empCode}';
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.primarySoft,
                          child: Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        title: Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyling.bold14),
                        subtitle: Text('Code: ${e.empCode}',
                            style: TextStyling.caption),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary)
                            : null,
                        onTap: () => Navigator.pop(context, e),
                      );
                    },
                  ),
                ),
                SizedBox(height: media.padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Generic option picker (bottom sheet) – used for "Applying for"
// ─────────────────────────────────────────────────────────────────────────

class _OptionPickerField extends StatefulWidget {
  final String title;
  final String hint;
  final IconData icon;
  final List<String> options;
  final String? currentValue; // model value; empty => selection cleared
  final bool hasError;
  final ValueChanged<String> onSelected;

  const _OptionPickerField({
    required this.title,
    required this.hint,
    required this.options,
    required this.onSelected,
    this.icon = Icons.list_alt_rounded,
    this.currentValue,
    this.hasError = false,
  });

  @override
  State<_OptionPickerField> createState() => _OptionPickerFieldState();
}

class _OptionPickerFieldState extends State<_OptionPickerField> {
  String? _selected;

  @override
  void didUpdateWidget(covariant _OptionPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.currentValue ?? '').isEmpty && _selected != null) {
      _selected = null;
    }
  }

  Future<void> _open() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionSheet(
        title: widget.title,
        options: widget.options,
        selected: _selected,
      ),
    );
    if (picked != null) {
      setState(() => _selected = picked);
      widget.onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _selected;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _open,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: _dropdownDecoration(widget.hasError),
        child: Row(
          children: [
            Icon(widget.icon, size: 20, color: AppColors.darkGrey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                s ?? widget.hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyling.text16.copyWith(
                  color: s == null ? AppColors.darkGrey : AppColors.black,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkGrey),
          ],
        ),
      ),
    );
  }
}

class _OptionSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selected;

  const _OptionSheet({
    required this.title,
    required this.options,
    this.selected,
  });

  @override
  State<_OptionSheet> createState() => _OptionSheetState();
}

class _OptionSheetState extends State<_OptionSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final searchable = widget.options.length > 6;
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.options
        : widget.options.where((o) => o.toLowerCase().contains(q)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.8),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child:
                        Text(widget.title, style: TextStyling.section),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.darkGrey,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                if (searchable)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      cursorColor: AppColors.primary,
                      style: TextStyling.text16
                          .copyWith(color: AppColors.black),
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search',
                        filled: true,
                        fillColor: AppColors.surfaceMuted,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 20, color: AppColors.darkGrey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.2),
                        ),
                      ),
                    ),
                  ),
                const Divider(height: 1, color: AppColors.border),
                Flexible(
                  child: filtered.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No results',
                        style: TextStyling.caption),
                  )
                      : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 16,
                        color: AppColors.border),
                    itemBuilder: (context, i) {
                      final o = filtered[i];
                      final isSelected = o == widget.selected;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 2),
                        title: Text(
                          o,
                          style: TextStyling.bold14.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.black,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary)
                            : null,
                        onTap: () => Navigator.pop(context, o),
                      );
                    },
                  ),
                ),
                SizedBox(height: media.padding.bottom + 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// PASTE THIS CLASS at the bottom of your Apply Loan screen file.
// It uses imports the screen already has (material, AppColors, TextStyling).
// ─────────────────────────────────────────────────────────────────────────

/// Shown in the Employee area while the list loads, or when it could not be
/// loaded (including the server's own message, e.g. "You are not eligible...").
// ─────────────────────────────────────────────────────────────────────────
// PASTE THIS CLASS at the bottom of your Apply Loan screen file
// (replace the earlier _EmployeeStatusBox if you already pasted it).
// It uses imports the screen already has (material, AppColors, TextStyling).
// ─────────────────────────────────────────────────────────────────────────

/// Shown in the Employee area while the list loads, or when it could not be
/// loaded. Only the message is shown (the server's own text, e.g. "You are
/// not eligible to fill a loan form on behalf of another employee.").
class _EmployeeStatusBox extends StatelessWidget {
  final bool isLoading;
  final String? message;

  const _EmployeeStatusBox({
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    // ── loading ──────────────────────────────────────────────────────────
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text('Loading employees...', style: TextStyling.caption),
          ],
        ),
      );
    }

    // ── message from the server (or a generic one if it sent none) ──────
    final text = (message ?? '').trim().isEmpty
        ? 'Please check your connection and try again.'
        : message!.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline_rounded,
                size: 20, color: AppColors.danger),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyling.body
                  .copyWith(color: AppColors.danger, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}