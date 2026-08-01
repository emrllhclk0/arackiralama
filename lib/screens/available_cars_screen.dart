import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cars_provider.dart';
import '../providers/rentals_provider.dart';
import '../widgets/car_card.dart';
import '../widgets/tariff_selection_dialog.dart';
import '../services/notification_service.dart';

class AvailableCarsScreen extends ConsumerWidget {
  const AvailableCarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableCarsAsync = ref.watch(availableCarsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Boştaki Araçlar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(availableCarsProvider.notifier).refresh();
        },
        child: availableCarsAsync.when(
          data: (cars) {
            if (cars.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.electric_car, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Tüm araçlar kirada',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return CarCard(
                  car: car,
                  onTap: () async {
                    final selectedTariff =
                        await showTariffSelectionDialog(context);

                    if (selectedTariff != null && context.mounted) {
                      try {
                        await ref
                            .read(activeRentalsProvider.notifier)
                            .startRental(car.id, selectedTariff);

                        final endTime = DateTime.now()
                            .add(Duration(minutes: selectedTariff.minutes));

                        await NotificationService
                            .scheduleRentalEndNotification(
                          rentalId: '${car.id}_${DateTime.now().millisecondsSinceEpoch}',
                          endTime: endTime,
                          carName: car.name,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${car.name} kiralama başladı! (${selectedTariff.minutes} dk - ${selectedTariff.price} TL)'),
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
                      ref.read(availableCarsProvider.notifier).refresh(),
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
