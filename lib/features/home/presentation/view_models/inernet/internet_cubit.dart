import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/constants.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  InternetCubit() : super(InternetInitial());

  static InternetCubit get(context) => BlocProvider.of(context);

  // لما يبقى فيه انترنت
  void internetConnected() {
    AppConstants.hasInternet = true;
    emit(InternetConnectedState());
  }

  // لما ميبقاش فيه انترنت
  void internetDisconnected() {
    AppConstants.hasInternet = false;
    emit(InternetDisconnectedState());
  }
}