import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/features/gov_connect/pages/forget_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}


class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin{

  final _formKey = GlobalKey<FormState>();
  late TabController _mainTabController;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _loginUser() async {
    final apiService = ApiService();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await apiService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (response.success && response.data != null) { 
        // Store tokens and user data
        final accessToken = response.data['access'];
        final refreshToken = response.data['refresh'];
        final user = response.data['user'];

        await saveToLocalStorage('access_token', accessToken);
        await saveToLocalStorage('refresh_token', refreshToken);
        await saveToLocalStorage('user_data', jsonEncode(user));
        // Clear guest flag when user logs in
        await removeFromLocalStorage('is_guest');  

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.stringsNoListen.success)),
        );

        await Future.delayed(const Duration(seconds: 1));
        
        // Navigate based on user type
        if (user['user_type'] == 'citizen') {
          context.go('/home');
        } else {
          context.go('/home');
        }
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

@override
void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    // Listen to tab changes to update the UI
    _mainTabController.addListener(() {
      setState(() {
        // Update UI when tab changes
        // Clear the field when switching tabs (only when change completes)
        if (!_mainTabController.indexIsChanging) {
          _usernameController.clear();
        }
      });
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
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
            _buildFooter(),
          ],
        ),
      ),
    );
  }


   Widget _buildMainTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 64),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: TabBar(
        controller: _mainTabController,
        indicator: BoxDecoration(
          color: const Color(0xFF003399),
          borderRadius: BorderRadius.circular(24),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, size: 20),
                SizedBox(width: 8),
                Text(context.strings.phone),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_outlined, size: 20),
                SizedBox(width: 8),
                Text(context.strings.email),
              ],
            ),
          ),
        ],
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
              _buildLanguageSelector(),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo_transparent.png', 
                height: 80,
              ),
              const SizedBox(height: 20),
              Text(
                context.strings.signin,
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
                  context.strings.pleaseLogin,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF003399)
                  ),
                ),
              ),
              SizedBox(height: 48,),
              _buildMainTabBar()

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
        child: GestureDetector(
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
      child:Form(
      key: _formKey,  
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUsernameField(),
          const SizedBox(height: 24),
          _buildPasswordField(),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle forgot password logic
                //context.go('/forget-password');
                Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPasswordPage()));
              },
              child: Text(
                context.strings.forgotPassword,
                style: const TextStyle(
                  color: Color(0xFF003399),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
           _buildSignInButton(context),
           SizedBox(height: 10,),
          Center(
            child: Text(context.strings.donothaveAccount, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          _buildGuestButton(context),
           const SizedBox(height: 24),
         
          const SizedBox(height: 16),
          Center(
            child: Text(context.strings.orContinueWithLimitedFeatures, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          _buildSignUpButton(context),
        ],
      ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.strings.password,
          style: const TextStyle(
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
              return context.strings.passwordRequired;
            }
            
            // Trim whitespace and check if empty
            final trimmedValue = value.trim();
            if (trimmedValue.isEmpty) {
              return context.strings.passwordRequired;
            }
            
            // Check minimum length
            if (trimmedValue.length < 6) {
              return context.strings.passwordMinLength;
            }
            
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    // Determine if email tab is selected (index 1)
    final isEmailTab = _mainTabController.index == 1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEmailTab ? context.strings.email : context.strings.userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          keyboardType: isEmailTab ? TextInputType.emailAddress : TextInputType.name,
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
                isEmailTab ? Icons.email_outlined : Icons.supervised_user_circle,
                color: Colors.grey[600],
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintText: isEmailTab 
                ? context.strings.enterEmailAddress 
                : context.strings.enterUserName,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return isEmailTab 
                  ? 'Email is required'
                  : context.strings.phoneNumberRequired;
            }
            
            // Email validation
            if (isEmailTab) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return context.strings.validEmailAddress;
              }
            }
            
            // Phone/Username validation
            if (!isEmailTab) {
              // Remove spaces and common phone formatting characters
              //final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
              
              // Check if it's a valid phone number (digits only, 9-15 digits)
              // if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
              //   return 'Please enter a valid phone number';
              // }
              
              // Check minimum length for phone number
              // if (cleanedValue.length < 9) {
              //   return 'Phone number must be at least 9 digits';
              // }
              
              // Check maximum length for phone number
              // if (cleanedValue.length > 15) {
              //   return 'Phone number must not exceed 15 digits';
              // }

              if (value == null || value.isEmpty){
                  context.strings.fullNameRequired;
              } else {
                null;
              }
              
            }
            
            return null;
          },
        ),
      ],
    );
  }

  // Widget _buildPasswordField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         "Password",
  //         style: TextStyle(
  //           fontWeight: FontWeight.bold,
  //           color: Colors.black87,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       TextFormField(
  //         controller: _passwordController,
  //         obscureText: true,
  //         decoration: InputDecoration(
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(10),
  //             borderSide: BorderSide.none,
  //           ),
  //           filled: true,
  //           fillColor: Colors.grey[200],
  //           prefixIcon: const Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 16.0),
  //             child: Icon(Icons.lock_outline),
  //           ),
  //           suffixIcon: const Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 16.0),
  //             child: Icon(Icons.visibility_off_outlined),
  //           ),
  //         ),
  //        validator: (value) {
  //                       if (value == null || value.isEmpty) {
  //                         return 'Password is required';
  //                       } else if (value.length < 6) {
  //                         return 'Password must be at least 6 characters';
  //                       }
  //                       return null;
  //                     },
  //       ),
  //     ],
  //   );
  // }


  

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
           _loginUser();
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF003399),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        context.strings.signin,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        // Set guest flag in local storage
        await saveToLocalStorage('is_guest', 'true');
        // Navigate to home page
        context.go('/home');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Color(0xFF003399)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        context.strings.continueAsGuest,
        style: const TextStyle(fontSize: 18, color: Color(0xFF003399)),
        
      ),
    );
  }

  Widget _buildGuestButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        context.go('/register');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Color(0xFF003399)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        context.strings.signup,
        style: const TextStyle(fontSize: 18, color: Color(0xFF003399)),
        
      ),
    );
  }


  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Text(
        context.strings.footerText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
    );
  }
}