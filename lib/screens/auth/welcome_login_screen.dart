import 'package:flutter/material.dart';
import 'package:bus_ticket_system/database/db_helper.dart';
import 'package:bus_ticket_system/user/screens/my_tickets_screen.dart';

class WelcomeLoginScreen extends StatefulWidget {
  final String userEmail;

  const WelcomeLoginScreen({super.key, required this.userEmail});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends State<WelcomeLoginScreen> {
  String userName = "";
  String userPhone = "";
  int userId = 0;
  bool isWalletVisible = false;
  bool isLoading = true;

  // Bottom Nav
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = await DBHelper.instance.getUserByEmail(widget.userEmail);

    if (user != null) {
      setState(() {
        userId = user['id'] as int;
        userName = "${user['firstName']} ${user['lastName']}";
        userPhone = user['phone'] ?? "";
        isLoading = false;
      });
    } else {
      setState(() {
        userName = "Unknown User";
        userPhone = "";
        userId = 0;
        isLoading = false;
      });
    }
  }

  void _goToMyTickets() {
    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found. Please login again.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyTicketsScreen(userId: userId, userEmail: widget.userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.green, size: 30),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/bus_welcome.png",
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              "JUNAID MOVERS",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.green, size: 30),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ===== TOP BANNER =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/bus_welcome.png",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ===== USER CARD =====
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 40, color: Colors.green),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userPhone,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isWalletVisible = !isWalletVisible;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Wallet Balance",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              Text(
                                isWalletVisible ? "0.00 PKR" : "***** PKR",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // ===== 3 MAIN FEATURES =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _featureButton(
                  icon: Icons.directions_bus,
                  title: "Bus Tickets",
                  onTap: () {
                    Navigator.pushNamed(context, '/search_bus');
                  },
                ),
                _featureButton(
                  icon: Icons.inventory,
                  title: "Cargo Tracking",
                  onTap: () {
                    Navigator.pushNamed(context, '/cargo_tracking');
                  },
                ),
                _featureButton(
                  icon: Icons.local_taxi,
                  title: "Special Booking",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Coming Soon!")),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ===== BOTTOM NAVIGATION BAR =====
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // important
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              // Home → do nothing, already here
              break;
            case 1:
              _goToMyTickets(); // My Tickets
              break;
            case 2:
              // My Wallet → future logic
              break;
            case 3:
              // Support → future logic
              break;
            case 4:
              // Promotions → future logic
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: "My Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "My Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Support"),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: "Promotions"),
        ],
      ),
    );
  }

  Widget _featureButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 95,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
