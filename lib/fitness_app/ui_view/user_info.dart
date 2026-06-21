import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fitness_app_theme.dart'; // 👈 use your existing theme colors

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String? _backendUrl;

  @override
  void initState() {
    super.initState();
    _loadBackendUrl();
  }

  Future<void> _loadBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _backendUrl = prefs.getString('backend_url');
    });
  }

  void _showBackendUrlDialog() {
    final controller = TextEditingController(text: _backendUrl ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Backend URL'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Backend URL',
            hintText: 'https://your-backend-url.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.clear(),
            child: Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('backend_url', controller.text);
              setState(() {
                _backendUrl = controller.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Backend URL saved!')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: AppBar(
        backgroundColor: FitnessAppTheme.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: FitnessAppTheme.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: IconThemeData(color: FitnessAppTheme.darkText),
      ),
      body: SingleChildScrollView( // <-- Add this widget to make the screen scrollable
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Picture and Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/userImage.png'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Foodie Explorer',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: FitnessAppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Passionate about discovering recipes',
                    style: TextStyle(
                      fontSize: 14,
                      color: FitnessAppTheme.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Options List
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildProfileOption(Icons.person_outline, 'My Profile', () {
                    // Add your navigation or dialog here
                  }),
                  _buildProfileOption(Icons.settings_outlined, 'Settings', () {
                    // Add your navigation or dialog here
                  }),
                  _buildProfileOption(Icons.link, 'Backend URL', _showBackendUrlDialog,
                      subtitle: _backendUrl ?? 'Not configured'),
                  _buildProfileOption(Icons.lock_outline, 'Account', () {
                    // Add your navigation or dialog here
                  }),
                  _buildProfileOption(Icons.info_outline, 'About App', () {
                    // Add your navigation or dialog here
                  }),
                  _buildProfileOption(Icons.logout, 'Logout', () {
                    // Add your logout logic here
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: FitnessAppTheme.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: FitnessAppTheme.nearlyDarkBlue),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: FitnessAppTheme.darkText,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: FitnessAppTheme.grey),
        onTap: onTap,
      ),
    );
  }
}
