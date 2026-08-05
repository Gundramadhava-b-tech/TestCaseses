import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state.dart';
import '../models/patient.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final severityData = appState.severityDistribution;
    final totalAnalyses = appState.totalAnalyses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AeroDiag Medical Dashboard'),
        actions: [
          IconButton(
            icon: Icon(appState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => appState.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      drawer: _buildDrawer(context, appState),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diagnostic Overview',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Obstructive Sleep Apnea (OSA) Analytics & Scan Management',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Upload & Analyze'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/upload'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stat Cards Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.1,
                        children: [
                          _buildStatCard(
                            context,
                            title: 'Total Patients',
                            value: '${appState.totalPatients}',
                            icon: Icons.people_alt_outlined,
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Diagnostic Scans',
                            value: '${appState.totalScans}',
                            icon: Icons.medical_services_outlined,
                            color: Colors.teal,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Analyses Run',
                            value: '${appState.totalAnalyses}',
                            icon: Icons.analytics_outlined,
                            color: Colors.indigo,
                          ),
                          _buildStatCard(
                            context,
                            title: 'Severe OSA Cases',
                            value: '${severityData['Severe'] ?? 0}',
                            icon: Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Analytics Charts Section
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildSeverityChartCard(context, severityData, totalAnalyses)),
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: _buildRecentAnalysesCard(context, appState)),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSeverityChartCard(context, severityData, totalAnalyses),
                            const SizedBox(height: 24),
                            _buildRecentAnalysesCard(context, appState),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityChartCard(BuildContext context, Map<String, int> data, int total) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OSA Risk Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Apnea-Hypopnea Index (AHI) Classifications', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: total == 0
                  ? const Center(child: Text('No diagnostic data available'))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: (data['Normal'] ?? 0).toDouble(),
                            title: 'Normal\n${data['Normal'] ?? 0}',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.amber,
                            value: (data['Mild'] ?? 0).toDouble(),
                            title: 'Mild\n${data['Mild'] ?? 0}',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: (data['Moderate'] ?? 0).toDouble(),
                            title: 'Mod\n${data['Moderate'] ?? 0}',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: (data['Severe'] ?? 0).toDouble(),
                            title: 'Severe\n${data['Severe'] ?? 0}',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnalysesCard(BuildContext context, AppState appState) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Diagnostic Scans', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/analyses'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            if (appState.analyses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recent diagnostic scans recorded.'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appState.analyses.length.clamp(0, 4),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final item = appState.analyses[idx];
                  final patient = appState.patients.firstWhere(
                    (p) => p.id == item.patientId,
                    orElse: () => Patient(
                      id: '',
                      name: 'Patient ${item.patientId}',
                      age: 0,
                      gender: '',
                      bmi: 0,
                      medicalHistory: '',
                      createdAt: DateTime.now(),
                    ),
                  );

                  Color badgeColor = item.severity == 'Severe'
                      ? Colors.red
                      : item.severity == 'Moderate'
                          ? Colors.orange
                          : item.severity == 'Mild'
                              ? Colors.amber
                              : Colors.green;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('AHI Score: ${item.ahiScore} • Area: ${item.minAirwayArea} mm²'),
                    trailing: Chip(
                      label: Text(
                        item.severity,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: badgeColor,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppState appState) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('AeroDiag Medical Suite', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(appState.currentUserEmail ?? 'doctor@aerodiag.med'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.airline_seat_flat_angled, color: Colors.blue, size: 30),
            ),
            decoration: BoxDecoration(color: Colors.blue.shade800),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Patients'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/patients');
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Upload Scan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/upload');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Analyses & Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/analyses');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              appState.setCurrentUser(null);
              Navigator.pushReplacementNamed(context, '/sign-in');
            },
          ),
        ],
      ),
    );
  }
}
