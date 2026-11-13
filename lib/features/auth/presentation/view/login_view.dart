import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/auth/presentation/view/forget_password_view.dart';
import 'package:alrayan_admin/features/auth/presentation/view/widgets/auth_ui.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/user_login/login_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/user_login/login_state.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';

/// Admin sign-in: phone or email + password, same design as the customer app.
/// Admin accounts are created by the store owner, so there is no sign-up here.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // 0 = phone (default), 1 = email.
  int _method = 0;

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;
    final identifier = _method == 0 ? "+20${phoneController.text.trim()}" : emailController.text.trim();
    context.read<LoginCubit>().userlogin(identifier: identifier, password: passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final gap = MediaQuery.of(context).size.height;
    return AuthScaffold(
      logo: AssetData.logo,
      title: 'auth_title'.tr(),
      subtitle: 'auth_subtitle'.tr(),
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthMethodTabs(index: _method, onChanged: (i) => setState(() => _method = i)).authEnter(180),
              SizedBox(height: gap * .018),
              (_method == 0
                      ? AuthPhoneField(key: const ValueKey('phone'), controller: phoneController)
                      : AuthEmailField(key: const ValueKey('email'), controller: emailController))
                  .authEnter(240),
              SizedBox(height: gap * .024),
              AuthPasswordField(controller: passwordController, onSubmit: _submit).authEnter(300),
              AuthForgotLink(
                onTap: () => NavigationUtils.navigateTo(context: context, destinationScreen: ForgetPasswordView()),
              ).authEnter(380),
              SizedBox(height: gap * .012),
              BlocConsumer<LoginCubit, LoginStates>(
                listener: (context, state) {
                  if (state is LoginSuccessState) {
                    context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(0);
                    GoRouter.of(context).pushReplacement('/mainLayoutView');
                  }
                  if (state is LoginErrorState) showAuthError(context, state.errorMessage);
                },
                builder: (context, state) => AuthPrimaryButton(
                  loading: state is LoginLoadingState,
                  onPress: _submit,
                ),
              ).authEnter(460),
            ],
          ),
        ),
      ],
    );
  }
}
