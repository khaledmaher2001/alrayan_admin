import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_helper.dart';

/// Sign-in look shared with the customer app: same background pattern,
/// language pill, method tabs, filled fields, button and footer, with the
/// same sizes (fractions of the screen height), so all three apps feel like
/// one product. Kept self-contained so the app's other screens are untouched.

const _accent = Color(0xFF1D1D2F);
const _fieldFill = Color(0xffF7F7F8);
const _ink = Color(0xff0F0F0E);
const _muted = Color(0xff98999A);

double _h(BuildContext c, double f) => MediaQuery.of(c).size.height * f;
Color get _primary => AppColors.primarySwatchColor;

class AuthText {
  static TextStyle title(BuildContext c) =>
      TextStyle(fontSize: _h(c, .03), fontWeight: FontWeight.w600, color: _primary);
  static TextStyle subtitle(BuildContext c) =>
      TextStyle(fontSize: _h(c, .016), fontWeight: FontWeight.w600, color: Colors.black);
  static TextStyle label(BuildContext c) =>
      TextStyle(fontSize: _h(c, .016), fontWeight: FontWeight.w600, color: _ink);
  static TextStyle hint(BuildContext c) =>
      TextStyle(fontSize: _h(c, .016), fontWeight: FontWeight.w600, color: _muted);
}

extension _Entrance on Widget {
  Widget enter(int ms) => animate(delay: ms.ms)
      .fadeIn(duration: 500.ms, curve: Curves.easeOut)
      .slideY(begin: 0.35, end: 0, duration: 650.ms, curve: Curves.easeOutCubic);
  Widget pop(int ms) => animate(delay: ms.ms)
      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
      .scale(begin: const Offset(.5, .5), end: const Offset(1, 1), duration: 700.ms, curve: Curves.elasticOut);
}

/// Page frame: pattern at the bottom, language pill, scrolling form, footer.
/// The footer hides while the keyboard is open so it never covers a field.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.logo,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String logo;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (!keyboardOpen)
              Positioned.fill(child: CustomPaint(painter: AuthWavesPainter(_primary))),
            Column(
              children: [
                SizedBox(height: padding.top),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(_h(context, .022), _h(context, .06), _h(context, .022), _h(context, .022)),
                    child: Column(
                      children: [
                        Image.asset(logo, width: MediaQuery.of(context).size.width * 0.4).pop(0),
                        SizedBox(height: _h(context, .024)),
                        Column(
                          children: [
                            Text(title, textAlign: TextAlign.center, style: AuthText.title(context)),
                            SizedBox(height: _h(context, .012)),
                            Text(subtitle, textAlign: TextAlign.center, style: AuthText.subtitle(context)),
                            SizedBox(height: _h(context, .012)),
                            Container(
                              height: _h(context, .004),
                              width: MediaQuery.of(context).size.width * .2,
                              decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(30)),
                            ),
                          ],
                        ).enter(120),
                        SizedBox(height: _h(context, .03)),
                        ...children,
                      ],
                    ),
                  ),
                ),
                if (!keyboardOpen) const _MadeBy().enter(780),
                SizedBox(height: padding.bottom + (keyboardOpen ? 0 : _h(context, .024))),
              ],
            ),
            PositionedDirectional(
              top: padding.top + _h(context, .012),
              end: _h(context, .024),
              child: const _LanguagePill().pop(150),
            ),
          ],
        ),
      ),
    );
  }
}

class _MadeBy extends StatelessWidget {
  const _MadeBy();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: _h(context, .018), fontWeight: FontWeight.w600, color: Colors.black);
    final size = MediaQuery.of(context).size.width * .11;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("أكواد ACWAD", style: style),
        const SizedBox(width: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset('assets/images/acwad.png', width: size, height: size),
        ),
        const SizedBox(width: 6),
        Text("Made with love by", style: style),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill();

  Future<void> _pick(BuildContext context) async {
    final current = context.locale.languageCode;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(_h(context, .022)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('auth_choose_language'.tr(), style: AuthText.label(context).copyWith(fontSize: _h(context, .02))),
              SizedBox(height: _h(context, .018)),
              for (final (code, name) in [('ar', "s_arabic".tr()), ('en', 'English')])
                Padding(
                  padding: EdgeInsets.only(bottom: _h(context, .012)),
                  child: Material(
                    color: code == current ? _primary.withValues(alpha: .08) : _fieldFill,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(sheet).pop(code),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 56),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: code == current ? _primary : Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(name, style: AuthText.label(context))),
                            if (code == current) Icon(Icons.check_circle, color: _primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || picked == current || !context.mounted) return;
    await CacheHelper.saveData(key: 'language', value: picked);
    if (context.mounted) await context.setLocale(Locale(picked));
    rebuildWholeApp();
  }

  @override
  Widget build(BuildContext context) {
    final label = context.locale.languageCode == 'ar' ? "s_arabic".tr() : 'English';
    return Semantics(
      button: true,
      label: '${'auth_choose_language'.tr()}: $label',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _pick(context),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.symmetric(horizontal: _h(context, .015)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _primary.withValues(alpha: .2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/images/auth_language.svg',
                  width: _h(context, .024),
                  height: _h(context, .024),
                  colorFilter: ColorFilter.mode(_primary, BlendMode.srcIn)),
              const SizedBox(width: 6),
              Text(label, style: AuthText.label(context).copyWith(color: _primary)),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Phone number / Email" switch, same look as the customer app's tab bar.
class AuthMethodTabs extends StatelessWidget {
  const AuthMethodTabs({super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final titles = ['auth_tab_phone'.tr(), 'auth_tab_email'.tr()];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _h(context, .0075), vertical: _h(context, .006)),
      decoration: BoxDecoration(color: const Color(0xffF6F8FE), borderRadius: BorderRadius.circular(_h(context, .015))),
      child: Row(
        children: [
          for (var i = 0; i < titles.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                label: titles[i],
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index ? _primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(_h(context, .015)),
                    ),
                    child: Text(
                      titles[i],
                      style: TextStyle(
                        fontSize: _h(context, .017),
                        fontWeight: FontWeight.w600,
                        color: i == index ? Colors.white : const Color(0xff9CA4AB),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

InputDecoration _decoration(BuildContext c, {String? hint, Widget? prefix, Widget? suffix}) {
  OutlineInputBorder b(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color),
      );
  return InputDecoration(
    counterText: '',
    filled: true,
    fillColor: _fieldFill,
    hintText: hint,
    hintStyle: AuthText.hint(c),
    errorMaxLines: 2,
    contentPadding: EdgeInsets.symmetric(vertical: _h(c, .018), horizontal: _h(c, .02)),
    prefixIcon: prefix,
    suffixIcon: suffix,
    border: b(DsColor.border),
    enabledBorder: b(DsColor.border),
    focusedBorder: b(_primary),
    errorBorder: b(AppColors.redColor),
    focusedErrorBorder: b(AppColors.redColor),
  );
}

Widget _svg(String asset) => Builder(
      builder: (c) => Padding(
        padding: EdgeInsets.symmetric(horizontal: _h(c, .015)),
        child: SvgPicture.asset(asset,
            width: _h(c, .024), height: _h(c, .024), colorFilter: ColorFilter.mode(_primary, BlendMode.srcIn)),
      ),
    );

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AuthText.label(context)),
          SizedBox(height: _h(context, .006)),
          child,
        ],
      );
}

/// Egyptian mobile number without the leading 0, shown after "+20 |".
class AuthPhoneField extends StatelessWidget {
  const AuthPhoneField({super.key, required this.controller});
  final TextEditingController controller;

  static String? validate(String? v) {
    if (v == null || v.isEmpty) return 'auth_err_phone_required'.tr();
    if (v.length < 10 || v[0] != '1' || !['0', '1', '2', '5'].contains(v[1])) return 'auth_err_phone_invalid'.tr();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _Labeled(
      label: 'auth_phone'.tr(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          maxLength: 10,
          style: AuthText.label(context),
          inputFormatters: [
            _ArabicDigits(),
            FilteringTextInputFormatter.digitsOnly,
            _NoLeadingZero(),
          ],
          validator: validate,
          decoration: _decoration(
            context,
            hint: '1012345678',
            prefix: Padding(
              padding: EdgeInsetsDirectional.only(start: _h(context, .015)),
              child: Center(
                widthFactor: 1,
                child: Text('+20  |', style: AuthText.hint(context).copyWith(fontSize: _h(context, .018), fontWeight: FontWeight.w400)),
              ),
            ),
            suffix: _svg('assets/images/auth_phone.svg'),
          ),
        ),
      ),
    );
  }
}

class AuthEmailField extends StatelessWidget {
  const AuthEmailField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _Labeled(
      label: 'auth_email'.tr(),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        style: AuthText.label(context),
        validator: (v) => (v ?? '').trim().isEmpty ? 'auth_err_email_required'.tr() : null,
        decoration: _decoration(context, hint: 'name@example.com', suffix: _svg('assets/images/auth_mail.svg')),
      ),
    );
  }
}

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({super.key, required this.controller, this.onSubmit});
  final TextEditingController controller;
  final VoidCallback? onSubmit;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return _Labeled(
      label: 'auth_password'.tr(),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _hidden,
        obscuringCharacter: '●',
        maxLines: 1,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => widget.onSubmit?.call(),
        style: AuthText.label(context),
        validator: (v) => (v ?? '').isEmpty ? 'auth_err_password_required'.tr() : null,
        decoration: _decoration(
          context,
          hint: '●●●●●●●●',
          prefix: _svg('assets/images/auth_lock.svg'),
          suffix: IconButton(
            tooltip: _hidden ? 'auth_show_password'.tr() : 'auth_hide_password'.tr(),
            onPressed: () => setState(() => _hidden = !_hidden),
            icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _muted),
          ),
        ),
      ),
    );
  }
}

class AuthForgotLink extends StatelessWidget {
  const AuthForgotLink({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(48, 44)),
          child: Text('auth_forgot'.tr(), style: AuthText.label(context).copyWith(color: _primary)),
        ),
      );
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({super.key, required this.onPress, required this.loading});
  final VoidCallback onPress;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withValues(alpha: .7),
          elevation: 3,
          padding: EdgeInsets.symmetric(vertical: _h(context, .018)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_h(context, .012))),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
            : Text('auth_sign_in'.tr(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: _h(context, .02))),
      ),
    );
  }
}

/// Error dialog in the same style as the customer app's.
void showAuthError(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (dialog) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.fromLTRB(_h(context, .024), _h(context, .03), _h(context, .024), _h(context, .024)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.redColor.withValues(alpha: .1), shape: BoxShape.circle),
            child: Icon(Icons.error_outline_rounded, color: AppColors.redColor, size: _h(context, .05)),
          ),
          SizedBox(height: _h(context, .018)),
          Text('auth_error_title'.tr(), textAlign: TextAlign.center, style: AuthText.label(context).copyWith(fontSize: _h(context, .02))),
          SizedBox(height: _h(context, .01)),
          Text(message, textAlign: TextAlign.center, style: AuthText.hint(context).copyWith(fontWeight: FontWeight.w500)),
          SizedBox(height: _h(context, .024)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(dialog).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                padding: EdgeInsets.symmetric(vertical: _h(context, .018)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_h(context, .012))),
              ),
              child: Text('auth_try_again'.tr(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: _h(context, .02))),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Soft waves at the bottom of the sign-in page, tinted with the brand colour
/// (replaces a fixed green picture so every brand gets its own colour).
class AuthWavesPainter extends CustomPainter {
  AuthWavesPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final top = h * .66;
    final path = Path()
      ..moveTo(0, top)
      ..cubicTo(w * .08, top + h * .06, w * .2, top + h * .1, w * .3, top + h * .085)
      ..cubicTo(w * .42, top + h * .07, w * .44, top + h * .1, w * .52, top + h * .105)
      ..cubicTo(w * .62, top + h * .11, w * .7, top + h * .06, w * .8, top + h * .065)
      ..cubicTo(w * .88, top + h * .07, w * .95, top + h * .09, w, top + h * .1)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: .10), color.withValues(alpha: .03)],
      ).createShader(Rect.fromLTWH(0, top, w, h - top));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AuthWavesPainter old) => old.color != color;
}

/// Shared helpers so the login screens don't depend on each app's own copies.
extension AuthEntrance on Widget {
  Widget authEnter(int ms) => enter(ms);
}

class _ArabicDigits extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final t = newValue.text.replaceAllMapped(
      RegExp('[٠-٩۰-۹]'),
      (m) {
        final u = m[0]!.codeUnitAt(0);
        return String.fromCharCode((u >= 0x06F0 ? u - 0x06F0 : u - 0x0660) + 0x30);
      },
    );
    return newValue.copyWith(text: t);
  }
}

class _NoLeadingZero extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.startsWith('0')) {
      final t = newValue.text.replaceFirst(RegExp('^0+'), '');
      return TextEditingValue(text: t, selection: TextSelection.collapsed(offset: t.length));
    }
    return newValue;
  }
}


/// Marks every widget for rebuild after a language change — const widgets
/// (bottom bar, logout row, …) otherwise keep showing the previous language.
void rebuildWholeApp() {
  void visit(Element e) {
    e.markNeedsBuild();
    e.visitChildren(visit);
  }
  WidgetsBinding.instance.rootElement?.visitChildren(visit);
}
