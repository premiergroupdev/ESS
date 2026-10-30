import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

/// Shared implementation behind [MainInputField] and [SecondInputField].
///
/// Validation rules are identical to the previous version. What changed:
///  * filled, rounded field with a visible focus ring
///  * the `hint` argument is now actually shown (it was accepted but ignored)
///  * validation text renders under the field instead of being clipped by a
///    fixed-height container
///  * a tall `height` (e.g. 200 on Apply Visit) becomes a multi-line field
class _AppTextField extends StatelessWidget {
  final bool isPassword;
  final String? label;
  final String hint;
  final TextEditingController controller;
  final Function? onTap;
  final TextInputType? inputType;
  final ValueChanged<String>? onChanged;
  final bool isRequired;
  final bool? readOnly;
  final String message;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? width;
  final double? height;
  final bool phoneMask;

  const _AppTextField({
    required this.isPassword,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onTap,
    required this.inputType,
    required this.onChanged,
    required this.isRequired,
    required this.readOnly,
    required this.message,
    required this.suffixIcon,
    required this.prefixIcon,
    required this.width,
    required this.height,
    required this.phoneMask,
  });

  String? _validate(String? val) {
    bool emailValid = true;
    if (inputType == TextInputType.emailAddress) {
      emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(val!);
    }
    return isRequired
        ? (val!.isEmpty || (emailValid == false))
        ? message
        : null
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly =
    (inputType == TextInputType.datetime) ? true : readOnly ?? false;

    final bool multiline = !isPassword && height != null && height! > 90;
    final int minLines =
    multiline ? ((height! - 28) / 22).floor().clamp(3, 10).toInt() : 1;

    final field = TextFormField(
      onTap: onTap != null ? () => onTap!() : null,
      textInputAction:
      multiline ? TextInputAction.newline : TextInputAction.next,
      keyboardType: multiline
          ? TextInputType.multiline
          : (inputType ?? TextInputType.text),
      validator: _validate,
      onChanged: onChanged,
      inputFormatters: <TextInputFormatter>[
        if (phoneMask && inputType == TextInputType.phone)
          MaskedInputFormatter('####-###-####'),
      ],
      controller: controller,
      readOnly: isReadOnly,
      obscureText: isPassword,
      minLines: minLines,
      maxLines: isPassword ? 1 : (multiline ? null : 1),
      cursorColor: AppColors.primary,
      style: TextStyling.text16.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintMaxLines: 1,
        filled: true,
        fillColor: isReadOnly && onTap == null
            ? AppColors.surfaceMuted
            : AppColors.surface,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        alignLabelWithHint: multiline,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );

    return SizedBox(
      width: width ?? double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!, style: TextStyling.label),
            const SizedBox(height: 8),
          ],
          field,
        ],
      ),
    );
  }
}

/// Standard text field. Signature unchanged.
class MainInputField extends StatelessWidget {
  final bool isPassword;
  final String? label;
  final String hint;
  final TextEditingController controller;
  final Function? onTap;
  final TextInputType? inputType;
  final ValueChanged<String>? onChanged;
  final bool isRequired;
  final bool? readOnly;
  final String message;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? width;
  final double? height;

  const MainInputField(
      {Key? key,
        this.width,
        this.height,
        this.isPassword = false,
        this.label,
        required this.hint,
        required this.controller,
        this.onTap,
        this.inputType,
        this.onChanged,
        this.isRequired = true,
        this.suffixIcon,
        this.prefixIcon,
        required this.message,
        this.readOnly})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AppTextField(
      isPassword: isPassword,
      label: label,
      hint: hint,
      controller: controller,
      onTap: onTap,
      inputType: inputType,
      onChanged: onChanged,
      isRequired: isRequired,
      readOnly: readOnly,
      message: message,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      width: width,
      height: height,
      phoneMask: false,
    );
  }
}

/// Same field, with the phone mask used by the forms. Signature unchanged.
class SecondInputField extends StatelessWidget {
  final bool isPassword;
  final String? label;
  final String hint;
  final TextEditingController controller;
  final Function? onTap;
  final TextInputType? inputType;
  final ValueChanged<String>? onChanged;
  final bool isRequired;
  final bool? readOnly;
  final String message;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? width;
  final double? height;

  const SecondInputField({
    Key? key,
    this.width,
    this.height,
    this.isPassword = false,
    this.label,
    required this.hint,
    required this.controller,
    this.onTap,
    this.inputType,
    this.onChanged,
    this.isRequired = true,
    this.suffixIcon,
    this.prefixIcon,
    required this.message,
    this.readOnly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AppTextField(
      isPassword: isPassword,
      label: label,
      hint: hint,
      controller: controller,
      onTap: onTap,
      inputType: inputType,
      onChanged: onChanged,
      isRequired: isRequired,
      readOnly: readOnly,
      message: message,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      width: width,
      height: height,
      phoneMask: true,
    );
  }
}

/// Dropdown styled to match the text fields. Signature unchanged.
/// (The arrow used to be transparent; it is visible now.)
class CustomDropDown extends StatelessWidget {
  final String? label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  const CustomDropDown(
      {Key? key,
        this.label,
        required this.value,
        required this.items,
        required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: TextStyling.label),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              borderRadius: BorderRadius.circular(14),
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary),
              style: TextStyling.text16.copyWith(color: AppColors.black),
              items: items,
              onChanged: (String? newValue) {
                onChanged(newValue);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class customDropDown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  customDropDown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        borderRadius: BorderRadius.circular(14),
        dropdownColor: AppColors.surface,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary),
        style: TextStyling.text14.copyWith(color: AppColors.black),
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}