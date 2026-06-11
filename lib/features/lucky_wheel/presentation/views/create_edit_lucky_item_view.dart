import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_dropdown_formfield.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/create_coupon_assets/create_coupon_assets_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_category_bottom_sheet.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/select_product_bottom_sheet.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/models/lucky_wheel_model.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/repo/lucky_wheel_repo_impl.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/create_coupon/create_coupon_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/create_coupon/create_coupon_states.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/edit_lucky_item/edit_lucky_item_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/get_lucky_wheel_items/get_lucky_wheel_items_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateEditLuckyItemView extends StatefulWidget {
  const CreateEditLuckyItemView({
    super.key,
    this.existingItem,
    required this.usedProbability,
    this.autoFillProbability = false,
  });

  /// null → create mode, non-null → edit mode
  final Rewards? existingItem;

  /// sum of all other items' probabilities (0.0–1.0)
  final double usedProbability;

  /// when true (last available slot), pre-fills probability with remaining %
  final bool autoFillProbability;

  @override
  State<CreateEditLuckyItemView> createState() => _CreateEditLuckyItemViewState();
}

class _CreateEditLuckyItemViewState extends State<CreateEditLuckyItemView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayText;
  late final TextEditingController _couponCode;
  late final TextEditingController _discountValue;
  late final TextEditingController _description;
  late final TextEditingController _minOrderAmount;
  late final TextEditingController _expiresAt;
  late final TextEditingController _probability;

  /// type field: no_reward | free_shipping | discount_coupon | discount_product
  String? _rewardType;

  /// discountType field: percentage | fixed_amount | product_specific | category_specific
  String? _discountType;

  /// productId field — single id for discount_product, product_specific, category_specific
  int? _selectedProductId;
  String? _selectedItemName;

  bool _isActive = true;

  bool get _isEditMode => widget.existingItem != null;

  bool get _isCoupon => _rewardType == 'كوبون خصم';

  /// discount_coupon and discount_product both require discountType + discountValue
  bool get _needsDiscountFields =>
      _isCoupon || _rewardType == 'خصم على منتج';

  /// product_specific / category_specific: product picker needed (coupon only)
  /// discount_product: always needs productId
  bool get _needsProductId =>
      _rewardType == 'خصم على منتج' ||
      (_isCoupon &&
          (_discountType == 'خصم على منتج' || _discountType == 'خصم على قسم'));

  /// for discount_product, only percentage/fixed_amount make sense
  List<String> get _discountTypeOptions =>
      _rewardType == 'خصم على منتج'
          ? ['نسبة مئوية', 'نسبة ثابتة']
          : _discountTypeLabels.keys.toList();

  static const _rewardTypeLabels = <String, String>{
    'بدون جائزة': 'no_reward',
    'شحن مجاني': 'free_shipping',
    'كوبون خصم': 'discount_coupon',
    'خصم على منتج': 'discount_product',
  };

  static const _discountTypeLabels = <String, String>{
    'نسبة مئوية': 'percentage',
    'نسبة ثابتة': 'fixed_amount',
    'خصم على منتج': 'product_specific',
    'خصم على قسم': 'category_specific',
  };

  static String _apiToRewardLabel(String? api) => _rewardTypeLabels.entries
      .firstWhere((e) => e.value == api, orElse: () => const MapEntry('', ''))
      .key;

  static String _apiToDiscountLabel(String? api) => _discountTypeLabels.entries
      .firstWhere((e) => e.value == api, orElse: () => const MapEntry('', ''))
      .key;

  String _rewardTypeForApi() => _rewardTypeLabels[_rewardType] ?? 'no_reward';
  String _discountTypeForApi() => _discountTypeLabels[_discountType] ?? '';

  double get _remainingPercent =>
      (1.0 - widget.usedProbability).clamp(0.0, 1.0) * 100;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _displayText = TextEditingController(text: item?.displayText ?? '');
    _couponCode = TextEditingController(text: item?.couponCode ?? '');
    _discountValue = TextEditingController(
      text: item?.discountValue != null ? item!.discountValue.toString() : '',
    );
    _description = TextEditingController(text: item?.description ?? '');
    _minOrderAmount = TextEditingController(
      text: item?.minOrderAmount != null ? item!.minOrderAmount.toString() : '',
    );

    String expiresAtText = '';
    if (item?.expiresAt != null) {
      try {
        final dt = DateTime.parse(item!.expiresAt!);
        expiresAtText =
            '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {}
    }
    _expiresAt = TextEditingController(text: expiresAtText);

    final probValue = item?.probability;
    final probDouble = probValue is num ? probValue.toDouble() * 100 : 0.0;
    final remainingForInit = (1.0 - widget.usedProbability).clamp(0.0, 1.0) * 100;
    _probability = TextEditingController(
      text: _isEditMode
          ? probDouble.toStringAsFixed(0)
          : (widget.autoFillProbability
              ? remainingForInit.toStringAsFixed(1)
              : ''),
    );

    if (_isEditMode) {
      final rLabel = _apiToRewardLabel(item?.type);
      _rewardType = rLabel.isEmpty ? null : rLabel;
      final dLabel = _apiToDiscountLabel(item?.discountType);
      _discountType = dLabel.isEmpty ? null : dLabel;
      _selectedProductId = item?.productId;
      _isActive = item?.isActive ?? true;

      if (_selectedProductId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_discountType == 'خصم على قسم') {
            final categories =
                context.read<GetCategoriesCubit>().categoriesModel?.data ?? [];
            final cat = categories.where((c) => c.id == _selectedProductId).firstOrNull;
            if (cat != null && mounted) setState(() => _selectedItemName = cat.name?.ar);
          } else {
            final products = context.read<GetProductsCubit>().productsList;
            final prod = products.where((p) => p.id == _selectedProductId).firstOrNull;
            if (prod != null && mounted) setState(() => _selectedItemName = prod.name?.ar);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _displayText.dispose();
    _couponCode.dispose();
    _discountValue.dispose();
    _description.dispose();
    _minOrderAmount.dispose();
    _expiresAt.dispose();
    _probability.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      _expiresAt.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _openProductPicker(BuildContext context) {
    final cubit = context.read<CreateCouponAssetsCubit>();
    cubit.selectedProducts.clear();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      useSafeArea: true,
      builder: (_) => const SelectProductBottomSheet(),
    ).then((_) {
      if (!mounted) return;
      if (cubit.selectedProducts.isNotEmpty) {
        setState(() {
          _selectedProductId = cubit.selectedProducts.first.id;
          _selectedItemName = cubit.selectedProducts.first.name?.ar;
        });
        cubit.selectedProducts.clear();
      }
    });
  }

  void _openCategoryPicker(BuildContext context) {
    final cubit = context.read<CreateCouponAssetsCubit>();
    cubit.selectedCategories.clear();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      useSafeArea: true,
      builder: (_) => const SelectCategoriesBottomSheet(),
    ).then((_) {
      if (!mounted) return;
      if (cubit.selectedCategories.isNotEmpty) {
        setState(() {
          _selectedProductId = cubit.selectedCategories.first.id;
          _selectedItemName = cubit.selectedCategories.first.name?.ar;
        });
        cubit.selectedCategories.clear();
      }
    });
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_rewardType == null) {
      cherryToast(context: context, text: 'يجب اختيار نوع الجائزة', isSuccess: false);
      return;
    }

    if (_needsProductId && _selectedProductId == null) {
      cherryToast(
        context: context,
        text: _discountType == 'خصم على قسم' ? 'يجب اختيار قسم' : 'يجب اختيار منتج',
        isSuccess: false,
      );
      return;
    }

    final probPercent = double.tryParse(_probability.text.trim()) ?? 0;
    final probFraction = probPercent / 100;

    if (widget.usedProbability + probFraction > 1.001) {
      cherryToast(
        context: context,
        text: 'مجموع الاحتمالية يتجاوز 100%، المتبقي: ${_remainingPercent.toStringAsFixed(1)}%',
        isSuccess: false,
      );
      return;
    }

    final data = <String, dynamic>{
      'type': _rewardTypeForApi(),
      'displayText': _displayText.text.trim(),
      'probability': probFraction,
      'isActive': _isActive,
      if (_needsDiscountFields) 'couponCode': _couponCode.text.trim(),
      if (_needsDiscountFields) ...{
        'discountType': _discountTypeForApi(),
        'discountValue': double.tryParse(_discountValue.text.trim()) ?? 0,
      },
      if (_description.text.trim().isNotEmpty) 'description': _description.text.trim(),
      if (_minOrderAmount.text.trim().isNotEmpty)
        'minOrderAmount': double.tryParse(_minOrderAmount.text.trim()) ?? 0,
      if (_expiresAt.text.trim().isNotEmpty)
        'expiresAt': '${_expiresAt.text.trim()}T00:00:00.000Z',
      if (_selectedProductId != null) 'productId': _selectedProductId,
    };

    if (_isEditMode) {
      context.read<EditLuckyItemCubit>().editLuckyItem(
            itemId: widget.existingItem!.id!,
            data: data,
          );
    } else {
      context.read<CreateLuckyItemCubit>().createLuckyItem(data: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CreateLuckyItemCubit(getIt.get<LuckyWheelRepoImpl>())),
        BlocProvider(create: (_) => EditLuckyItemCubit(getIt.get<LuckyWheelRepoImpl>())),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
            child: Column(
              children: [
                SizedBox(height: AppConstants.height10(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomBackButton(),
                    Text(
                      _isEditMode ? 'تعديل الجائزة' : 'إضافة جائزة',
                      style: Styles.inter18500Black(context),
                    ),
                    SizedBox(width: AppConstants.width20(context) * 2),
                  ],
                ),
                SizedBox(height: AppConstants.height10(context)),
                _ProbabilityIndicator(remainingPercent: _remainingPercent),
                SizedBox(height: AppConstants.height15(context)),
                Expanded(
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<CreateLuckyItemCubit, CreateLuckyItemStates>(
                        listener: (context, state) {
                          if (state is CreateLuckyItemSuccessState) {
                            cherryToast(context: context, text: state.message);
                            context
                                .read<GetLuckyWheelItemsCubit>()
                                .getLuckyWheelItems(withLoading: false);
                            NavigationUtils.navigateBack(context: context);
                          } else if (state is CreateLuckyItemErrorState) {
                            cherryToast(
                                context: context, text: state.error, isSuccess: false);
                          }
                        },
                      ),
                      BlocListener<EditLuckyItemCubit, EditLuckyItemState>(
                        listener: (context, state) {
                          if (state is EditLuckyItemSuccessState) {
                            cherryToast(context: context, text: state.message);
                            context
                                .read<GetLuckyWheelItemsCubit>()
                                .getLuckyWheelItems(withLoading: false);
                            NavigationUtils.navigateBack(context: context);
                          } else if (state is EditLuckyItemErrorState) {
                            cherryToast(
                                context: context, text: state.error, isSuccess: false);
                          }
                        },
                      ),
                    ],
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          // ── نوع الجائزة ──────────────────────────────
                          _FieldLabel(text: 'نوع الجائزة'),
                          SizedBox(height: AppConstants.height5(context)),
                          CustomDropDownButton(
                            hintText: 'اختر نوع الجائزة',
                            value: _rewardType,
                            items: _rewardTypeLabels.keys.toList(),
                            onChanged: (v) => setState(() {
                              _rewardType = v;
                              _discountType = null;
                              _selectedProductId = null;
                              _selectedItemName = null;
                            }),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'يجب اختيار نوع الجائزة' : null,
                          ),
                          SizedBox(height: AppConstants.height15(context)),

                          // ── النص المعروض ──────────────────────────────
                          _FieldLabel(text: 'النص المعروض على العجلة'),
                          SizedBox(height: AppConstants.height5(context)),
                          DefaultTextFormField(
                            textInputType: TextInputType.text,
                            controller: _displayText,
                            hintText: 'مثال: خصم 20%',
                            validationMsg: 'يجب إدخال النص المعروض',
                          ),
                          SizedBox(height: AppConstants.height15(context)),

                          // ── كود الكوبون + نوع الخصم + قيمته (لأي نوع خصم) ──
                          if (_needsDiscountFields) ...[
                            _FieldLabel(text: 'كود الكوبون'),
                            SizedBox(height: AppConstants.height5(context)),
                            DefaultTextFormField(
                              textInputType: TextInputType.text,
                              controller: _couponCode,
                              hintText: 'مثال: LUCKY20',
                              validationMsg: 'يجب إدخال كود الكوبون',
                            ),
                            SizedBox(height: AppConstants.height15(context)),
                          ],

                          if (_needsDiscountFields) ...[
                            _FieldLabel(text: 'نوع الخصم'),
                            SizedBox(height: AppConstants.height5(context)),
                            CustomDropDownButton(
                              hintText: 'اختر نوع الخصم',
                              value: _discountType,
                              items: _discountTypeOptions,
                              onChanged: (v) => setState(() {
                                _discountType = v;
                                _selectedProductId = null;
                                _selectedItemName = null;
                              }),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'يجب اختيار نوع الخصم' : null,
                            ),
                            SizedBox(height: AppConstants.height15(context)),

                            _FieldLabel(text: 'قيمة الخصم'),
                            SizedBox(height: AppConstants.height5(context)),
                            DefaultTextFormField(
                              textInputType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              controller: _discountValue,
                              hintText: '0',
                              validation: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'يجب إدخال قيمة الخصم';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: AppConstants.height15(context)),
                          ],

                          // ── اختيار منتج / قسم (single select) ──────────
                          if (_needsProductId) ...[
                            _FieldLabel(
                              text: _discountType == 'خصم على قسم'
                                  ? 'اختر قسم'
                                  : 'اختر منتج',
                            ),
                            SizedBox(height: AppConstants.height5(context)),
                            _SinglePickerField(
                              selectedName: _selectedItemName,
                              hint: _discountType == 'خصم على قسم'
                                  ? 'اضغط لاختيار قسم'
                                  : 'اضغط لاختيار منتج',
                              onTap: () => _discountType == 'خصم على قسم'
                                  ? _openCategoryPicker(context)
                                  : _openProductPicker(context),
                              onClear: () => setState(() {
                                _selectedProductId = null;
                                _selectedItemName = null;
                              }),
                            ),
                            SizedBox(height: AppConstants.height15(context)),
                          ],

                          // ── الوصف ──────────────────────────────────────
                          _FieldLabel(text: 'الوصف'),
                          SizedBox(height: AppConstants.height5(context)),
                          DefaultTextFormField(
                            textInputType: TextInputType.text,
                            controller: _description,
                            hintText: 'وصف الجائزة',
                            maxLines: 2,
                            validation: (_) => null,
                          ),
                          SizedBox(height: AppConstants.height15(context)),

                          // ── أقل قيمة للطلب + تاريخ الانتهاء ───────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: 'أقل قيمة للطلب'),
                                    SizedBox(height: AppConstants.height5(context)),
                                    DefaultTextFormField(
                                      textInputType: TextInputType.number,
                                      controller: _minOrderAmount,
                                      hintText: '0',
                                      validation: (_) => null,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: AppConstants.width10(context)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: 'تاريخ الانتهاء'),
                                    SizedBox(height: AppConstants.height5(context)),
                                    DefaultTextFormField(
                                      textInputType: TextInputType.none,
                                      controller: _expiresAt,
                                      hintText: 'yyyy-MM-dd',
                                      readOnly: true,
                                      suffixIcon: const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 18),
                                      onTap: _pickDate,
                                      validation: (_) => null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.height15(context)),

                          // ── نسبة الظهور ────────────────────────────────
                          _FieldLabel(
                            text: 'نسبة الظهور',
                            hint: 'المتبقي: ${_remainingPercent.toStringAsFixed(1)}%',
                          ),
                          SizedBox(height: AppConstants.height5(context)),
                          DefaultTextFormField(
                            textInputType:
                                const TextInputType.numberWithOptions(decimal: true),
                            controller: _probability,
                            hintText: 'من 0 إلى ${_remainingPercent.toStringAsFixed(1)}',
                            suffixIcon: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: AppConstants.sp5(context) * 2),
                              child: Text(
                                '%',
                                style: Styles.inter14500black(context)
                                    .copyWith(color: Colors.grey),
                              ),
                            ),
                            formatter: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                            ],
                            validation: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'يجب إدخال نسبة الظهور';
                              }
                              final val = double.tryParse(v.trim());
                              if (val == null || val <= 0) {
                                return 'يجب أن تكون النسبة أكبر من 0';
                              }
                              if (val > _remainingPercent + 0.01) {
                                return 'النسبة تتجاوز المتبقي (${_remainingPercent.toStringAsFixed(1)}%)';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppConstants.height15(context)),

                          // ── تفعيل الجائزة ──────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('تفعيل الجائزة',
                                  style: Styles.inter16500black(context)),
                              Switch(
                                value: _isActive,
                                onChanged: (v) => setState(() => _isActive = v),
                                activeThumbColor: Colors.white,
                                activeTrackColor: AppColors.primaryColor,
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.height20(context)),

                          // ── زر الحفظ ───────────────────────────────────
                          BlocBuilder<CreateLuckyItemCubit, CreateLuckyItemStates>(
                            builder: (context, createState) {
                              return BlocBuilder<EditLuckyItemCubit, EditLuckyItemState>(
                                builder: (context, editState) {
                                  final isLoading =
                                      createState is CreateLuckyItemLoadingState ||
                                          editState is EditLuckyItemLoadingState;
                                  return isLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : DefaultButton(
                                          onPress: () => _submit(context),
                                          text: _isEditMode ? 'تعديل' : 'إضافة',
                                          borderRadius: AppConstants.sp10(context),
                                        );
                                },
                              );
                            },
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.hint});
  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: Styles.inter14500black(context)),
        if (hint != null) ...[
          const Spacer(),
          Text(
            hint!,
            style: Styles.inter14500black(context)
                .copyWith(color: AppColors.primaryColor),
          ),
        ],
      ],
    );
  }
}

class _ProbabilityIndicator extends StatelessWidget {
  const _ProbabilityIndicator({required this.remainingPercent});
  final double remainingPercent;

  @override
  Widget build(BuildContext context) {
    final usedPercent = 100 - remainingPercent;
    final isOver = usedPercent > 100.01;
    final color = isOver
        ? Colors.red
        : remainingPercent < 10
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: EdgeInsets.all(AppConstants.sp10(context)),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الاحتمالية المستخدمة', style: Styles.inter14500black(context)),
              Text(
                '${usedPercent.toStringAsFixed(1)}% / 100%',
                style: Styles.inter14500black(context)
                    .copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height5(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (usedPercent / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(height: AppConstants.height5(context)),
          Text(
            'المتبقي: ${remainingPercent.toStringAsFixed(1)}%',
            style: Styles.inter14500black(context).copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SinglePickerField extends StatelessWidget {
  const _SinglePickerField({
    required this.hint,
    required this.onTap,
    required this.onClear,
    this.selectedName,
  });

  final String? selectedName;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (selectedName != null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height10(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withAlpha(15),
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: AppColors.primaryColor.withAlpha(60)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(selectedName!, style: Styles.inter14500black(context)),
            ),
            InkWell(
              onTap: onClear,
              child: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      );
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppConstants.sp20(context)),
        decoration: BoxDecoration(
          color: const Color(0xffF7F7F8),
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, color: AppColors.gray),
            SizedBox(width: AppConstants.width5(context)),
            Text(hint, style: Styles.inter14600gray(context)),
          ],
        ),
      ),
    );
  }
}
