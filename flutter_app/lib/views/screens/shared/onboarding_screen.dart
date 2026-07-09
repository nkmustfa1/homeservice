import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _currentLanguage = "AR";

  final Map<String, List<Map<String, String>>> onboardingData = {
    "EN": [
      {
        "image": 'assets/images/onboarding/onboarding1.png',
        "title": "WELCOME TO FIXIT",
        "description":
            "Simply touch and pick to have all of your products and services delivered to your door.",
      },
      {
        "image": 'assets/images/onboarding/onboarding2.png',
        "title": "FIND YOUR SERVICES",
        "description":
            "Select a service from the list that correlates with your needs and then move forward.",
      },
      {
        "image": 'assets/images/onboarding/onboarding3.png',
        "title": "BOOK YOUR DATE AND TIME",
        "description":
            "Choose an appropriate time and day, then reserve your service by including an address.",
      },
    ],
    "AR": [
      {
        "image": 'assets/images/onboarding/onboarding1.png',
        "title": "مرحبًا بك في خدماتي",
        "description":
            "ببساطة، المس واختر لتوصيل جميع منتجاتك وخدماتك إلى باب منزلك.",
      },
      {
        "image": 'assets/images/onboarding/onboarding2.png',
        "title": "ابحث عن خدماتك",
        "description": "اختر خدمة من القائمة التي تتوافق مع احتياجاتك ثم تابع.",
      },
      {
        "image": 'assets/images/onboarding/onboarding3.png',
        "title": "احجز التاريخ والوقت",
        "description":
            "اختر الوقت واليوم المناسبين، ثم قم بحجز خدمتك مع إضافة العنوان.",
      },
    ],
  };

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingCompleted', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          isLoggedIn: false,
          userId: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentData = onboardingData[_currentLanguage]!;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: currentData.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButtonHideUnderline(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: DropdownButton<String>(
                                value: _currentLanguage,
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                                items: [
                                  DropdownMenuItem(
                                    value: "EN",
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/flags/usa_flag.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                        SizedBox(width: 5),
                                        Text("EN"),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "AR",
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/flags/sa_flag.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                        SizedBox(width: 5),
                                        Text("AR"),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _currentLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _pageController
                                  .jumpToPage(currentData.length - 1);
                            },
                            child: Text(
                              _currentLanguage == "EN" ? "SKIP" : "تخطي",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF5464FD),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Image.asset(
                      currentData[index]["image"]!,
                      height: 200,
                    ),
                    SizedBox(height: 20),
                    Text(
                      currentData[index]["title"]!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        currentData[index]["description"]!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              currentData.length,
              (index) => buildDot(index),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _currentPage == 0
                      ? null
                      : () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                  child: CircleAvatar(
                    backgroundColor: _currentPage == 0
                        ? Colors.grey[300]
                        : Color(0xFF5464FD),
                    radius: 30,
                    child: Icon(
                      Icons.arrow_back,
                      color: _currentPage == 0 ? Colors.grey : Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_currentPage == currentData.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Color(0xFF5464FD),
                    radius: 30,
                    child: Icon(
                      _currentPage == currentData.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(right: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Color(0xFF5464FD) : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
