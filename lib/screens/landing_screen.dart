import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/translation_service.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgLight,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(context, isMobile),
              SizedBox(height: isMobile ? 40 : 80),
              _buildHeroSection(context, isMobile),
              SizedBox(height: isMobile ? 60 : 100),
              _buildFeaturesGrid(context, isMobile),
              SizedBox(height: isMobile ? 80 : 120),
              _buildFooter(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48, 
        vertical: isMobile ? 24 : 32
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.masks, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AeroDiag',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Text(
                    'OSA DIAGNOSTICS',
                    style: TextStyle(
                      fontSize: 8,
                      letterSpacing: 2,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => context.go('/sign-in'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24, 
                vertical: isMobile ? 12 : 16
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isMobile ? 'Login' : 'doctor_portal_login'.tr(context),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'ai_powered_badge'.tr(context),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'landing_headline'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 32 : 56,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'landing_subheadline'.tr(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 15 : 18,
                color: AppColors.textGray,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: isMobile ? double.infinity : null,
              child: ElevatedButton(
                onPressed: () => context.go('/sign-in'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'access_workspace'.tr(context),
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildFeatureCard(
              Icons.bolt,
              'ai_powered_analysis'.tr(context),
              'ai_powered_desc'.tr(context),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              Icons.analytics_outlined,
              'realtime_diagnostics'.tr(context),
              'realtime_desc'.tr(context),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              Icons.shield_outlined,
              'secure_compliant'.tr(context),
              'secure_desc'.tr(context),
            ),
          ],
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          Expanded(
            child: _buildFeatureCard(
              Icons.bolt,
              'ai_powered_analysis'.tr(context),
              'ai_powered_desc'.tr(context),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildFeatureCard(
              Icons.analytics_outlined,
              'realtime_diagnostics'.tr(context),
              'realtime_desc'.tr(context),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildFeatureCard(
              Icons.shield_outlined,
              'secure_compliant'.tr(context),
              'secure_desc'.tr(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 24),
          Text(
            'copyright'.tr(context),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textGray, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
