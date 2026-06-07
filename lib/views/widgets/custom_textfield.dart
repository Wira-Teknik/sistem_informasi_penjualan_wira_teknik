import 'package:flutter/material.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/text_constant.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextfield({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.textCapitalization,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) Text(widget.label!, style: semiBoldTextStyle),
        const SizedBox(height: 8),
        TextFormField(
          onTap: widget.onTap,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          controller: widget.controller,
          obscureText: _isObscured,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: mediumTextStyle,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: regularTextStyle.copyWith(
              color: semiSecondaryColor.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: whiteColor,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: semiSecondaryColor.withValues(alpha: 0.5),
                  )
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: semiSecondaryColor.withValues(alpha: 0.5),
                    ),
                    onPressed: _toggleObscure,
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: semiSecondaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: primaryColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.red.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
