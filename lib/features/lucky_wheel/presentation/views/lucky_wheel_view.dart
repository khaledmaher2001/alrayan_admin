import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/repo/lucky_wheel_repo_impl.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/delete_lucky_item/delete_lucky_item_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/edit_lucky_item/edit_lucky_item_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/get_lucky_wheel_items/get_lucky_wheel_items_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/widgets/lucky_wheel_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LuckyWheelView extends StatefulWidget {
  const LuckyWheelView({super.key});

  @override
  State<LuckyWheelView> createState() => _LuckyWheelViewState();
}

class _LuckyWheelViewState extends State<LuckyWheelView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetLuckyWheelItemsCubit>().getLuckyWheelItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => EditLuckyItemCubit(getIt.get<LuckyWheelRepoImpl>()),
        ),
        BlocProvider(
          create: (_) => DeleteLuckyItemCubit(getIt.get<LuckyWheelRepoImpl>()),
        ),
      ],
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: const Scaffold(body: LuckyWheelViewBody()),
      ),
    );
  }
}
