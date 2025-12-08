import 'package:flutter/material.dart';
import '../../admin/models/bus_model.dart';

class PassengerDetailScreen extends StatefulWidget {
  final BusModel bus;
  final List<int> selectedSeats;
  final String date;

  const PassengerDetailScreen({
    super.key,
    required this.bus,
    required this.selectedSeats,
    required this.date,
  });

  @override
  State<PassengerDetailScreen> createState() => _PassengerDetailScreenState();
}

class _PassengerDetailScreenState extends State<PassengerDetailScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController cnicCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text("Passenger Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("Enter Your Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _buildTextField(
              controller: nameCtrl,
              label: "Full Name",
              icon: Icons.person,
              keyboardType: TextInputType.name,
            ),

            const SizedBox(height: 15),

            _buildTextField(
              controller: cnicCtrl,
              label: "CNIC Number",
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 15),

            _buildTextField(
              controller: phoneCtrl,
              label: "Phone Number",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  if (nameCtrl.text.isEmpty ||
                      cnicCtrl.text.isEmpty ||
                      phoneCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  final passengerData = {
                    "name": nameCtrl.text,
                    "cnic": cnicCtrl.text,
                    "phone": phoneCtrl.text,
                  };

                  Navigator.pushNamed(
                    context,
                    "/payment",
                    arguments: {
                      "bus": widget.bus,
                      "selectedSeats": widget.selectedSeats,
                      "date": widget.date,
                      "passengerData": passengerData,
                    },
                  );
                },
                child: const Text(
                  "Next: Payment",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
