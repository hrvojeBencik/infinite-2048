import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/subscription_service.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionService _service;

  SubscriptionBloc({required SubscriptionService service})
      : _service = service,
        super(const SubscriptionInitial()) {
    on<SubscriptionCheckRequested>(_onCheckRequested);
    on<SubscriptionLoadOfferings>(_onLoadOfferings);
    on<SubscriptionPurchaseRequested>(_onPurchaseRequested);
    on<SubscriptionRestoreRequested>(_onRestoreRequested);
  }

  Future<void> _onCheckRequested(
    SubscriptionCheckRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    await _service.initialize();
    final isPremium = await _service.isPremium();
    emit(SubscriptionLoaded(isPremium: isPremium));
  }

  Future<void> _onLoadOfferings(
    SubscriptionLoadOfferings event,
    Emitter<SubscriptionState> emit,
  ) async {
    await _service.initialize();
    emit(SubscriptionLoading(isPremium: state.isPremium));
    final offerings = await _service.getOfferings();
    emit(SubscriptionLoaded(
      isPremium: state.isPremium,
      offerings: offerings,
    ));
  }

  Future<void> _onPurchaseRequested(
    SubscriptionPurchaseRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionPurchasing(
      isPremium: state.isPremium,
      offerings: state.offerings,
    ));
    try {
      await _service.purchasePackage(event.package);
      final isPremium = await _service.isPremium();
      emit(SubscriptionLoaded(
        isPremium: isPremium,
        offerings: state.offerings,
      ));
    } catch (e) {
      emit(SubscriptionError(
        errorMessage:
            'Purchase could not be completed. Check your payment method and try again.',
        isPremium: state.isPremium,
        offerings: state.offerings,
      ));
    }
  }

  Future<void> _onRestoreRequested(
    SubscriptionRestoreRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading(
      isPremium: state.isPremium,
      offerings: state.offerings,
    ));
    try {
      await _service.restorePurchases();
      final isPremium = await _service.isPremium();
      emit(SubscriptionLoaded(
        isPremium: isPremium,
        offerings: state.offerings,
        errorMessage:
            isPremium ? null : 'No active subscription found for this Apple ID.',
      ));
    } catch (e) {
      emit(SubscriptionError(
        errorMessage: 'No active subscription found for this Apple ID.',
        isPremium: state.isPremium,
        offerings: state.offerings,
      ));
    }
  }
}
