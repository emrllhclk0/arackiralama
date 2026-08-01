import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rental.dart';
import '../models/tariff.dart';
import 'cars_provider.dart';

/// Aktif kiralamaları yöneten provider
final activeRentalsProvider =
    StateNotifierProvider<ActiveRentalsNotifier, AsyncValue<List<Rental>>>(
        (ref) {
  return ActiveRentalsNotifier(ref);
});

class ActiveRentalsNotifier extends StateNotifier<AsyncValue<List<Rental>>> {
  final Ref _ref;

  ActiveRentalsNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchRentals();
  }

  Future<void> fetchRentals() async {
    state = const AsyncValue.loading();
    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      final rentals = await supabaseService.fetchActiveRentals();
      state = AsyncValue.data(rentals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startRental(int carId, Tariff tariff) async {
    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      await supabaseService.startRental(carId, tariff);
      await refresh();
      await _ref.read(availableCarsProvider.notifier).refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<Rental> extendRental(String rentalId, Tariff tariff) async {
    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      final updatedRental =
          await supabaseService.extendRental(rentalId, tariff);
      await refresh();
      return updatedRental;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeRental(String rentalId, int carId) async {
    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      await supabaseService.completeRental(rentalId, carId);
      await refresh();
      await _ref.read(availableCarsProvider.notifier).refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    await fetchRentals();
  }
}
