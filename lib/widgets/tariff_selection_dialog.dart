import 'package:flutter/material.dart';
import '../constants/tariffs.dart';
import '../models/tariff.dart';

/// Tarife seçim bottom sheet'ini gösterir.
/// Seçilen tarife döndürülür, iptal edilirse null döner.
Future<Tariff?> showTariffSelectionDialog(BuildContext context) {
  return showModalBottomSheet<Tariff>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.teal.shade600, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Tarife Seçin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade200, height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tariffs.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey.shade200, height: 1),
                itemBuilder: (context, index) {
                  final tariff = tariffs[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.teal.shade200),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${tariff.minutes}',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      '${tariff.minutes} Dakika',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      '${tariff.price} TL',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(tariff);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}
