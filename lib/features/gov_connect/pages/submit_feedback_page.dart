import 'package:flutter/material.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import '../core/api_service.dart';

// --- Data Model (for potential categories) ---
final List<String> feedbackCategories = [
  'app_feedback',
  'general_inquiry',
  'service_issue',
  'bug_report',
  'feature_request',
  'complaint',
];

// Category display mapping
final Map<String, String> categoryDisplayNames = {
  'app_feedback': 'App Feedback',
  'general_inquiry': 'General Inquiry',
  'service_issue': 'Issue with Service',
  'bug_report': 'Bug Report',
  'feature_request': 'Feature Request',
  'complaint': 'Complaint',
};

// --- The Submit Feedback Widget ---

class SubmitFeedbackPage extends StatefulWidget {
  const SubmitFeedbackPage({super.key});

  @override
  State<SubmitFeedbackPage> createState() => _SubmitFeedbackPageState();
}

class _SubmitFeedbackPageState extends State<SubmitFeedbackPage> {
  bool _isAnonymous = false;
  String? _selectedCategory;
  String? _attachedFileName; // Mock for file attachment display
  bool _isSubmitting = false; // Loading state

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController(text: 'Jane Doe');
  final TextEditingController _emailController = TextEditingController(text: 'jane.doe@example.com');
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Helper to simulate file attachment
  void _attachFile() {
    setState(() {
      // In a real app, this would open a file picker
      _attachedFileName = 'attachment_photo.jpeg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File selected: $_attachedFileName')),
    );
  }

  // Handle submission
  Future<void> _submitFeedback() async {
    // Basic validation check
    if (_subjectController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields (*).')),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get token from local storage
      final token = await getFromLocalStorage('access_token');
      
      if (token == null) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to submit feedback'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Create API service instance
      final apiService = ApiService();
      
      // Submit feedback to API
      final response = await apiService.submitFeedback(
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        category: _selectedCategory!,
        appName: 'my_gov_connect',
        isAnonymous: _isAnonymous,
        token: token,
      );

      if (response.success) {
        // Clear form fields
        _subjectController.clear();
        _messageController.clear();
        setState(() {
          _selectedCategory = null;
          _isAnonymous = false;
        });

        // Show success message and close modal
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.data != null && response.data['message'] != null
                    ? response.data['message']
                    : response.message ?? 'Feedback submitted successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Show error message
        String errorMessage = response.message ?? 'Failed to submit feedback';
        
        // Try to extract error from response data
        if (response.data != null && response.data['errors'] != null) {
          final errors = response.data['errors'];
          if (errors is Map) {
            errorMessage = errors.values.first is List
                ? errors.values.first[0]
                : errors.values.first.toString();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Handle network or other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We wrap the form in a Center and a Card to match the rounded modal look
    return Scaffold(
      appBar: AppBar(
        title: const Text(
                  'Submit Feedback',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        leading: IconButton(onPressed: (){
         Navigator.of(context).pop();
        }, icon: Icon(Icons.arrow_back)),        
      ),
      body: Container(
        color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                
                const SizedBox(height: 4),
                const Text(
                  'Let us know how we can improve.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 25),

                // Anonymous Toggle
                _buildAnonymousToggle(),
                const SizedBox(height: 20),

                // Name Field (Disabled if anonymous)
                _buildTextField(
                  label: 'Name',
                  controller: _nameController,
                  enabled: !_isAnonymous,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 15),

                // Email Field (Disabled if anonymous)
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  enabled: !_isAnonymous,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),

                // Subject Field (Required)
                _buildTextField(
                  label: 'Subject *',
                  controller: _subjectController,
                  hint: 'e.g., Issue with service',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),

                // Category Dropdown (Required)
                _buildCategoryDropdown(),
                const SizedBox(height: 15),

                // Message Field (Required, Multi-line)
                _buildMessageField(),
                const SizedBox(height: 20),

                // Attachment Area
                // _buildAttachmentArea(),
                // const SizedBox(height: 25),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitting ? Colors.grey : Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Submitting...', style: TextStyle(fontSize: 16)),
                          ],
                        )
                      : const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
      ),
    );
        
      
    
  }

  // --- Widget Builders ---

  Widget _buildAnonymousToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Submit Anonymously',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: _isAnonymous,
          onChanged: (bool value) {
            setState(() {
              _isAnonymous = value;
            });
          },
          activeColor: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: enabled ? Colors.grey.shade300 : Colors.grey.shade200),
            ),
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category *',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select a category'),
              value: _selectedCategory,
              icon: const Icon(Icons.keyboard_arrow_down),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: feedbackCategories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(categoryDisplayNames[value] ?? value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Message *',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _messageController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe your feedback in detail...',
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachment',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: _attachFile,
          child: DottedBorderContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_attachedFileName == null)
                  const Icon(Icons.cloud_upload_outlined, size: 35, color: Colors.grey),
                if (_attachedFileName != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.insert_drive_file, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        _attachedFileName!,
                        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Drag & drop or click to upload',
                    style: TextStyle(color: Colors.grey),
                  ),
                if (_attachedFileName == null)
                  const Text(
                    'PDF, JPEG, PNG (Max 5MB)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Custom Dotted Border Container Widget (for attachment area) ---
// Note: This requires a package like 'dotted_border' in a real app,
// but for a purely visual mock, we can use a custom painter or simple border.
// Here we simulate the look using an existing package structure for simplicity.

class DottedBorderContainer extends StatelessWidget {
  final Widget child;

  const DottedBorderContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid, // Simple solid border for this example
          width: 2,
        ),
      ),
      child: Center(child: child),
    );
  }
}