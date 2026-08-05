import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/severity_badge.dart';
import '../widgets/patient_avatar.dart';
import '../providers/data_provider.dart';
import '../models/patient.dart';
import '../services/translation_service.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final patients = dataProvider.patients;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSearchAndFilters(context, dataProvider),
            const SizedBox(height: 24),
            _buildPatientsTable(context, patients),
            const SizedBox(height: 24),
            _buildPagination(context, patients.length),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isMobile)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'patients'.tr(context),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage and review clinical patient records',
                  style: TextStyle(color: AppColors.textGray, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        else
          Expanded(
            child: Text(
              'patients'.tr(context),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (!isMobile) const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showAddPatientModal(context),
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
          label: Text(isMobile ? 'add'.tr(context) : 'register_patient'.tr(context)),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, DataProvider dataProvider) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: isMobile
        ? Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textGray, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'search_placeholder'.tr(context),
                        hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filters'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textGray),
                ),
              ),
            ],
          )
        : Row(
            children: [
              const Icon(Icons.search, color: AppColors.textGray, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'search_placeholder'.tr(context),
                    hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const VerticalDivider(width: 32, indent: 12, endIndent: 12),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filters'),
                style: TextButton.styleFrom(foregroundColor: AppColors.textGray),
              ),
            ],
          ),
    );
  }

  Widget _buildPatientsTable(BuildContext context, List<Patient> patients) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    return Card(
      child: isMobile
        ? ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patients.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildPatientMobileItem(context, patients[index]),
          )
        : Column(
            children: [
              _buildTableHeader(context),
              ...patients.map((p) => _buildPatientRow(context, p)),
            ],
          ),
    );
  }

  Widget _buildPatientMobileItem(BuildContext context, Patient patient) {
    return ListTile(
      onTap: () => context.go('/patients/${patient.id}'),
      leading: PatientAvatar(initials: patient.initials),
      title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('ID: ${patient.id} • ${patient.age} yrs • ${patient.gender}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SeverityBadge(severity: patient.latestStatus),
          const SizedBox(height: 4),
          Text('${patient.scanCount} scans', style: const TextStyle(fontSize: 10, color: AppColors.textGray)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('patient_name'.tr(context), style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('age_gender'.tr(context), style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('BMI', style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('latest_status'.tr(context), style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('scans'.tr(context), style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPatientRow(BuildContext context, Patient patient) {
    return InkWell(
      onTap: () => context.go('/patients/${patient.id}'),
      child: Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderGray))),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  PatientAvatar(initials: patient.initials),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('ID: ${patient.id}', style: const TextStyle(color: AppColors.textGray, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text('${patient.age} yrs • ${patient.gender}', style: const TextStyle(fontSize: 13))),
            Expanded(flex: 1, child: Text('${patient.bmi}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: SeverityBadge(severity: patient.latestStatus)),
            Expanded(flex: 2, child: Text('${patient.scanCount} ${'scans'.tr(context)}', style: const TextStyle(fontSize: 13))),
            const Icon(Icons.chevron_right, color: AppColors.textGray, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Showing $total patients', style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
        Row(
          children: [
            _buildPagerButton('Previous', isEnabled: false),
            const SizedBox(width: 8),
            _buildPagerButton('Next', isEnabled: false),
          ],
        ),
      ],
    );
  }

  Widget _buildPagerButton(String label, {required bool isEnabled}) {
    return OutlinedButton(
      onPressed: isEnabled ? () {} : null,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }

  void _showAddPatientModal(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final bmiController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final historyController = TextEditingController();
    String gender = 'Male';
    final isMobile = MediaQuery.of(context).size.width < 1024;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('register_patient'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        content: SizedBox(
          width: isMobile ? MediaQuery.of(context).size.width : 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalField(context, 'full_name'.tr(context), 'John Doe', nameController),
                const SizedBox(height: 16),
                if (isMobile) ...[
                  _buildModalField(context, 'age'.tr(context), '45', ageController, isNumeric: true),
                  const SizedBox(height: 16),
                  _buildModalDropdown(context, 'gender'.tr(context), gender, ['Male', 'Female', 'Other'], (val) => gender = val!),
                ] else
                  Row(
                    children: [
                      Expanded(child: _buildModalField(context, 'age'.tr(context), '45', ageController, isNumeric: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModalDropdown(context, 'gender'.tr(context), gender, ['Male', 'Female', 'Other'], (val) => gender = val!)),
                    ],
                  ),
                const SizedBox(height: 16),
                _buildModalField(context, 'bmi'.tr(context), '24.5', bmiController, isNumeric: true),
                const SizedBox(height: 16),
                _buildModalField(context, 'email'.tr(context), 'john@example.com', emailController),
                const SizedBox(height: 16),
                _buildModalField(context, 'phone'.tr(context), '+1 (555) 000-0000', phoneController),
                const SizedBox(height: 16),
                _buildModalField(context, 'medical_history'.tr(context), 'Hypertension, etc.', historyController, maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(context))),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
                final newPatient = Patient(
                  id: '000${50 + Provider.of<DataProvider>(context, listen: false).patients.length}',
                  name: nameController.text,
                  age: int.tryParse(ageController.text) ?? 0,
                  gender: gender,
                  email: emailController.text,
                  phone: phoneController.text,
                  bmi: double.tryParse(bmiController.text) ?? 0.0,
                  medicalHistory: historyController.text,
                  scanCount: 0,
                  latestStatus: 'Normal',
                  registeredDate: DateTime.now(),
                );
                Provider.of<DataProvider>(context, listen: false).addPatient(newPatient);
                Navigator.pop(context);
              }
            }, 
            child: Text('save_patient'.tr(context))
          ),
        ],
      ),
    );
  }

  Widget _buildModalField(BuildContext context, String label, String hint, TextEditingController controller, {bool isNumeric = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildModalDropdown(BuildContext context, String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
