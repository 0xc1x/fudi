import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/network/payment_gateway.dart';
import '../data/mock_payment_gateway.dart';
import '../data/supabase_order_repository.dart';
import '../domain/order_model.dart';
import '../domain/order_repository.dart';
import '../domain/reservation_result.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return SupabaseOrderRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

final paymentGatewayProvider = Provider<PaymentGateway>((ref) {
  return MockPaymentGateway();
});

final userOrdersProvider =
    AsyncNotifierProvider<UserOrdersNotifier, List<OrderModel>>(
  UserOrdersNotifier.new,
);

class UserOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    final repo = ref.watch(orderRepositoryProvider);
    return repo.getUserOrders();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(orderRepositoryProvider);
      return repo.getUserOrders();
    });
  }
}

final orderDetailProvider =
    FutureProvider.family<OrderModel, String>((ref, id) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrderById(id);
});

enum ReservationStep {
  idle,
  reserving,
  paying,
  success,
  review,
  error,
}

class ReservationState {
  const ReservationState({
    this.step = ReservationStep.idle,
    this.result,
    this.orderId,
    this.errorMessage,
  });

  final ReservationStep step;
  final ReservationResult? result;
  final String? orderId;
  final String? errorMessage;

  ReservationState copyWith({
    ReservationStep? step,
    ReservationResult? result,
    String? orderId,
    String? errorMessage,
  }) {
    return ReservationState(
      step: step ?? this.step,
      result: result ?? this.result,
      orderId: orderId ?? this.orderId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final reservationControllerProvider =
    NotifierProvider<ReservationController, ReservationState>(
  ReservationController.new,
);

class ReservationController extends Notifier<ReservationState> {
  @override
  ReservationState build() => const ReservationState();

  OrderRepository get _orderRepo => ref.read(orderRepositoryProvider);
  PaymentGateway get _paymentGateway => ref.read(paymentGatewayProvider);

  Future<void> reserveAndPay({
    required String offerId,
    String? couponId,
  }) async {
    state = state.copyWith(step: ReservationStep.reserving);

    final reservationResult =
        await _orderRepo.reserveOffer(offerId: offerId, couponId: couponId);

    if (reservationResult is ReservationFailure) {
      state = state.copyWith(
        step: ReservationStep.error,
        errorMessage: reservationResult.message,
      );
      return;
    }

    final success = reservationResult as ReservationSuccess;
    state = state.copyWith(
      step: ReservationStep.paying,
      result: success,
      orderId: success.orderId,
    );

    final paymentResult = await _paymentGateway.process(
      orderId: success.orderId,
      amount: success.price,
      currency: 'COP',
    );

    if (paymentResult is PaymentFailure) {
      state = state.copyWith(
        step: ReservationStep.error,
        errorMessage: paymentResult.message,
      );
      return;
    }

    state = state.copyWith(step: ReservationStep.success);

    ref.invalidate(userOrdersProvider);
  }

  void reset() {
    state = const ReservationState();
  }
}

final orderCancelProvider =
    AsyncNotifierProvider<OrderCancelNotifier, CancelOrderState>(
  OrderCancelNotifier.new,
);

class CancelOrderState {
  const CancelOrderState({
    this.isCanceling = false,
    this.result,
    this.errorMessage,
  });

  final bool isCanceling;
  final CancelOrderResult? result;
  final String? errorMessage;

  CancelOrderState copyWith({
    bool? isCanceling,
    CancelOrderResult? result,
    String? errorMessage,
  }) {
    return CancelOrderState(
      isCanceling: isCanceling ?? this.isCanceling,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OrderCancelNotifier extends AsyncNotifier<CancelOrderState> {
  @override
  CancelOrderState build() => const CancelOrderState();

  OrderRepository get _orderRepo => ref.read(orderRepositoryProvider);

  Future<void> cancelOrder(String orderId) async {
    state = const AsyncLoading();

    try {
      final result = await _orderRepo.cancelOrder(orderId);

      if (result.success) {
        state = AsyncData(CancelOrderState(result: result));
        ref.invalidate(userOrdersProvider);
        ref.invalidate(orderDetailProvider(orderId));
      } else {
        state = AsyncData(CancelOrderState(errorMessage: result.message ?? 'Error al cancelar'));
      }
    } catch (e) {
      state = AsyncData(CancelOrderState(errorMessage: e.toString()));
    }
  }

  void reset() {
    state = const AsyncData(CancelOrderState());
  }
}
