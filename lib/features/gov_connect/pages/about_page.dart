import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
        title: const Text('About MyGov Connect', style: TextStyle(color: Colors.black)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Welcome Section ---
            _buildSectionTitle('Welcome'),
            const Text(
              'Welcome to My Gov Connect, the official mobile application of the government, designed to bring you closer to the information and services that matter. This platform is a flagship initiative to foster transparency, enhance public engagement, and ensure every citizen has direct access to timely and accurate government communications.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // --- Mission Section ---
            _buildSectionTitle('Our Core Mission'),
            const Text(
              'Our core mission is to create a single, reliable, and accessible digital channel for all official government news, announcements, and services. We aim to empower citizens by keeping them informed, safe, and involved in the national dialogue.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            
            // --- Ownership & Management ---
            _buildSectionTitle('Ownership & Technology'),
            _buildInfoCard(
              title: 'Owned and Managed by:',
              content: 'Government Communication Affairs (GCA)',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              title: 'Powered by:',
              content: 'Ministry of Innovation and Technology (MInT), ensuring a secure, robust, and user-friendly experience for all.',
              icon: Icons.code,
            ),
            const SizedBox(height: 25),

            // --- What We Do Section ---
            _buildSectionTitle('What We Do'),
            _buildFeaturePoint(
              title: 'Inform',
              content: 'We deliver verified news and announcements directly from government departments, customized to your region and interests.',
              icon: Icons.article_outlined,
            ),
            _buildFeaturePoint(
              title: 'Alert',
              content: 'We provide critical real-time notifications for emergencies, public safety, and important service updates to help you stay prepared.',
              icon: Icons.notifications_active_outlined,
            ),
            _buildFeaturePoint(
              title: 'Assist',
              content: 'Our emergency services directory provides instant access to help when you need it most.',
              icon: Icons.help_outline,
            ),
            _buildFeaturePoint(
              title: 'Engage',
              content: 'We offer a platform for you to share your feedback and participate in public surveys and polls, making your voice an essential part of the governance process.',
              icon: Icons.people_alt_outlined,
            ),
            const SizedBox(height: 25),

            // --- Contact Information Section ---
            _buildSectionTitle('Contact Information'),
            _buildContactInfo(
              icon: Icons.email_outlined,
              title: 'Email',
              detail: 'support@mygovconnect.gov.et',
            ),
            _buildContactInfo(
              icon: Icons.call_outlined,
              title: 'Phone',
              detail: '+251 11 155 1234 (GCA Headquarters)',
            ),
            _buildContactInfo(
              icon: Icons.location_on_outlined,
              title: 'Address',
              detail: 'Government Communication Affairs,\nAddis Ababa, Ethiopia',
            ),
            const SizedBox(height: 30),

            // --- Footer Commitment ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'We are committed to continuously improving this platform to better serve the needs of the public. Thank you for being a part of our connected community.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Reusable Widget Builders ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePoint({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.grey,
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}