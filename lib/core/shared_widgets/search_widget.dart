import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/constants.dart';
import '../utils/text_styles/styles.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
    this.icon,
    this.onSearch,
    required this.hint,
    this.searchController,
    this.readOnly = false,
    this.onTap,
  });

  final Widget? icon;
  final String hint;
  final TextEditingController? searchController;
  final Function(String)? onSearch;
  final Function()? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return DefaultTextFormField(
      textInputType: TextInputType.text,
      borderSideEnabledColor: const Color(0xffD6D6D6),
      contentPaddingVertical: AppConstants.height15(context),
      hintText: hint,
      onFilledSubmit: onSearch,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: 1,
      hasBorder: false,
      hintStyle: Styles.inter14600gray(
        context,
      ).copyWith(color: const Color(0xff6C6D6E), fontWeight: FontWeight.w500),
      borderSideColor: const Color(0xffD6D6D6),
      fillColor: const Color(0xffF5F5F5),
      controller: searchController!,
      borderRadius: AppConstants.sp10(context),
      suffixIcon: icon,
      prefixIcon: SvgPicture.asset(
        AssetData.search,
        fit: BoxFit.scaleDown,
        color: const Color(0xff6C6D6E),
      ),
    );
  }
}
