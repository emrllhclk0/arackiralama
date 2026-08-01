import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/revenue_provider.dart';
import '../widgets/revenue_summary_card.dart';

class RevenueScreen extends ConsumerWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyRevenueAsync = ref.watch(dailyRevenueProvider);
    final monthlyRevenueAsync = ref.watch(monthlyRevenueProvider);

    final now = DateTime.now();
    final todayStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(now);
    final monthStr = DateFormat('MMMM yyyy', 'tr_TR').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ciro Raporu',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyRevenueProvider);
          ref.invalidate(monthlyRevenueProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Günlük Ciro
            dailyRevenueAsync.when(
              data: (revenue) => RevenueSummaryCard(
                title: 'Bugünün Cirosu',
                amount: revenue,
                subtitle: todayStr,
                icon: Icons.today,
                color1: Colors.blueAccent,
                color2: Colors.lightBlue,
              ),
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Container(
                padding: const EdgeInsets.all(16),
                child: Text('Hata: $err',
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
            const SizedBox(height: 16),
            // Aylık Ciro
            monthlyRevenueAsync.when(
              data: (revenue) => RevenueSummaryCard(
                title: 'Bu Ayın Cirosu',
                amount: revenue,
                subtitle: monthStr,
                icon: Icons.calendar_month,
                color1: Colors.purpleAccent,
                color2: Colors.deepPurple,
              ),
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Container(
                padding: const EdgeInsets.all(16),
                child: Text('Hata: $err',
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
