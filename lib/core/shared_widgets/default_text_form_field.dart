import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class DefaultTextFormField extends StatefulWidget {
  final int? maxLength;
  final int? maxLines;
  final bool isEnabled;
  final bool required;
  final bool isPassword;
  final bool isFilled;
  final bool hasBorder;
  final bool autoFocus;
  final bool readOnly;
  final double contentPaddingVertical;
  final double contentPaddingHorizontal;
  final double borderRadius;
  final double borderSideWidth;
  final Color enabledBorderRadiusColor;
  final Color? borderSideColor;
  final Color? borderSideEnabledColor;
  final Color? labelColorActive;
  final String? validationMsg;
  final TextInputType textInputType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function? onPressSuffixIcon;
  final Function(String)? onFilledSubmit;
  final Function(String)? onChange;
  final Function? validation;
  final Function? onTap;
  final String? labelText;
  final String? hintText;
  final TextEditingController controller;
  final Color? fillColor;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final List<TextInputFormatter>? formatter;

  const DefaultTextFormField({
    super.key,
    this.isPassword = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.isFilled = false,
    this.hasBorder = true,
    this.labelColorActive,
    this.required = true,
    this.isEnabled = true,
    this.borderSideWidth = 1.0,
    this.contentPaddingHorizontal = 10.0,
    this.borderSideColor,
    this.contentPaddingVertical = 10.0,
    this.borderRadius = 10,
    this.enabledBorderRadiusColor = DsColor.textMuted,
    this.maxLength,
    this.maxLines,
    this.labelText,
    this.hintText,
    required this.textInputType,
    required this.controller,
    this.onFilledSubmit,
    this.onChange,
    this.borderSideEnabledColor,
    this.onTap,
    this.onPressSuffixIcon,
    this.validation,
    this.suffixIcon,
    this.prefixIcon,
    this.validationMsg,
    this.style,
    this.hintStyle,
    this.fillColor,
    this.formatter,
  });

  @override
  State<DefaultTextFormField> createState() => _DefaultTextFormFieldState();
}

class _DefaultTextFormFieldState extends State<DefaultTextFormField> {
  late FocusNode myFocusNode;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    // myFocusNode.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      style: widget.style,
      readOnly: widget.readOnly,

      obscureText: widget.isPassword && hidePassword,
      focusNode: myFocusNode,
      autofocus: widget.autoFocus,
      enabled: widget.isEnabled,
      obscuringCharacter: '●',
      controller: widget.controller,
      keyboardType: widget.textInputType,
      inputFormatters: widget.formatter,
      onFieldSubmitted: (value) {
        if (widget.onFilledSubmit != null) {
          widget.onFilledSubmit!(value);
        }
      },
      onChanged: (value) {
        if (widget.onChange != null) {
          widget.onChange!(value);
        }
      },
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      validator: (String? value) {
        if (widget.validation != null) {
          return widget.validation!(value);
        } else if (value!.isEmpty && widget.required) {
          return widget.validationMsg ?? "filed_required".tr();
        } else {
          return null;
        }
      },
      // Design-system field: white, 1px line, brand outline on focus, 12 radius, ~52dp tall.
      // A screen's explicit colours are kept; the old beige/grey defaults are replaced.
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: widget.contentPaddingVertical > 15 ? widget.contentPaddingVertical : 15,
          horizontal: widget.contentPaddingHorizontal < DsSpace.lg ? DsSpace.lg : widget.contentPaddingHorizontal,
        ),
        border: _border(widget.borderSideEnabledColor ?? DsColor.border),
        enabledBorder: _border(widget.borderSideEnabledColor ?? DsColor.border),
        disabledBorder: _border(DsColor.divider),
        focusedBorder: _border(widget.borderSideColor ?? DsColor.primary, 1.5),
        errorBorder: _border(DsColor.danger),
        focusedErrorBorder: _border(DsColor.danger, 1.5),
        errorStyle: DsText.caption.copyWith(color: DsColor.danger),
        filled: true,
        fillColor: widget.isEnabled ? (_legacyFill(widget.fillColor) ? (widget.hasBorder ? DsColor.surface : DsColor.fill) : widget.fillColor ?? DsColor.surface) : DsColor.fill,
        prefixIcon: widget.prefixIcon,
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle ?? DsText.body.copyWith(color: DsColor.textSubtle),
        errorMaxLines: 2,
        labelStyle: DsText.body.copyWith(color: myFocusNode.hasFocus ? (widget.labelColorActive ?? DsColor.primary) : (widget.labelColorActive ?? DsColor.textMuted)),
        suffixIcon:
            widget.suffixIcon ??
            (widget.isPassword
                ? InkWell(
                    onTap: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    child: Icon(hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: DsColor.textMuted),
                  )
                : null),
      ),
    );
  }

  /// Old screens pass light greys/beiges as "filled" backgrounds; fields are white now.
  static bool _legacyFill(Color? c) => c == null || c.a == 0 || const [0xffF7F7F8, 0xffF5F5F5, 0xffF6F8FE, 0xffFAFAFA, 0xffF3F4F6, 0xffF7F9FA].contains(c.toARGB32());

  OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(DsRadius.md),
        borderSide: widget.hasBorder ? BorderSide(color: color, width: width) : BorderSide.none,
      );

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }
}
