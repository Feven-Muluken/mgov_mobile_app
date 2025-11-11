import 'package:flutter/material.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/features/gov_connect/pages/password_reset_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}


class _ForgetPasswordPageState extends State<ForgetPasswordPage> with TickerProviderStateMixin{

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  String? phone;

  Future<void> _verifyOtp(BuildContext context) async {
  final otp = _otpControllers.map((c) => c.text).join();
 

  if (otp.length != 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.stringsNoListen.error)),
    );
    return;
  }

  final apiService = ApiService();

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  

  try {
    final response = await apiService.verifyOtp(  
      phone: "+251${(_phoneNumberController.text.trim())}",
      otp: otp,
    );
    
    // Close loading dialog
    if (mounted) Navigator.pop(context);
    
    if (response.success) {
      // Close OTP dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.stringsNoListen.success)),
      );

      final phoneNumber = "+251${(_phoneNumberController.text.trim())}";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordResetPage(
            phoneNumber: phoneNumber,
            otpCode: otp,
          ),
        ),
      );  // redirect after verification
    } else {
      // Handle different error types
      String errorMessage = response.message;
      
      // Check if it's a parsing error (server returned non-JSON response)
      if (errorMessage.toLowerCase().contains('failed to parse response')) {
        // Extract server error from the message if available
        if (errorMessage.contains('MultipleObjectsReturned')) {
          errorMessage = 'Server error: Multiple OTP records found. Please contact support.';
        } else if (response.statusCode != null && response.statusCode == 500) {
          errorMessage = 'Server error: Unable to verify OTP. Please try again or contact support.';
        } else {
          errorMessage = 'Failed to parse response from server';
        }
      } else if (response.statusCode != null && response.statusCode == 500) {
        // Server error but not a parse error
        errorMessage = 'Server error: ${response.message}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  } catch (e) {
    // Close loading dialog if still open
    if (mounted) Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${context.stringsNoListen.error} $e")),
    );
  }
}
 
  

  void _forgetPassword() async {
    final apiService = ApiService();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await apiService.forgetPassword(
        phone: "+251${(_phoneNumberController.text.trim())}"
        
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (response.success ) { 
         _showOtpDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.stringsNoListen.success)),
        );

        await Future.delayed(const Duration(seconds: 1));
        
        // Navigate based on user type
        
         
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${context.stringsNoListen.error} ${response.message}")),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${context.stringsNoListen.error} $e")),
      );
    }
  }

  void _showOtpDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, 
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(context.strings.confirmPhoneNumber),
        content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.strings.otpCodeMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // OTP Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Flexible(
                  child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: _otpControllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: "", 
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                  ),
                );
              }),
            ),
          ],
        ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _verifyOtp(context);
            },
            child: Text(context.strings.verify),
          ),
          TextButton(
            onPressed: () {
              _resendOtp(context);
            },
            child: Text(context.strings.resendCodeIn30s),
          ),
        ],
      );
    },
  );
  }

  Future<void> _resendOtp(BuildContext context) async {
    
  // if (registeredPhone == null || registeredPhone!.isEmpty) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(context.stringsNoListen.error)),
  //   );
  //   return;
  // }

  final apiService = ApiService();

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final response = await apiService.resendOtp(
      phoneNumber: "+251${(_phoneNumberController.text.trim())}"
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message'] ?? context.stringsNoListen.success),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${context.stringsNoListen.error} ${response.message}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // Close loading dialog if still open
    if (mounted) Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${context.stringsNoListen.error} $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

@override
void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
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
                  "Please Enter Your Phone Number",
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
          _buildUsernameField(),
          const SizedBox(height: 48),
          
           _buildSignInButton(context),
           SizedBox(height: 10,),
         
         
         
          
        ],
      ),
      ),
    );
  }

  

  Widget _buildUsernameField() {
    // Determine if email tab is selected (index 1)
    // final isEmailTab = _mainTabController.index == 1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.strings.phone,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
               Icons.phone,
                color: Colors.grey[600],
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintText: "Enter Phone Number",
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.strings.phoneNumberRequired;
            }
            
            // Remove spaces and common phone formatting characters
            final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
            
            // Check if it's a valid phone number (digits only)
            if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
              return 'Please enter a valid phone number';
            }
            
            // Check minimum length for phone number
            if (cleanedValue.length < 9) {
              return 'Phone number must be at least 9 digits';
            }
            
            // Check maximum length for phone number
            if (cleanedValue.length > 15) {
              return 'Phone number must not exceed 15 digits';
            }
            
            return null;
          },
        ),
      ],
    );
  }

  

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _forgetPassword();
          
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
        "Send an OTP",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  
}

 