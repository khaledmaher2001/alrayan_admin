import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// True when the signed-in staff member has [permission] (e.g.
/// "notifications.send"). Full administrators can do everything; while the
/// profile is still loading we allow it and let the server decide.
bool staffCan(BuildContext context, String permission) {
  final state = context.read<GetProfileCubit>().state;
  if (state is! GetProfileSuccessState) return true;
  final profile = state.model.data;
  return profile == null || profile.can(permission);
}
