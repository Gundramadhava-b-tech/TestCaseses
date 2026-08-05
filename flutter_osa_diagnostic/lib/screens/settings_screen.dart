import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlCtrl;

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(text: ApiService.baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Theme Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile(
                    title: const Text('Dark Mode Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Toggle high-contrast medical dark theme'),
                    secondary: Icon(appState.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.blue),
                    value: appState.isDarkMode,
                    onChanged: (_) => appState.toggleTheme(),
                  ),
                ),
                const SizedBox(height: 16),

                // API Server Connection Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Backend Server Connection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Set API endpoint host for live database synchronization.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _urlCtrl,
                          decoration: InputDecoration(
                            labelText: 'API Base URL',
                            hintText: 'http://localhost:3000/api',
                            prefixIcon: const Icon(Icons.dns_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save & Reconnect API'),
                            onPressed: () {
                              appState.updateApiBaseUrl(_urlCtrl.text.trim());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('API URL updated successfully.')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // App Info Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.blue),
                    title: Text('AeroDiag Unified Platform'),
                    subtitle: Text('Version 1.0.0 (Flutter Web & Android Edition)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
