import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';



class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  // Convert to a getter method so we can access context
  // Using stringsNoListen because getters can be called from event handlers
  List<Map<String, String>> get onboardingData => [
    {
      "title": context.stringsNoListen.welcome,
      "subtitle": context.stringsNoListen.onboardingDesc1,
      "image": "assets/images/gov_con_onboa_img_1.png",
    }, 
    {
      "title": context.stringsNoListen.onboardingTitle2,
      "subtitle": context.stringsNoListen.onboardingDesc2,
      "image": "assets/images/gov_con_onboa_img_2.png",
    },
    {
      "title": context.stringsNoListen.onboardingTitle3,
      "subtitle": context.stringsNoListen.onboardingDesc3,
      "image": "assets/images/gov_con_onboa_img_3.png",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() async {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Handle navigation to the next screen (e.g., login or home page)
      // print("Onboarding complete!");

      context.go('/login');

      
      var settingsBox = await Hive.openBox('settings');
      await settingsBox.put('hasSeenOnboarding', true);
   

    // // ✅ Navigate to next screen
    // final userProvider = Provider.of<UserProvider>(context, listen: false);
    // if (userProvider.user != null) {
    //   context.go('/complaint'); // Home for logged in users
    // } else {
    //   context.go('/login');
    }
    }
  

  void _onSkip() {
    Future<void> _completeOnboarding(BuildContext context) async {
    var settingsBox = await Hive.openBox('settings');  
    await settingsBox.put('hasSeenOnboarding', true); // ✅ Save flag

    // Go to login (or home) after onboarding
    context.go('/login'); // Change '/login' to '/home' if user already logged in
  }
  _completeOnboarding(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
      
        child: Column(
          children: [
           Expanded(
            flex: 7,
            child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPageContent(onboardingData[index]);
                },
              ),
            ),
            

          _buildFooter(),
           
        
            
          ],
        ),
        ),
        
     
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              // Toggle between English and Amharic
              context.languageProvider.toggleLanguage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
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
        ],
      ),
    );
  }

  // Widget _buildPageContent(Map<String, String> data) {
  //   return Column(
  //     children: [
  //       const Spacer(flex: 1),
  //       _buildHeroSection(data),
  //       const Spacer(flex: 1),
  //     ],
  //   );
  // }

  Widget _buildPageContent(Map<String, String> data) {
    return Stack(
      children: [
        // Blue container with custom clipper for the curved bottom-left corner
        Positioned(
          top: 0,
          left: 0,
          right: 0,

          height: MediaQuery.of(context).size.height * 0.6,

            child: Container(
              decoration: const BoxDecoration(
              color: Color(0xFF003399), // Deep blue color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
              ),
            ),
            ),
          ),
        
        // Onboarding content
        SafeArea(
          child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              // Expanded(
              //   child: 
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/logo_transparent.png', 
                      height: 80,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      data["title"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        data["subtitle"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    //const Spacer(),
                    const SizedBox(height: 48),
                    Image.asset(
                      data["image"]!,
                      height: MediaQuery.of(context).size.height * 0.35,
                      //fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              //),
            ],
          ),
          ),
        ),
      ],
      
    );
  }


  

  Widget _buildFooter() {
    // double screenHeight = MediaQuery.of(context).size.height;
    // double padding = screenHeight < 600 ? 8.0 : 24.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      //padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => _buildDot(index),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _onSkip,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF003399)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    context.strings.skip,
                    style: const TextStyle(fontSize: 18, color: Color(0xFF003399)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onNextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF003399),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == onboardingData.length - 1 
                            ? context.strings.start 
                            : context.strings.next,
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.strings.footerText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF003399) : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

}

