import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../database/db_helper.dart';

class SupportScreen extends StatelessWidget {
  final int userId; // ✅ add userId

  const SupportScreen({super.key, required this.userId}); // ✅ required

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Help & Support"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _supportTile(
              icon: Icons.question_answer,
              color: Colors.blue,
              title: "FAQs",
              subtitle: "Find answers to common questions",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("FAQs coming soon")),
                );
              },
            ),
            _supportTile(
              icon: Icons.feedback,
              color: Colors.purple,
              title: "Feedback",
              subtitle: "Share your thoughts with us",
              onTap: () {
                _openInputDialog(context, "Feedback");
              },
            ),
            _supportTile(
              icon: Icons.report_problem,
              color: Colors.red,
              title: "Complain",
              subtitle: "Submit complaints easily",
              onTap: () {
                _openInputDialog(context, "Complain");
              },
            ),
            _supportTile(
              icon: Icons.call,
              color: Colors.redAccent,
              title: "Call Us",
              subtitle: "Reach us instantly for support",
              onTap: () {
                _launchCall();
              },
            ),
            _supportTile(
              icon: Icons.chat,
              color: Colors.green,
              title: "WhatsApp",
              subtitle: "Chat with us on WhatsApp",
              onTap: () {
                _launchWhatsApp();
              },
            ),
            _supportTile(
              icon: Icons.share,
              color: Colors.blueAccent,
              title: "Follow Us on Social Media",
              subtitle: "Facebook & Instagram",
              onTap: () {
                _openSocialLinks();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _openInputDialog(BuildContext context, String type) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(type),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Enter your $type",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                if (type == "Feedback") {
                  await DBHelper.instance.insertFeedback(
                      userId: userId, // ✅ use constructor userId
                      message: controller.text);
                } else if (type == "Complain") {
                  await DBHelper.instance.insertComplain(
                      userId: userId,
                      message: controller.text);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$type submitted successfully")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _launchCall() async {
    final uri = Uri.parse("tel:03014025346");
    await launchUrl(uri);
  }

  void _launchWhatsApp() async {
    final uri = Uri.parse("https://wa.me/923014025346");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openSocialLinks() async {
    const facebookUrl = "https://facebook.com/yourpage";
    const instagramUrl = "https://instagram.com/yourpage";

    await launchUrl(Uri.parse(facebookUrl));
    await launchUrl(Uri.parse(instagramUrl));
  }
}
