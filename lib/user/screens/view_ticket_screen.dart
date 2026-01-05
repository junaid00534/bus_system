// lib/user/screens/view_ticket_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

class ViewTicketScreen extends StatefulWidget {
  final Map<String, dynamic> ticketData;

  const ViewTicketScreen({
    super.key,
    required this.ticketData,
  });

  @override
  State<ViewTicketScreen> createState() => _ViewTicketScreenState();
}

class _ViewTicketScreenState extends State<ViewTicketScreen> {
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final p = widget.ticketData;

    final passenger = p["passenger"] ?? {};
    final bus = p["bus"] ?? {};
    final List seats = p["seats"] ?? [];
    final date = p["date"] ?? "";
    final paymentMethod = p["paymentMethod"] ?? "";

    // Safely get bus properties
    String busNumber = "";
    String fromCity = "";
    String toCity = "";
    String time = "";

    if (bus is Map<String, dynamic>) {
      busNumber = bus["busNumber"] ?? bus["busNo"] ?? bus["bus_number"] ?? "";
      fromCity = bus["fromCity"] ?? bus["from"] ?? "";
      toCity = bus["toCity"] ?? bus["to"] ?? "";
      time = bus["time"] ?? "";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Your Ticket"),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Screenshot(
        controller: screenshotController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  spreadRadius: 3,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "BUS TICKET",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Passenger Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                ticketRow("Name", passenger["name"] ?? ""),
                ticketRow("CNIC", passenger["cnic"] ?? ""),
                ticketRow("Phone", passenger["phone"] ?? ""),
                ticketRow("Seat(s)", seats.join(", ")),
                ticketRow("Payment", paymentMethod),
                const SizedBox(height: 20),
                const Text("Bus Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                ticketRow("Bus Number", busNumber),
                ticketRow("Route", "$fromCity → $toCity"),
                ticketRow("Time", time),
                ticketRow("Date", date),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await saveTicketAsImage();
                    },
                    label: const Text(
                      "Print / Save Ticket",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ticketRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Flexible(
            child: Text(value.toString(),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> saveTicketAsImage() async {
    final Uint8List? image = await screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final imagePath = File("${directory.path}/ticket.png");

    await imagePath.writeAsBytes(image);
    await Share.shareXFiles([XFile(imagePath.path)], text: "Here is your bus ticket");
  }
}
