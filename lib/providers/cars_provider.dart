import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car.dart';
import '../services/supabase_service.dart';

/// Supabase servis instance provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService());

/// Boştaki araçları yöneten provider
final availableCarsProvider =
    StateNotifierProvider<AvailableCarsNotifier, AsyncValue<List<Car>>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AvailableCarsNotifier(supabaseService);
});

class AvailableCarsNotifier extends StateNotifier<AsyncValue<List<Car>>> {
  final SupabaseService _supabaseService;

  AvailableCarsNotifier(this._supabaseService)
      : super(const AsyncValue.loading()) {
    fetchCars();
  }

  Future<void> fetchCars() async {
    state = const AsyncValue.loading();
    try {
      final cars = await _supabaseService.fetchAvailableCars();
      state = AsyncValue.data(cars);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await fetchCars();
  }
}
