import 'package:flutter/material.dart';
import 'package:bus_ticket_system/database/db_helper.dart';

// Import Bus Model
import 'package:bus_ticket_system/admin/models/bus_model.dart';

// Correct Screen File
import 'available_buses_screen.dart';

class SearchBusScreen extends StatefulWidget {
  const SearchBusScreen({super.key});

  @override
  State<SearchBusScreen> createState() => _SearchBusScreenState();
}

class _SearchBusScreenState extends State<SearchBusScreen> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDate;

  Future<void> pickDate() async {
    DateTime today = DateTime.now();
    DateTime lastAllowed = today.add(const Duration(days: 10));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: lastAllowed,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.green,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  searchBus() async {
    final from = fromController.text.trim();
    final to = toController.text.trim();

    final db = DBHelper.instance;

    // Get raw data from DB (List<Map>)
    final rawBuses = await db.getBusesByRoute(from, to);

    // FIX: Convert to List<BusModel>
    final List<BusModel> buses =
        rawBuses.map((e) => BusModel.fromMap(e)).toList();

    // Navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvailableBusesUserScreen(
          buses: buses,
          selectedDate: selectedDate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Search Bus", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 15),

            TextField(
              controller: fromController,
              decoration: InputDecoration(
                labelText: "From City",
                labelStyle: const TextStyle(color: Colors.green),
                prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: toController,
              decoration: InputDecoration(
                labelText: "To City",
                labelStyle: const TextStyle(color: Colors.green),
                prefixIcon: const Icon(Icons.location_city, color: Colors.green),
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Travel Date",
                labelStyle: const TextStyle(color: Colors.green),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.green),
                  onPressed: pickDate,
                ),
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: pickDate,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (fromController.text.isEmpty ||
                      toController.text.isEmpty ||
                      dateController.text.isEmpty ||
                      selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all fields"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  searchBus();
                },
                child: const Text("Search Bus", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
