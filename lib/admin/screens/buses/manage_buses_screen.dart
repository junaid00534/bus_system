import 'package:flutter/material.dart';
import 'package:bus_ticket_system/admin/models/bus_model.dart';
import 'package:bus_ticket_system/database/db_helper.dart';
import 'add_edit_bus_screen.dart';

class ManageBusesScreen extends StatefulWidget {
  const ManageBusesScreen({super.key});

  @override
  State<ManageBusesScreen> createState() => _ManageBusesScreenState();
}

class _ManageBusesScreenState extends State<ManageBusesScreen> {
  // Currently selected date (defaults to today)
  DateTime selectedDate = DateTime.now();

  // List of next 10 days for the date selector
  List<DateTime> next10Days = [];

  // List of buses for the selected date
  List<BusModel> buses = [];

  // Map to store booked seats count for each bus (busId → booked count)
  Map<int, int> bookedSeatsCount = {};

  @override
  void initState() {
    super.initState();
    _generateDates();
    _loadBuses();

    // Optional: Clean old buses and their bookings on screen load
    DBHelper.instance.cleanOldBusesAndBookings();
  }

  // Generate list of next 10 days (today + next 9 days)
  void _generateDates() {
    next10Days = List.generate(10, (i) => DateTime.now().add(Duration(days: i)));
  }

  // Load buses for the selected date and sort them by time (chronological order)
  Future<void> _loadBuses() async {
    final dateKey = _formatDate(selectedDate);

    // Fetch buses from database for the selected date
    final list = await DBHelper.instance.getBusesByDate(dateKey);

    // Convert raw maps to BusModel objects
    List<BusModel> loadedBuses = list.map((e) => BusModel.fromMap(e)).toList();

    // Sort buses by departure time (earliest first)
    loadedBuses.sort((a, b) => a.time.compareTo(b.time));

    // Calculate booked seats count for each bus
    Map<int, int> tempCount = {};
    for (var bus in loadedBuses) {
      final bookedList = await DBHelper.instance.getBookedSeatsWithGender(bus.id!);
      tempCount[bus.id!] = bookedList.length;
    }

    // Update state if widget is still mounted
    if (mounted) {
      setState(() {
        buses = loadedBuses;
        bookedSeatsCount = tempCount;
      });
    }
  }

  // Format DateTime to string in YYYY-MM-DD format (used as key in DB)
  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  // Get short day name (Sun, Mon, etc.)
  String _dayName(DateTime dt) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[dt.weekday % 7];
  }

  // Get short month name (Jan, Feb, etc.)
  String _monthShort(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m[d.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7f6),
      appBar: AppBar(
        title: const Text('Manage Buses'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navigate to add new bus screen
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditBusScreen()),
          );
          // Refresh the list after adding a new bus
          await _loadBuses();
        },
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          // -------------------- DATE SELECTOR ---------------------
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: next10Days.length,
              itemBuilder: (context, i) {
                final d = next10Days[i];
                final active = _formatDate(d) == _formatDate(selectedDate);

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedDate = d);
                    _loadBuses();
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                      boxShadow: active ? null : [const BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: FittedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_dayName(d), style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("${d.day}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${_monthShort(d)} ${d.year}',
                              style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          // -------------------- BUSES LIST ---------------------
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadBuses,
              child: buses.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Text(
                            'No buses found for selected date',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: buses.length,
                      itemBuilder: (context, idx) => _busCard(buses[idx]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Individual bus card with live seats left information
  Widget _busCard(BusModel b) {
    final int booked = bookedSeatsCount[b.id!] ?? 0;
    final int seatsLeft = b.seats - booked;

    // Change color to red if no seats left
    final Color seatsTextColor = seatsLeft <= 0 ? Colors.red : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- LEFT SIDE ----------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(b.time, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b.busNumber,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(b.fromCity,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Via ${b.routeVia}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(b.toCity,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    children: [
                      const Icon(Icons.event_seat, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Seats Left $seatsLeft",
                        style: TextStyle(color: seatsTextColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      if (b.refreshment == 1 || b.refreshment == true)
                        const Row(
                          children: [
                            Icon(Icons.restaurant, size: 18, color: Colors.grey),
                            SizedBox(width: 6),
                            Text("Refreshment", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ---------------- RIGHT SIDE ----------------
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (b.discountLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        b.discountLabel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    "PKR ${b.fare.toStringAsFixed(0)}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  if (b.originalFare > b.fare)
                    Text(
                      "PKR ${b.originalFare.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddEditBusScreen(bus: b)),
                        );
                        await _loadBuses();
                      },
                      child: const Text("Edit", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Bus"),
                          content: const Text("Are you sure you want to delete this bus?\nThis will NOT delete already booked tickets."),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Cancel")),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Delete")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await DBHelper.instance.deleteBus(b.id!);
                        await _loadBuses();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}