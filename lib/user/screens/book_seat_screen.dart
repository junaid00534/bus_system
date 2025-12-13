import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../admin/models/bus_model.dart';

class BookSeatScreen extends StatefulWidget {
  final BusModel bus;
  final DateTime selectedDate;
  final int userId; // 👈 Add this

  const BookSeatScreen({
    super.key,
    required this.bus,
    required this.selectedDate,
    required this.userId, // 👈 Receive logged-in userId
  });

  @override
  State<BookSeatScreen> createState() => _BookSeatScreenState();
}

class _BookSeatScreenState extends State<BookSeatScreen> {
  List<int> selectedSeats = [];
  Map<int, String> seatGender = {};
  Map<int, String> bookedSeatsMap = {}; // Already booked seats

  @override
  void initState() {
    super.initState();
    loadBookedSeats();
  }

  Future<void> loadBookedSeats() async {
    final db = DBHelper.instance;

    if (widget.bus.id == null) return; // Safety Fix

    final rows = await db.getBookedSeatsWithGender(widget.bus.id!);

    Map<int, String> temp = {};

    for (var r in rows) {
      int seat = int.tryParse(r['seatNumber'].toString()) ?? 0;
      String gender = (r['gender'] ?? "M").toString();
      temp[seat] = gender;
    }

    setState(() {
      bookedSeatsMap = temp;
    });
  }

  // ============================================
  // 🔥 GENDER POPUP
  // ============================================
  Future<String?> selectGenderDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Gender"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.male, color: Colors.blue),
                title: const Text("Male"),
                onTap: () => Navigator.pop(context, "M"),
              ),
              ListTile(
                leading: const Icon(Icons.female, color: Colors.pink),
                title: const Text("Female"),
                onTap: () => Navigator.pop(context, "F"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateKey =
        "${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Select Seat"),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // =============== SEAT GRID ===============
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 350,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 40,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      int seatNum = index + 1;
                      bool isBooked = bookedSeatsMap.containsKey(seatNum);
                      bool isSelected = selectedSeats.contains(seatNum);

                      // Gender priority → booked → selected → null safe
                      String gender =
                          bookedSeatsMap[seatNum] ?? seatGender[seatNum] ?? "M";

                      return GestureDetector(
                        onTap: isBooked
                            ? null
                            : () async {
                                if (isSelected) {
                                  setState(() {
                                    selectedSeats.remove(seatNum);
                                    seatGender.remove(seatNum);
                                  });
                                } else {
                                  String? g = await selectGenderDialog();
                                  if (g != null) {
                                    setState(() {
                                      selectedSeats.add(seatNum);
                                      seatGender[seatNum] = g;
                                    });
                                  }
                                }
                              },

                        child: Container(
                          decoration: BoxDecoration(
                            color: isBooked
                                ? (gender == "M"
                                    ? Colors.blue.shade300
                                    : Colors.pink.shade300)
                                : isSelected
                                    ? (seatGender[seatNum] == "M"
                                        ? Colors.blue
                                        : Colors.pink)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Center(
                            child: Text(
                              seatNum.toString(),
                              style: TextStyle(
                                color: isBooked || isSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // =============== BOOK BUTTON ===============
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed: selectedSeats.isEmpty
                    ? null
                    : () async {
                        final db = DBHelper.instance;

                        if (widget.bus.id == null) return; // Safety Fix

                        for (int seat in selectedSeats) {
                          await db.bookSeats(
                            busId: widget.bus.id!,
                            seats: [seat.toString()],
                            gender: seatGender[seat] ?? "M",
                            date: dateKey,
                            userId: widget.userId, // 👈 FIX: use real logged-in userId
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Seats booked successfully!"),
                          ),
                        );

                        // NAVIGATE
                        Navigator.pushNamed(
                          context,
                          '/passenger_details',
                          arguments: {
                            'bus': widget.bus,
                            'selectedSeats': selectedSeats,
                            'genderMap': seatGender,
                            'date': dateKey,
                          },
                        );
                      },

                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
