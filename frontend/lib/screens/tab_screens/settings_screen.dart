import 'package:flutter/material.dart';
import '../../components/safe_scaffold.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;
  String language = "English";

  final List<String> languages = ["English", "Spanish", "French", "German"];

  Widget _buildSettingItem({
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          if (trailing != null) trailing,
          if (onTap != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: onTap,
            ),
        ],
      ),
    );
  }

  void _navigateToMyProperties() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyPropertiesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Settings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text("General", style: TextStyle(color: Colors.grey)),
            _buildSettingItem(
              label: "Enable Notifications",
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (val) => setState(() => notificationsEnabled = val),
              ),
            ),
            _buildSettingItem(
              label: "Dark Mode",
              trailing: Switch(
                value: darkMode,
                onChanged: (val) => setState(() => darkMode = val),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Language", style: TextStyle(color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: DropdownButtonFormField<String>(
                value: language,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: languages
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => language = val);
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text("Account", style: TextStyle(color: Colors.grey)),
            _buildSettingItem(
              label: "Change Password",
              onTap: () {
                // Navigate to change password screen or show dialog
              },
            ),
            _buildSettingItem(
              label: "Privacy Policy",
              onTap: () {
                // Navigate to privacy policy screen or open url
              },
            ),

            const SizedBox(height: 40),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save settings or show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved')),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text("Save Settings", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                onPressed: _navigateToMyProperties,
                icon: const Icon(Icons.home),
                label: const Text("View My Properties"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy placeholder for MyPropertiesScreen
class MyPropertiesScreen extends StatelessWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Properties")),
      body: const Center(child: Text("Here are all your properties.")),
    );
  }
}
