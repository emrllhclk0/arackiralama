import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rentals_provider.dart';
import '../providers/revenue_provider.dart';
import '../widgets/rented_car_card.dart';
import '../widgets/tariff_selection_dialog.dart';
import '../services/notification_service.dart';

class RentedCarsScreen extends ConsumerWidget {
  const RentedCarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRentalsAsync = ref.watch(activeRentalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kiradaki Araçlar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(activeRentalsProvider.notifier).refresh();
        },
        child: activeRentalsAsync.when(
          data: (rentals) {
            if (rentals.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.timer_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Kirada araç yok',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rentals.length,
              itemBuilder: (context, index) {
                final rental = rentals[index];
                return RentedCarCard(
                  rental: rental,
                  onExtend: () async {
                    final selectedTariff =
                        await showTariffSelectionDialog(context);

                    if (selectedTariff != null && context.mounted) {
                      try {
                        // Mevcut bildirimi iptal et
                        await NotificationService.cancelNotification(rental.id);

                        // Kiralama süresini uzat
                        final updatedRental = await ref
                            .read(activeRentalsProvider.notifier)
                            .extendRental(rental.id, selectedTariff);

                        // Yeni bitiş zamanıyla bildirimi planla
                        await NotificationService
                            .scheduleRentalEndNotification(
                          rentalId: updatedRental.id,
                          endTime: updatedRental.endTime,
                          carName: rental.car?.name ?? 'Araç',
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '+${selectedTariff.minutes} dk eklendi! (${selectedTariff.price} TL)'),
                              backgroundColor: Colors.amber.shade700,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hata: $e'),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                      }
                    }
                  },
                  onComplete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text('Emin misiniz?',
                            style: TextStyle(color: Colors.black87)),
                        content: const Text('Bu kiralama tamamlansın mı?',
                            style: TextStyle(color: Colors.black54)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('İptal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Tamamla',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      try {
                        await ref
                            .read(activeRentalsProvider.notifier)
                            .completeRental(rental.id, rental.carId);
                        await NotificationService.cancelNotification(
                            rental.id);
                        ref.invalidate(dailyRevenueProvider);
                        ref.invalidate(monthlyRevenueProvider);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${rental.car?.name ?? "Araç"} kiralama tamamlandı.'),
                              backgroundColor: Colors.green.shade700,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hata: $e'),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                      }
                    }
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Hata: $err', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(activeRentalsProvider.notifier).refresh(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
