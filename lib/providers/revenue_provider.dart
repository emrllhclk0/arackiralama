import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cars_provider.dart';

/// Günlük ciro provider
final dailyRevenueProvider = FutureProvider<int>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final today = DateTime.now();
  return await supabaseService.getDailyRevenue(today);
});

/// Aylık ciro provider
final monthlyRevenueProvider = FutureProvider<int>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final now = DateTime.now();
  return await supabaseService.getMonthlyRevenue(now.year, now.month);
});
