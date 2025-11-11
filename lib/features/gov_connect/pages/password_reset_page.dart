import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';

class PasswordResetPage extends StatefulWidget {
  final String phoneNumber;
  final String otpCode;
  
  const PasswordResetPage({
    super.key,
    required this.phoneNumber,
    required this.otpCode,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}


class _PasswordResetPageState extends State<PasswordResetPage> with TickerProviderStateMixin{

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
 

@override
void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final apiService = ApiService();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await apiService.resetPassword(
        phoneNumber: widget.phoneNumber,
        otpCode: widget.otpCode,
        newPassword: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Password reset successful'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        
        // Navigate to login page
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSignInForm(context),
           
          ],
        ),
      ),
    );
  }


  

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.20, // Adjust height as needed
          decoration: const BoxDecoration(
            //color: Color(0xFF003399), // Deep blue color

              color: Colors.white,
            // borderRadius: BorderRadius.only(
            //   bottomLeft: Radius.circular(80),
            // ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo_transparent.png', 
                height: 80,
              ),
              const SizedBox(height: 20),
              Text(
                "Forget Password",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003399)
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  "Please Enter Your New Password",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF003399)
                  ),
                ),
              ),
              SizedBox(height: 48,),
              //_buildMainTabBar()

            ],
          ),
        ),
      ],
    );
  }

  

  Widget _buildSignInForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child:Form(
      key: _formKey,  
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPasswordField(),
          const SizedBox(height: 24),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Confirm New Password",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword 
                          ? Icons.visibility_off_outlined 
                          : Icons.visibility_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
            ),
          ],
        ),
          const SizedBox(height: 48),
          
           _buildSignInButton(context),
           SizedBox(height: 10,),
         
         
         
          
        ],
      ),
      ),
    );
  }

  

  
  

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _resetPassword();
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF003399),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Confirm Submission",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }


  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "New Password",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.lock_outline),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IconButton(
                icon: Icon(
                  _obscurePassword 
                      ? Icons.visibility_off_outlined 
                      : Icons.visibility_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }

                    // Length check
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }

                    // Uppercase check
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Password must contain at least one uppercase letter';
                    }

                    // Lowercase check
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Password must contain at least one lowercase letter';
                    }

                    // Digit check
                    if (!RegExp(r'\d').hasMatch(value)) {
                      return 'Password must contain at least one digit';
                    }

                    // Special character check
                    if (!RegExp(r'[!@#\$&*~%^(),.?":{}|<>]').hasMatch(value)) {
                      return 'Password must contain at least one special character';
                    }

                    return null; // Valid
                  },
        ),
      ],
    );
  }

  
}




 