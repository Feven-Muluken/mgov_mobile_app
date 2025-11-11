import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';


class SignUpPage extends StatefulWidget{

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedGender;

  Map<String, dynamic>? responseData;
  String? registeredPhone;


  //final TextEditingController otpController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());

 


Future<Map<String, dynamic>?> getUserDataFromLocalStorage() async {
  final jsonString = await getFromLocalStorage('response_data');
  if (jsonString != null && jsonString.isNotEmpty) {
    //return jsonDecode(jsonString) as Map<String, dynamic>;
     setState(() {
        responseData = jsonDecode(jsonString) as Map<String, dynamic>;
      });
  }
  return null;
}

void _registerUser() async {
  final apiService = ApiService();
  
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final response = await apiService.register(
      userName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone_number: "+251${(_phoneController.text.trim())}",
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      userType: 'citizen',
      termAccepted: true,
      privacyConsent: true,
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (response.success && response.data != null) {
      setState(() {
        responseData = response.data;
        registeredPhone = "+251${(_phoneController.text.trim())}";
      });

      // Save response data
      await saveToLocalStorage('response_data', jsonEncode(response.data));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.stringsNoListen.success)),
      );

      // Clear form
      _formKey.currentState?.reset();
      _fullNameController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      await Future.delayed(const Duration(seconds: 1));

      // Show OTP dialog
      _showOtpDialog(context);
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
      phone: registeredPhone!.toString(),
      otp: otp,
    );
    print(response);
    print(registeredPhone!.toString(),);
    print(otp,);
    // Close loading dialog
    if (mounted) Navigator.pop(context);
    
    if (response.success) {
      // Close OTP dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.stringsNoListen.success)),
      );

      context.go('/login'); // redirect after verification
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

Future<void> _resendOtp(BuildContext context) async {
  if (registeredPhone == null || registeredPhone!.isEmpty) {
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
    final response = await apiService.resendOtp(
      phoneNumber: registeredPhone!,
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

// Future<void> _verifyOtp(BuildContext context) async {
//   final otp = _otpControllers.map((c) => c.text).join(); 

  

//   if (otp.length != 6) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Enter a valid 6-digit code")),
//     );
//     return;
//   }

//   final url = Uri.parse('http://196.189.50.35:8080/api/auth/verify-otp/');
//   final response = await http.post(
//     url,
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({
//       "phone": responseData!['phone'], 
//       "otp": otp,
//     }),
//   );

//   if (response.statusCode == 200) {
//     Navigator.pop(context); // close OTP dialog
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("OTP Verified Successfully!")),
//     );
//     context.go('/login'); // redirect after verification
//   } else {
//     final error = jsonDecode(response.body);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: ${error.toString()}")),
//     );
//   }
// }
  



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

@override
void initState() {
    // TODO: implement initState
    super.initState();
    getUserDataFromLocalStorage();
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
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.25, // Adjust height as needed
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
              _buildLanguageSelector(),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo_transparent.png', 
                height: 80,
              ),
              const SizedBox(height: 20),
              Text(
                context.strings.signup,
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
                  context.strings.createAccount,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF003399)
                  ),
                ),
              ),

              
            ],
          ),
        ),
      ],
    );
  }

 

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 24.0),
      child: Align(
        alignment: Alignment.centerRight,
        child:GestureDetector(
        onTap: () {
          context.languageProvider.toggleLanguage();
        },  
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                const Icon(Icons.language, color: Colors.black54, size: 18),
                const SizedBox(width: 8),
                Text(
                  context.currentLanguage.name,
                  style: const TextStyle(color: Colors.black54),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black54),
              ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
      key: _formKey,  
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${context.strings.userName}(*)",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: context.strings.enterUserName,
              ),
              validator: (value) =>
                          value == null || value.isEmpty ? context.strings.fullNameRequired : null,
            ),
          ],
        ),

          const SizedBox(height: 24,),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${context.strings.firstName}(*)",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: context.strings.enterFirstName,
              ),
              validator: (value) =>
                          value == null || value.isEmpty ? context.strings.firstNameRequired : null,
            ),
          ],
        ),

          const SizedBox(height: 24,),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${context.strings.lastName}(*)",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: context.strings.enterLastName,
              ),
              validator: (value) =>
                          value == null || value.isEmpty ? context.strings.lastNameRequired : null,
            ),
          ],
        ),

          const SizedBox(height: 24,),
          _buildPhoneNumberField(),
          const SizedBox(height: 24),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.strings.emailAddressOptional,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: context.strings.enterEmailAddress,
              ),
              
              validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return context.strings.validEmailAddress;
                          }
                        }
                        return null; 
                      },
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // children: [
          //   Text(
          //     context.strings.gender,
          //     style: const TextStyle(
          //       fontWeight: FontWeight.bold,
          //       color: Colors.black87,
          //     ),
          //   ),

          //   const SizedBox(height: 8),
          // DropdownButtonFormField<String>(
          //             value: _selectedGender,
          //             items: [
          //               DropdownMenuItem(
          //                 value: 'male',
          //                 child: Text(context.strings.male),
          //               ),
          //               DropdownMenuItem(
          //                 value: 'female',
          //                 child: Text(context.strings.female),
          //               ),
          //             ],
          //             onChanged: (value) {
          //               setState(() {
          //                 _selectedGender = value;
          //               });
          //             },
          //             decoration: InputDecoration(
          //                 border: OutlineInputBorder(
          //                   borderRadius: BorderRadius.circular(10),
          //                   borderSide: BorderSide.none,
          //                 ),
          //                 filled: true,
          //                 fillColor: Colors.grey[200],
          //                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          //                 hintText: "Choose Gender",
          //           ),
                    
          //           ),
          //         ],
          // ),
          // const SizedBox(height: 24,),
          _buildPasswordField(),
          const SizedBox(height: 24),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Repeat Password(*)",
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle forgot password logic
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color(0xFF003399),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSignUpButton(context),
          const SizedBox(height: 16),
          const Center(
            child: Text("Have an account?", style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          _buildSignInButton(context),
        ],
      ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${context.strings.phoneNumber}(*)",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("+251", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            hintText: context.strings.enterPhoneNumber,
          ),
          validator: (value) {
                        if (value == null) {
                          return context.strings.phoneNumberRequired;
                        }
                        return null;
                      },
        ),
      ],
    );
  }


  

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password(*)",
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

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
              _registerUser();
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
        "Sign Up",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        context.go('/login');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Color(0xFF003399)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Sign In",
        style: TextStyle(fontSize: 18, color: Color(0xFF003399)),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Text(
        "Designed & developed by 360ground\nand Ministry of innovation and technology (MINT)",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
    );
  }
}