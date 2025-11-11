import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mgov_apps/features/gov_connect/pages/forget_password_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/home_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/register_page.dart';
import 'package:provider/provider.dart';
import 'package:mgov_apps/features/gov_connect/pages/login_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/onboarding_page.dart';
import '../../core/localization/language_provider.dart';

class GovConnectApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final String? user;

  GovConnectApp({Key? key, required this.hasSeenOnboarding, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context)  {
    // return MaterialApp(
    //   title: "My Gov Connect",
    //   theme: AppTheme.light,
    //   home: AuthModule(), // initial screen
    // );

    // return MaterialApp(
    //   title: "My Gov Connect",
    //   theme: ThemeData(primarySwatch: Colors.blue),
    //   home: Scaffold(
    //     appBar: AppBar(title: Text("Gov Connect")),
    //     body: Center(child: Text("Welcome to Gov Connect")),
    //   ),
    // );

   

    final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      
      GoRoute(
          path: '/',
          builder: (context, state) {

           

          if (!hasSeenOnboarding) {
              return const OnboardingPage();
            }

          if (user != null) {
              return HomePage();
            } else{
              return SignInPage();
            }    

          return SignInPage();

          }
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          return SignInPage();
        },
        
        
        ),
         GoRoute(
        path: '/register',
        builder: (context, state) {
          return SignUpPage();
        },
        
        
        ),

        GoRoute(
        path: '/forget-password',
        builder: (context, state) {
          return ForgetPasswordPage();
        },
        
        
        ),

        GoRoute(
        path: '/home',
        builder: (context, state) {
          return HomePage();
        },
        
        
        )
    ],  
    );

    return ChangeNotifierProvider(
      create: (context) => LanguageProvider()..initialize(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp.router(
            title: 'MyGov Connect',
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            routerConfig: _router,       
          );
        },
      ),
    );
  }
}
