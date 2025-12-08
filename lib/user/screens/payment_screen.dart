import 'package:flutter/material.dart';
import '../../admin/models/bus_model.dart';
import '../../database/db_helper.dart';
import 'view_ticket_screen.dart';
import 'passenger_detail_screen.dart';

class PaymentScreen extends StatefulWidget {
  final BusModel bus;
  final List<int> selectedSeats;
  final String date;
  final Map<String, dynamic> passengerData;

  const PaymentScreen({
    super.key,
    required this.bus,
    required this.selectedSeats,
    required this.date,
    required this.passengerData,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPayment;
  TextEditingController accountController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text("Payment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PassengerDetailScreen(
                  bus: widget.bus,
                  selectedSeats: widget.selectedSeats,
                  date: widget.date,
                ),
              ),
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            _paymentCard("Easypaisa", Icons.account_balance_wallet),
            _paymentCard("JazzCash", Icons.payment),
            _paymentCard("Credit/Debit Card", Icons.credit_card),

            const SizedBox(height: 20),

            if (selectedPayment != null) ...[
              Text(
                "$selectedPayment Account Number",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              _inputField(
                controller: accountController,
                hint: "Enter account number",
                icon: Icons.confirmation_number,
                keyboard: TextInputType.number,
              ),

              const SizedBox(height: 20),

              const Text(
                "Email for Payment Confirmation",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 6),

              _inputField(
                controller: emailController,
                hint: "Enter your email",
                icon: Icons.email,
                keyboard: TextInputType.emailAddress,
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _processPayment,
                child: const Text(
                  "Confirm & Continue",
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SAVE PAYMENT FUNCTION
  Future<void> _processPayment() async {
    if (selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method")),
      );
      return;
    }

    if (accountController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter account number and email")),
      );
      return;
    }

    // SAVE PAYMENT IN DB
    await DBHelper.instance.insertPayment(
      busId: widget.bus.id!,
      seats: widget.selectedSeats,
      passengerName: widget.passengerData["name"],
      passengerEmail: emailController.text.trim(),
      paymentMethod: selectedPayment!,
      accountNumber: accountController.text.trim(),
    );

    // GO TO TICKET SCREEN
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewTicketScreen(
          ticketData: {
            "passenger": widget.passengerData,
            "bus": widget.bus,
            "seats": widget.selectedSeats,
            "date": widget.date,
            "paymentMethod": selectedPayment,
          },
        ),
      ),
    );
  }

  // ------------------- UI COMPONENTS ------------------------
  Widget _paymentCard(String title, IconData icon) {
    bool active = selectedPayment == title;

    return GestureDetector(
      onTap: () => setState(() => selectedPayment = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? Colors.green : Colors.grey.shade300,
            width: active ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            Icon(icon, color: active ? Colors.green : Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? Colors.green.shade800 : Colors.black87,
              ),
            ),
            const Spacer(),
            Radio(
              value: title,
              groupValue: selectedPayment,
              onChanged: (value) => setState(() => selectedPayment = value),
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboard,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ),
      ),
    );
  }
}
