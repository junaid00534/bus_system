import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminOptions = [
      {
        'icon': Icons.route,
        'title': 'Manage Routes',
        'onTap': () => Navigator.pushNamed(context, '/manage_routes'),
      },
      {
        'icon': Icons.directions_bus,
        'title': 'Manage Buses',
        'onTap': () => Navigator.pushNamed(context, '/manage_buses'),
      },
      {
        'icon': Icons.receipt_long,
        'title': 'View All Bookings',
        'onTap': () => Navigator.pushNamed(context, '/view_all_booking'),
      },
      {
        'icon': Icons.people,
        'title': 'All Users',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Users list coming soon!")),
          );
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/admin_login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome, Admin!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== GRID STYLE CARDS LIKE USER SCREEN =====
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: adminOptions.map((option) {
                return _adminCard(
                  icon: option['icon'] as IconData,
                  title: option['title'] as String,
                  onTap: option['onTap'] as VoidCallback,
                );
              }).toList(),
            ),

            const Spacer(),

            const Text(
              "Bus Ticket System v1.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _adminCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 95,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
