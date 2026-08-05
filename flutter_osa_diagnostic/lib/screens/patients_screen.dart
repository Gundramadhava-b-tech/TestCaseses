import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/patient.dart';
import 'patient_detail_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final filteredPatients = appState.patients.where((p) {
      final query = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(query) ||
          p.email?.toLowerCase().contains(query) == true ||
          p.medicalHistory.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Add Patient',
            onPressed: () => _showAddPatientDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box
            TextField(
              decoration: InputDecoration(
                hintText: 'Search patients by name, email, or history...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 16),

            // Patient List
            Expanded(
              child: filteredPatients.isEmpty
                  ? const Center(child: Text('No patients found.'))
                  : ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, idx) {
                        final p = filteredPatients[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                                style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${p.age} yrs • ${p.gender} • BMI: ${p.bmi.toStringAsFixed(1)} kg/m²'),
                                if (p.medicalHistory.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'History: ${p.medicalHistory}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailScreen(patient: p),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPatientDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Patient'),
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final genderCtrl = TextEditingController(text: 'Male');
    final bmiCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final historyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add New Patient'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: bmiCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'BMI (kg/m²)'))),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: genderCtrl, decoration: const InputDecoration(labelText: 'Gender (Male / Female / Other)')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
              const SizedBox(height: 10),
              TextField(controller: historyCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Medical History / Symptoms')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final newP = Patient(
                id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                age: int.tryParse(ageCtrl.text) ?? 30,
                gender: genderCtrl.text.trim(),
                bmi: double.tryParse(bmiCtrl.text) ?? 24.0,
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                medicalHistory: historyCtrl.text.trim(),
                createdAt: DateTime.now(),
              );

              await context.read<AppState>().addPatient(newP);
              if (mounted) Navigator.pop(dialogCtx);
            },
            child: const Text('Save Patient'),
          ),
        ],
      ),
    );
  }
}
