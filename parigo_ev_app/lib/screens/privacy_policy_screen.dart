import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Privacy Matters', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(
              'At Parigo EV, your privacy is a top priority. As a growing startup, '
              'building trust with our users is the foundation of our business.\n\n'
              '1. Information We Collect\n'
              'We collect your mobile number for authentication. For Customers, we collect '
              'foreground location data to enable ride dispatching. For Drivers, we explicitly '
              'collect location data in the background to enable continuous ride assignment and live '
              'tracking for customers even when the app is closed. We also access the device camera '
              'and photo gallery when you choose to upload identity documents or profile photos.\n\n'
              '2. How We Use Your Data\n'
              'Your data is solely used to connect you with drivers/passengers, estimate fares, '
              'and improve our platform. We do not sell your personal data to third parties.\n\n'
              '3. Data Security\n'
              'We use industry-standard security measures to protect your information, including '
              'secure cloud storage for your identity documents. As an agile startup, we regularly '
              'update our systems to patch vulnerabilities.\n\n'
              '4. Your Rights & Data Deletion\n'
              'You have the right to request the complete deletion of your account and all associated '
              'data at any time. Simply email us at parigoev@gmail.com to initiate this request.\n\n'
              'We value your trust and are committed to protecting your privacy as we build '
              'the future of sustainable transport.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
