import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'available_cars_screen.dart';
import 'rented_cars_screen.dart';
import 'revenue_screen.dart';
import '../providers/rentals_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AvailableCarsScreen(),
    RentedCarsScreen(),
    RevenueScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final activeRentalsAsync = ref.watch(activeRentalsProvider);
          final int rentalCount = activeRentalsAsync.maybeWhen(
            data: (rentals) => rentals.length,
            orElse: () => 0,
          );

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: Colors.teal.shade600,
            unselectedItemColor: Colors.grey.shade400,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.electric_car),
                label: 'Boşta',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: rentalCount > 0,
                  label: Text(rentalCount.toString()),
                  child: const Icon(Icons.timer),
                ),
                label: 'Kirada',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Ciro',
              ),
            ],
          );
        },
      ),
    );
  }
}
