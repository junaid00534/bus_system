import 'package:flutter/material.dart';
import 'package:bus_ticket_system/database/db_helper.dart';
import 'package:bus_ticket_system/admin/models/bus_model.dart';
import 'package:bus_ticket_system/user/screens/available_buses_screen.dart';

class SearchBusScreen extends StatefulWidget {
  const SearchBusScreen({super.key});

  @override
  State<SearchBusScreen> createState() => _SearchBusScreenState();
}

class _SearchBusScreenState extends State<SearchBusScreen> {
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDate;
  String? selectedFrom;
  String? selectedTo;
  String selectedBusType = "All Types"; // Default bus type

  List<String> fromCities = [];
  List<String> toCities = [];
  bool isLoadingCities = true;

  final List<String> busTypes = ["All Types", "Gold", "Business", "Executive"];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  // Load all unique "From" and "To" cities from the database
  Future<void> _loadCities() async {
    final db = DBHelper.instance;
    final fromList = await db.getAllFromCities();
    final toList = await db.getAllToCities();

    setState(() {
      fromCities = fromList;
      toCities = toList;
      isLoadingCities = false;
    });
  }

  // Open date picker and allow selection only for the next 10 days (today + 9 days ahead)
  Future<void> pickDate() async {
    DateTime today = DateTime.now();
    DateTime lastAllowed = today.add(const Duration(days: 9)); // Only next 10 days total (today included)

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
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  // Search buses based on route, date, and optional bus type
  Future<void> searchBus(int userId) async {
    if (selectedFrom == null ||
        selectedTo == null ||
        selectedDate == null ||
        selectedFrom!.isEmpty ||
        selectedTo!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select From, To and Date"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final db = DBHelper.instance;

    // Fetch buses with optional bus type filter
    final rawBuses = await db.getBusesByRouteAndType(
      selectedFrom!,
      selectedTo!,
      selectedBusType == "All Types" ? null : selectedBusType,
    );

    final List<BusModel> buses =
        rawBuses.map((e) => BusModel.fromMap(e)).toList();

    // Filter buses by selected date (client-side filtering)
    final String formattedDate =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    final filteredBuses =
        buses.where((bus) => bus.date == formattedDate).toList();

    if (filteredBuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("No buses found for selected route, date and type"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to available buses screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvailableBusesUserScreen(
          buses: filteredBuses,
          selectedDate: selectedDate!,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Replace with actual logged-in user ID later
    final int currentUserId = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title:
            const Text("Search Bus", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // From city dropdown
            _buildDropdown(
              value: selectedFrom,
              hint: "Select From City",
              items: fromCities,
              onChanged: (value) => setState(() => selectedFrom = value),
              icon: Icons.location_on_outlined,
              loading: isLoadingCities,
            ),

            const SizedBox(height: 16),

            // To city dropdown
            _buildDropdown(
              value: selectedTo,
              hint: "Select To City",
              items: toCities,
              onChanged: (value) => setState(() => selectedTo = value),
              icon: Icons.flag_outlined,
              loading: isLoadingCities,
            ),

            const SizedBox(height: 16),

            // Bus type dropdown
            _buildDropdown(
              value: selectedBusType,
              hint: "Bus Type",
              items: busTypes,
              onChanged: (value) =>
                  setState(() => selectedBusType = value!),
              icon: Icons.directions_bus,
            ),

            const SizedBox(height: 16),

            // Date picker field - now limited to next 10 days only
            GestureDetector(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.green),
                    const SizedBox(width: 16),
                    Text(
                      dateController.text.isEmpty
                          ? "Select Travel Date (Next 10 days only)"
                          : dateController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: dateController.text.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Search buses button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => searchBus(currentUserId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  "Search Buses",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable modern dropdown widget
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
    bool loading = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        icon: Icon(icon, color: Colors.green),
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none),
        items: loading
            ? [
                const DropdownMenuItem(
                  child: Text("Loading cities..."),
                )
              ]
            : items
                .map(
                  (city) =>
                      DropdownMenuItem(value: city, child: Text(city)),
                )
                .toList(),
        onChanged: loading ? null : onChanged,
      ),
    );
  }
}