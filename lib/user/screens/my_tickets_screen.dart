import 'package:flutter/material.dart';
import 'package:bus_ticket_system/database/db_helper.dart';

class MyTicketsScreen extends StatefulWidget {
  final int userId;
  final String userEmail;

  const MyTicketsScreen({super.key, required this.userId, required this.userEmail});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<Map<String, dynamic>> tickets = [];
  bool loading = true;

  // New state for icon selection
  bool isIconSelected = false;

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    setState(() => loading = true);
    tickets = await DBHelper.instance.getUserBookings(widget.userId);
    setState(() => loading = false);
  }

  Future<void> cancelTicket(int bookingId) async {
    bool success = await DBHelper.instance.cancelBooking(bookingId, widget.userId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket cancelled successfully!"), backgroundColor: Colors.green),
      );
      loadTickets();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot cancel this ticket."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Tickets"), backgroundColor: Colors.green),
      body: Column(
        children: [
          // Icon with label
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isIconSelected = !isIconSelected;
                });
              },
              child: Column(
                children: [
                  Icon(Icons.airplane_ticket,
                      size: 50, color: isIconSelected ? Colors.green : Colors.grey),
                  const SizedBox(height: 6),
                  Text(
                    "My Tickets",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isIconSelected ? Colors.green : Colors.black),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : tickets.isEmpty
                    ? const Center(child: Text("No tickets found", style: TextStyle(fontSize: 18)))
                    : RefreshIndicator(
                        onRefresh: loadTickets,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            final t = tickets[index];
                            bool isActive = t['status'] == 'booked';

                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text("${t['fromCity']} → ${t['toCity']}",
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        ),
                                        Chip(
                                          label: Text(isActive ? "ACTIVE" : "PAST"),
                                          backgroundColor: isActive ? Colors.green : Colors.grey,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(t['busName'] ?? "Unknown Bus", style: const TextStyle(fontSize: 16)),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Seat: ${t['seatNumber']}"),
                                        Text("Date: ${t['travelDate']}"),
                                        Text("Time: ${t['time']}"),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text("Fare: Rs. ${t['fare']}"),
                                    if (isActive)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            onPressed: () => showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text("Cancel Ticket?"),
                                                content: const Text("This action cannot be undone."),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      cancelTicket(t['bookingId']);
                                                    },
                                                    child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            child: const Text("Cancel Ticket", style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
