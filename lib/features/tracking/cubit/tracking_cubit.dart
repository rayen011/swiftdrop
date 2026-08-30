import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/mock_drivers.dart';
import '../../../core/models/order.dart';
import '../../../core/models/order_status.dart';
import '../../../core/utils/order_timeline.dart';

class TrackingState extends Equatable {
  const TrackingState({
    required this.order,
    required this.driver,
    required this.status,
    required this.routeProgress,
  });

  final AppOrder order;
  final MockDriver driver;
  final OrderStatus status;
  final double routeProgress; // 0..1 along the driver route during onTheWay

  TrackingState copyWith({OrderStatus? status, double? routeProgress}) =>
      TrackingState(
        order: order,
        driver: driver,
        status: status ?? this.status,
        routeProgress: routeProgress ?? this.routeProgress,
      );

  @override
  List<Object?> get props => [order.id, status, routeProgress];
}

/// Renders the mock driver simulation (SPEC §1) by *reading the clock*, not by
/// scheduling transitions.
///
/// Everything shown is recomputed from the order's server-stamped `placedAt`, so
/// the cubit writes nothing: a tick only re-derives what is already true. This
/// is what makes tracking survive the app being backgrounded or killed —
/// reopening a 30s-old order correctly shows "on the way" rather than resuming
/// from wherever the old timers left off.
class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit({required AppOrder order})
      : super(TrackingState(
          order: order,
          driver: _driverFor(order),
          status: order.liveStatus(),
          routeProgress: order.placedAt == null
              ? 0
              : OrderTimeline.routeProgressAt(order.placedAt!),
        )) {
    if (state.status != OrderStatus.delivered) _startTicking();
  }

  /// Picked deterministically from the order id so the same order always shows
  /// the same driver across restarts (a random pick used to reshuffle on rebuild).
  static MockDriver _driverFor(AppOrder order) =>
      mockDrivers[order.id.hashCode.abs() % mockDrivers.length];

  static const _tick = Duration(milliseconds: 50);
  Timer? _ticker;

  void _startTicking() {
    _ticker = Timer.periodic(_tick, (_) => _refresh());
  }

  void _refresh() {
    if (isClosed) return;
    final placedAt = state.order.placedAt;
    if (placedAt == null) return;

    final now = DateTime.now();
    emit(state.copyWith(
      status: state.order.liveStatus(now: now),
      routeProgress: OrderTimeline.routeProgressAt(placedAt, now: now),
    ));

    if (state.status == OrderStatus.delivered) _ticker?.cancel();
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
