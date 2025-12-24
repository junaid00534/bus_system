import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class AdminComplainsScreen extends StatefulWidget {
  const AdminComplainsScreen({super.key});

  @override
  State<AdminComplainsScreen> createState() => _AdminComplainsScreenState();
}

class _AdminComplainsScreenState extends State<AdminComplainsScreen> {
  List<Map<String, dynamic>> complainList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final complains = await DBHelper.instance.getAllComplains();
    setState(() {
      complainList = complains;
      isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() => isLoading = true);
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Complains"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.deepOrange],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : complainList.isEmpty
              ? _buildEmptyState(
                  icon: Icons.report_problem_outlined,
                  title: "No Complains Yet",
                  subtitle: "Great! No user complaints reported.",
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: Colors.redAccent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: complainList.length,
                    itemBuilder: (context, index) {
                      final item = complainList[index];
                      return _modernComplainCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _modernComplainCard(Map<String, dynamic> item) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.red.withOpacity(0.08), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.red.withOpacity(0.2),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
          ),
          title: Text(
            item['message'] ?? 'No message',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("User ID: ${item['userId'] ?? 'Unknown'}"),
                const SizedBox(height: 4),
                Text(
                  item['date'] ?? '',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(title, style: TextStyle(fontSize: 22, color: Colors.grey[700], fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}