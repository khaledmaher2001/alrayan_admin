import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

/// Guards an async fetch cubit against overlapping requests.
///
/// Every fetch calls [beginRequest] — which cancels the previous in-flight
/// request — passes [requestCancelToken] to the repo, and after awaiting bails
/// out unless [isCurrentRequest] still holds (a newer fetch started, or the
/// cubit closed). Call [cancelInFlightRequest] from `close()`.
mixin RequestGuardMixin<S> on BlocBase<S> {
  int _requestSeq = 0;
  CancelToken? _activeToken;

  /// Opens a new request generation, cancelling any request still in flight,
  /// and returns the id identifying this generation.
  int beginRequest() {
    _requestSeq++;
    _activeToken?.cancel('superseded by request #$_requestSeq');
    _activeToken = CancelToken();
    return _requestSeq;
  }

  /// The [CancelToken] for the current generation — forward it to the repo.
  CancelToken? get requestCancelToken => _activeToken;

  /// True while [id] is still the latest generation and the cubit is open.
  bool isCurrentRequest(int id) => !isClosed && id == _requestSeq;

  /// Cancels whatever is in flight. Call from `close()`.
  void cancelInFlightRequest() {
    _activeToken?.cancel('cubit closed');
    _activeToken = null;
  }
}
