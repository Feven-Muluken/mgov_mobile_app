import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.black)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Introduction Section ---
            _buildSectionTitle('Introduction'),
            const Text(
              'MyGov Connect is committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 25),

            // --- Information We Collect Section ---
            _buildSectionTitle('Information We Collect'),
            _buildFeaturePoint(
              title: 'Personal Information',
              content: 'We may collect personal information such as your name, email address, phone number, and user preferences when you register or use certain features of the app.',
              icon: Icons.person_outline,
            ),
            _buildFeaturePoint(
              title: 'Usage Data',
              content: 'We automatically collect information about how you interact with the app, including device information, IP address, and usage patterns to improve our services.',
              icon: Icons.analytics_outlined,
            ),
            _buildFeaturePoint(
              title: 'Location Data',
              content: 'With your permission, we may collect location data to provide region-specific alerts, news, and services relevant to your area.',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 25),

            // --- How We Use Your Information Section ---
            _buildSectionTitle('How We Use Your Information'),
            _buildFeaturePoint(
              title: 'Service Delivery',
              content: 'To provide you with government alerts, news, surveys, and emergency services information tailored to your preferences and location.',
              icon: Icons.notifications_outlined,
            ),
            _buildFeaturePoint(
              title: 'Communication',
              content: 'To send you important updates, notifications, and respond to your inquiries and feedback.',
              icon: Icons.message_outlined,
            ),
            _buildFeaturePoint(
              title: 'Improvement',
              content: 'To analyze usage patterns and improve the app\'s functionality, user experience, and content relevance.',
              icon: Icons.trending_up_outlined,
            ),
            _buildFeaturePoint(
              title: 'Legal Compliance',
              content: 'To comply with applicable laws, regulations, and government requirements.',
              icon: Icons.gavel_outlined,
            ),
            const SizedBox(height: 25),

            // --- Data Sharing Section ---
            _buildSectionTitle('Data Sharing and Disclosure'),
            const Text(
              'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            _buildBulletPoint('With government agencies and departments to provide requested services'),
            _buildBulletPoint('When required by law or to respond to legal processes'),
            _buildBulletPoint('To protect the rights, property, or safety of users or the public'),
            _buildBulletPoint('With service providers who assist in app operations under strict confidentiality agreements'),
            const SizedBox(height: 25),

            // --- Data Security Section ---
            _buildSectionTitle('Data Security'),
            const Text(
              'We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 25),

            // --- Your Rights Section ---
            _buildSectionTitle('Your Rights'),
            _buildFeaturePoint(
              title: 'Access',
              content: 'You have the right to access and review your personal information stored in our systems.',
              icon: Icons.visibility_outlined,
            ),
            _buildFeaturePoint(
              title: 'Correction',
              content: 'You can update or correct your personal information through the app settings or by contacting us.',
              icon: Icons.edit_outlined,
            ),
            _buildFeaturePoint(
              title: 'Deletion',
              content: 'You may request deletion of your account and associated data, subject to legal retention requirements.',
              icon: Icons.delete_outline,
            ),
            _buildFeaturePoint(
              title: 'Opt-Out',
              content: 'You can opt-out of non-essential communications and adjust notification preferences in the app settings.',
              icon: Icons.settings_outlined,
            ),
            const SizedBox(height: 25),

            // --- Data Retention Section ---
            _buildSectionTitle('Data Retention'),
            const Text(
              'We retain your personal information only for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 25),

            // --- Children\'s Privacy Section ---
            _buildSectionTitle('Children\'s Privacy'),
            const Text(
              'Our app is not intended for children under the age of 13. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 25),

            // --- Changes to Privacy Policy Section ---
            _buildSectionTitle('Changes to This Privacy Policy'),
            const Text(
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date. You are advised to review this Privacy Policy periodically for any changes.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 25),

            // --- Contact Information Section ---
            _buildSectionTitle('Contact Us'),
            const Text(
              'If you have any questions or concerns about this Privacy Policy or our data practices, please contact us:',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            _buildContactInfo(
              icon: Icons.email_outlined,
              title: 'Email',
              detail: 'privacy@mygovconnect.gov.et',
            ),
            _buildContactInfo(
              icon: Icons.call_outlined,
              title: 'Phone',
              detail: '+251 11 155 1234',
            ),
            _buildContactInfo(
              icon: Icons.location_on_outlined,
              title: 'Address',
              detail: 'Government Communication Affairs,\nAddis Ababa, Ethiopia',
            ),
            const SizedBox(height: 30),

            // --- Last Updated ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Last Updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFeaturePoint({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: Colors.black87)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




