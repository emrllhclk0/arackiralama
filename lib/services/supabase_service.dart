import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car.dart';
import '../models/rental.dart';
import '../models/tariff.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Durumu 'available' olan araçları getirir
  Future<List<Car>> fetchAvailableCars() async {
    try {
      final response = await _client
          .from('cars')
          .select()
          .eq('status', 'available')
          .order('id');
      return response.map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Uygun araçlar getirilirken hata oluştu: $e');
    }
  }

  /// Aktif kiralamaları araç bilgileriyle birlikte getirir
  Future<List<Rental>> fetchActiveRentals() async {
    try {
      final response = await _client
          .from('rentals')
          .select('*, cars(*)')
          .eq('status', 'active')
          .order('start_time');
      return response.map((json) => Rental.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Aktif kiralamalar getirilirken hata oluştu: $e');
    }
  }

  /// Yeni kiralama başlatır ve aracı 'rented' durumuna geçirir
  Future<Rental> startRental(int carId, Tariff tariff) async {
    try {
      final now = DateTime.now().toUtc();
      final endTime = now.add(Duration(minutes: tariff.minutes));

      final rentalResponse = await _client.from('rentals').insert({
        'car_id': carId,
        'start_time': now.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_minutes': tariff.minutes,
        'total_price': tariff.price,
        'status': 'active',
      }).select('*, cars(*)').single();

      await _client.from('cars').update({'status': 'rented'}).eq('id', carId);

      return Rental.fromJson(rentalResponse);
    } catch (e) {
      throw Exception('Kiralama başlatılırken hata oluştu: $e');
    }
  }

  /// Mevcut kiralama süresini uzatır ve ücretini günceller
  Future<Rental> extendRental(String rentalId, Tariff tariff) async {
    try {
      // Mevcut kiralama bilgisini al
      final currentRental = await _client
          .from('rentals')
          .select()
          .eq('id', rentalId)
          .single();

      final currentEndTime = DateTime.parse(currentRental['end_time']);
      final newEndTime = currentEndTime.add(Duration(minutes: tariff.minutes));
      final newDuration =
          (currentRental['duration_minutes'] as int) + tariff.minutes;
      final newPrice =
          (currentRental['total_price'] as int) + tariff.price;

      // Kiralama kaydını güncelle
      final updatedRental = await _client.from('rentals').update({
        'end_time': newEndTime.toIso8601String(),
        'duration_minutes': newDuration,
        'total_price': newPrice,
      }).eq('id', rentalId).select('*, cars(*)').single();

      // Uzatma kaydını ekle
      await _client.from('rental_extensions').insert({
        'rental_id': rentalId,
        'added_minutes': tariff.minutes,
        'added_price': tariff.price,
      });

      return Rental.fromJson(updatedRental);
    } catch (e) {
      throw Exception('Kiralama uzatılırken hata oluştu: $e');
    }
  }

  /// Kiralamayı tamamlar ve aracı 'available' durumuna geçirir
  Future<void> completeRental(String rentalId, int carId) async {
    try {
      await _client
          .from('rentals')
          .update({'status': 'completed'})
          .eq('id', rentalId);
      await _client
          .from('cars')
          .update({'status': 'available'})
          .eq('id', carId);
    } catch (e) {
      throw Exception('Kiralama tamamlanırken hata oluştu: $e');
    }
  }

  /// Belirtilen tarihteki günlük ciroyu getirir
  Future<int> getDailyRevenue(DateTime date) async {
    try {
      final formattedDate =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _client
          .rpc('get_daily_revenue', params: {'target_date': formattedDate});
      return (response as int?) ?? 0;
    } catch (e) {
      throw Exception('Günlük gelir getirilirken hata oluştu: $e');
    }
  }

  /// Belirtilen yıl ve aydaki aylık ciroyu getirir
  Future<int> getMonthlyRevenue(int year, int month) async {
    try {
      final response = await _client.rpc('get_monthly_revenue',
          params: {'target_year': year, 'target_month': month});
      return (response as int?) ?? 0;
    } catch (e) {
      throw Exception('Aylık gelir getirilirken hata oluştu: $e');
    }
  }
}
