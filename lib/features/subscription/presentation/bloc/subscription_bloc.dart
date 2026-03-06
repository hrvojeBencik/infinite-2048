import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/subscription_repository.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

class LoadSubscription extends SubscriptionEvent {
  const LoadSubscription();
}

class PurchaseSubscription extends SubscriptionEvent {
  final String offeringId;
  const PurchaseSubscription(this.offeringId);
  @override
  List<Object?> get props => [offeringId];
}

class RestorePurchases extends SubscriptionEvent {
  const RestorePurchases();
}

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionStatus status;
  final List<SubscriptionOffering> offerings;

  const SubscriptionLoaded({required this.status, required this.offerings});

  bool get isPremium => status.isPremium;

  @override
  List<Object?> get props => [status, offerings];
}

class SubscriptionPurchasing extends SubscriptionState {}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;

  SubscriptionBloc({required this.repository}) : super(SubscriptionInitial()) {
    on<LoadSubscription>(_onLoad);
    on<PurchaseSubscription>(_onPurchase);
    on<RestorePurchases>(_onRestore);
  }

  Future<void> _onLoad(
      LoadSubscription event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final status = await repository.getSubscriptionStatus();
      final offerings = await repository.getOfferings();
      emit(SubscriptionLoaded(status: status, offerings: offerings));
    } catch (e) {
      emit(SubscriptionLoaded(
        status: const SubscriptionStatus(),
        offerings: const [],
      ));
    }
  }

  Future<void> _onPurchase(
      PurchaseSubscription event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionPurchasing());
    try {
      final status = await repository.purchaseSubscription(event.offeringId);
      final offerings = await repository.getOfferings();
      emit(SubscriptionLoaded(status: status, offerings: offerings));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
      add(const LoadSubscription());
    }
  }

  Future<void> _onRestore(
      RestorePurchases event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final status = await repository.restorePurchases();
      final offerings = await repository.getOfferings();
      emit(SubscriptionLoaded(status: status, offerings: offerings));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
      add(const LoadSubscription());
    }
  }
}
