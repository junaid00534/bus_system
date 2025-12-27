// lib/screens/user/available_buses_user_screen.dart (or wherever this file is located)

import 'package:flutter/material.dart';
import '../../admin/models/bus_model.dart';
import '../../database/db_helper.dart'; // DBHelper import
import 'book_seat_screen.dart';

class AvailableBusesUserScreen extends StatefulWidget {
  final List<BusModel> buses;
  final DateTime selectedDate;
  final int userId;

  const AvailableBusesUserScreen({
    super.key,
    required this.buses,
    required this.selectedDate,
    required this.userId,
  });

  @override
  State<AvailableBusesUserScreen> createState() =>
      _AvailableBusesUserScreenState();
}

class _AvailableBusesUserScreenState extends State<AvailableBusesUserScreen> {
  // Map to store live booked seats count for each bus
  Map<int, int> bookedSeatsCount = {};

  @override
  void initState() {
    super.initState();
    _loadBookedSeatsCount();
  }

  // Fetch booked seats count for each bus from the database
  // and store it in the map
  Future<void> _loadBookedSeatsCount() async {
    final db = DBHelper.instance;
    Map<int, int> tempCount = {};

    for (var bus in widget.buses) {
      final bookedList = await db.getBookedSeatsWithGender(bus.id!);
      tempCount[bus.id!] = bookedList.length;
    }

    if (mounted) {
      setState(() {
        bookedSeatsCount = tempCount;
      });
    }
  }

  // Format date as DD Mon YYYY
  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')} "
        "${_monthName(d.month)} "
        "${d.year}";
  }

  // Return month name from month number
  String _monthName(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7f6),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Times Details",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Book a Bus Ticket",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  formatDate(widget.selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: widget.buses.isEmpty
                ? Center(
                    child: Text(
                      "No buses available",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.buses.length,
                    itemBuilder: (context, index) {
                      return _ticketCard(context, widget.buses[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _ticketCard(BuildContext context, BusModel b) {
    final int booked = bookedSeatsCount[b.id!] ?? 0;
    final int seatsLeft = b.seats - booked;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      b.time,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 12, color: Colors.blue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          b.fromCity,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Text(
                      "Via ${b.routeVia}",
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          b.toCity,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.event_seat,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Seats Left  $seatsLeft",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(width: 20),
                      if (b.refreshment == 1 || b.refreshment == true)
                        const Row(
                          children: [
                            Icon(Icons.restaurant,
                                size: 18, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              "Refreshment",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle),
              ),
              Container(
                width: 2,
                height: 100,
                color: Colors.grey.shade300,
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (b.discountLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b.discountLabel,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.busClass,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "PKR ${b.fare.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (b.originalFare > b.fare)
                    Text(
                      "PKR ${b.originalFare.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 120,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: seatsLeft <= 0
                          ? null // Disable button if seats are sold out
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookSeatScreen(
                                    bus: b,
                                    selectedDate: widget.selectedDate,
                                    userId: widget.userId,
                                  ),
                                ),
                              ).then((_) {
                                // Reload booked seats count after returning
                                _loadBookedSeatsCount();
                              });
                            },
                      child: Text(
                        seatsLeft <= 0 ? "Sold Out" : "Buy Now",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
