import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  List<Map<String, dynamic>> feedbackList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final feedbacks = await DBHelper.instance.getAllFeedbacks();
    setState(() {
      feedbackList = feedbacks;
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
        title: const Text("User Feedbacks"),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.greenAccent],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : feedbackList.isEmpty
              ? _buildEmptyState(
                  icon: Icons.feedback_outlined,
                  title: "No Feedback Yet",
                  subtitle: "Users haven't submitted any feedback.",
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: Colors.green,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: feedbackList.length,
                    itemBuilder: (context, index) {
                      final item = feedbackList[index];
                      return _modernFeedbackCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _modernFeedbackCard(Map<String, dynamic> item) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.green.withOpacity(0.05), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.green, size: 30),
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
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
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