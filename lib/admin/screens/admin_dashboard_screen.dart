import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Welcome, Admin!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            // ========== ADMIN OPTIONS ==========

            _adminButton(
              icon: Icons.route,
              title: "Manage Routes",
              onTap: () {
                Navigator.pushNamed(context, '/manage_routes');
              },
            ),

            _adminButton(
              icon: Icons.directions_bus,
              title: "Manage Buses",
              onTap: () {
                Navigator.pushNamed(context, '/manage_buses');
              },
            ),

            _adminButton(
              icon: Icons.receipt_long,
              title: "View All Bookings",
              onTap: () {
                // TODO: Booking history screen yahan aayegi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Bookings screen coming soon!")),
                );
              },
            ),

            _adminButton(
              icon: Icons.people,
              title: "All Users",
              onTap: () {
                // TODO: Users list screen yahan aayegi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Users list coming soon!")),
                );
              },
            ),

            const Spacer(),

            // Optional: App version ya extra info
            const Center(
              child: Text(
                "Bus Ticket System v1.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reusable Button Widget
  Widget _adminButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 62),
          elevation: 6,
          shadowColor: Colors.greenAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 20),
          ],
        ),
      ),
    );
  }
}