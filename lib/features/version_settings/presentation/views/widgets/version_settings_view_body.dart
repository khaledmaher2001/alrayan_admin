import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/get_settings/get_settings_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/update_settings/update_settings_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/update_settings/update_settings_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../coupons/presentation/views/widgets/custom_coupon_field.dart';

class VersionSettingsViewBody extends StatefulWidget {
  const VersionSettingsViewBody({super.key});

  @override
  State<VersionSettingsViewBody> createState() =>
      _VersionSettingsViewBodyState();
}

class _VersionSettingsViewBodyState extends State<VersionSettingsViewBody> {
  final androidVersionController = TextEditingController();
  final androidEndDateController = TextEditingController();
  final androidUrlController = TextEditingController();
  final iosVersionController = TextEditingController();
  final iosEndDateController = TextEditingController();
  final iosUrlController = TextEditingController();

  DateTime? selectedAndroidDate;
  DateTime? selectedIosDate;

  // فلاج يمنع إعادة تهيئة الكنترولرز في كل إعادة بناء
  bool _initialized = false;

  @override
  void dispose() {
    androidVersionController.dispose();
    androidEndDateController.dispose();
    androidUrlController.dispose();
    iosVersionController.dispose();
    iosEndDateController.dispose();
    iosUrlController.dispose();
    super.dispose();
  }

  // للصيغة التي تُعرض في الحقول: "yyyy-MM-dd"
  String _formatDateOnly(DateTime dt) {
    return DateFormat("yyyy-MM-dd").format(dt);
  }

  // للصيغة التي تُرسل للـ API: "yyyy-MM-ddTHH:mm:00.000"
  String _dateTimeToIsoString(DateTime dt) {
    final datePart = DateFormat("yyyy-MM-dd", "en").format(dt);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return "${datePart}T${hour}:${minute}:00.000";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height20(context)),
          CustomAppBar(
            title: "أعدادات النسخة",
            textColor: Colors.black,
            hasBack: true,
            withNotifications: false,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: BlocBuilder<GetSettingsCubit, GetSettingsState>(
              builder: (context, state) {
                if (state is GetSettingsSuccessState) {
                  // --- فقط املأ الكنترولرز و selectedDates لمرة واحدة عند الاستلام الأول ---
                  if (!_initialized) {
                    // نملأ الكنترولرز بصيغة العرض (yyyy-MM-dd) إن أمكن
                    androidUrlController.text =
                        state.settingsModel.androidLink ?? "";
                    androidVersionController.text =
                        state.settingsModel.androidVersion ?? "";

                    if (state.settingsModel.androidEndDate != null &&
                        state.settingsModel.androidEndDate!.isNotEmpty) {
                      final parsedAndroid =
                      DateTime.tryParse(state.settingsModel.androidEndDate!);
                      if (parsedAndroid != null) {
                        selectedAndroidDate = parsedAndroid;
                        androidEndDateController.text =
                            _formatDateOnly(parsedAndroid);
                      } else {
                        // لو ما قدرنا نعمل parse، نعكس النص كما هو (أو تقدر تفرمت)
                        androidEndDateController.text =
                            state.settingsModel.androidEndDate ?? "";
                      }
                    }

                    iosUrlController.text = state.settingsModel.iosLink ?? "";
                    iosVersionController.text = state.settingsModel.iosVersion ?? "";

                    if (state.settingsModel.iosEndDate != null &&
                        state.settingsModel.iosEndDate!.isNotEmpty) {
                      final parsedIos =
                      DateTime.tryParse(state.settingsModel.iosEndDate!);
                      if (parsedIos != null) {
                        selectedIosDate = parsedIos;
                        iosEndDateController.text = _formatDateOnly(parsedIos);
                      } else {
                        iosEndDateController.text =
                            state.settingsModel.iosEndDate ?? "";
                      }
                    }

                    _initialized = true; // منع إعادة التعيين مرة أخرى
                  }
                  // --------------------------------------------------------------------

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width20(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "اعدادات نسخة الاندرويد",
                            style: Styles.inter16500black(context),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: AppConstants.height10(context),
                            ),
                            width: MediaQuery.of(context).size.width * .3,
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppConstants.sp30(context),
                              ),
                              color: AppColors.primaryColor.shade500,
                            ),
                          ),
                          SizedBox(height: AppConstants.height10(context)),
                          CustomCouponField(
                            title: "رقم النسخة الحالية",
                            hint: "رقم النسخة الحالية",
                            controller: androidVersionController,
                            keyboardType: TextInputType.number,
                            validationText: "من فضلك ادخل رقم النسخة الحالية",
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          CustomCouponField(
                            title: "اللينك الخاص بتحديث نسخة الاندرويد",
                            hint: "اللينك الخاص بتحديث نسخة الاندرويد",
                            controller: androidUrlController,
                            keyboardType: TextInputType.url,
                            validationText:
                            "من فضلك ادخل اللينك الخاص بتحديث نسخة الاندرويد",
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          CustomCouponField(
                            title: "اقصي موعد لتجديد نسخة الاندرويد",
                            hint: "اقصي موعد لتجديد نسخة الاندرويد",
                            readOnly: true,
                            controller: androidEndDateController,
                            keyboardType: TextInputType.number,
                            validationText: "يجب ادخال هذا الحقل",
                            onTap: () async {
                              // افتح اختيار التاريخ فقط
                              final DateTime initialDate =
                                  selectedAndroidDate ?? DateTime.now();
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(3000),
                              );
                              if (picked != null) {
                                // خزن التاريخ عند منتصف الليل (00:00) داخليًا
                                selectedAndroidDate = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  0,
                                  0,
                                );

                                // عرض التاريخ في الكنترولر بصيغة "yyyy-MM-dd"
                                androidEndDateController.text =
                                    _formatDateOnly(selectedAndroidDate!);

                                // إعادة بناء الواجهة لإظهار التغيير
                                setState(() {});
                              }
                            },
                          ),
                          SizedBox(height: AppConstants.height20(context)),

                          Text(
                            "اعدادات نسخة الايفون",
                            style: Styles.inter16500black(context),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: AppConstants.height10(context),
                            ),
                            width: MediaQuery.of(context).size.width * .3,
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppConstants.sp30(context),
                              ),
                              color: AppColors.primaryColor.shade500,
                            ),
                          ),
                          SizedBox(height: AppConstants.height10(context)),
                          CustomCouponField(
                            title: "رقم النسخة الحالية",
                            hint: "رقم النسخة الحالية",
                            controller: iosVersionController,
                            keyboardType: TextInputType.number,
                            validationText: "من فضلك ادخل رقم النسخة الحالية",
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          CustomCouponField(
                            title: "اللينك الخاص بتحديث نسخة الايفون",
                            hint: "اللينك الخاص بتحديث نسخة الايفون",
                            controller: iosUrlController,
                            keyboardType: TextInputType.url,
                            validationText:
                            "من فضلك ادخل اللينك الخاص بتحديث نسخة الايفون",
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          CustomCouponField(
                            title: "اقصي موعد لتجديد نسخة الايفون",
                            hint: "اقصي موعد لتجديد نسخة الايفون",
                            readOnly: true,
                            controller: iosEndDateController,
                            keyboardType: TextInputType.number,
                            validationText: "يجب ادخال هذا الحقل",
                            onTap: () async {
                              // افتح اختيار التاريخ فقط
                              final DateTime initialDate =
                                  selectedIosDate ?? DateTime.now();
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(3000),
                              );
                              if (picked != null) {
                                // خزن التاريخ عند منتصف الليل (00:00) داخليًا
                                selectedIosDate = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  0,
                                  0,
                                );

                                // عرض التاريخ في الكنترولر بصيغة "yyyy-MM-dd"
                                iosEndDateController.text =
                                    _formatDateOnly(selectedIosDate!);

                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child: BlocConsumer<UpdateSettingsCubit, UpdateSettingsStates>(
              builder: (context, state) {
                return DefaultButton(
                  onPress: state is UpdateSettingsLoadingState
                      ? null
                      : () {
                    context.read<UpdateSettingsCubit>().userUpdateSettings(
                      data: {
                        "androidVersion":
                        androidVersionController.text.trim(),
                        // عند الإرسال نستخدم ISO string (مع وقت منتصف الليل داخلياً)
                        "androidEndDate": selectedAndroidDate != null
                            ? _dateTimeToIsoString(selectedAndroidDate!)
                            : "",
                        "androidUrl": androidUrlController.text.trim(),
                        "iosVersion": iosVersionController.text.trim(),
                        "iosEndDate": selectedIosDate != null
                            ? _dateTimeToIsoString(selectedIosDate!)
                            : "",
                        "iosUrl": iosUrlController.text.trim(),
                      },
                    );
                  },
                  icon: state is UpdateSettingsLoadingState
                      ? SizedBox(
                    width: AppConstants.sp20(context),
                    height: AppConstants.sp20(context),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : null,
                  backgroundColor: state is UpdateSettingsLoadingState
                      ? AppColors.primaryColor.shade500
                      : AppColors.primaryColor,
                  text: state is UpdateSettingsLoadingState ? "" : "تحديث البيانات",
                  borderRadius: AppConstants.sp10(context),
                );
              },
              listener: (BuildContext context, UpdateSettingsStates state) {
                if (state is UpdateSettingsSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("تم تحديث البيانات بنجاح"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.read<GetSettingsCubit>().getSettings();
                } else if (state is UpdateSettingsErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
