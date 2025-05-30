import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:farmwisely/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmwisely/screens/home.dart';
import 'package:farmwisely/screens/my_farm.dart';
import 'package:farmwisely/screens/analytics.dart';
import 'package:farmwisely/screens/settings.dart';
import 'package:farmwisely/screens/ai_chat.dart';
import 'package:farmwisely/screens/help.dart';
import 'package:farmwisely/screens/recommendations.dart';
import 'package:farmwisely/screens/weather.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  final bool isLoggedIn = token != null;

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedPageIndex = 0;
  // Create a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // Callback function to update selectedPageIndex
  void onPageChanged(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmwisely',
      routes: {
        '/chat': (context) => AiChatScreen(), // Register the additional page
        '/help': (context) => HelpScreen(),
        '/recommendations': (context) => RecommendationsScreen(),
        '/weather': (context) => WeatherScreen(),
      },
      home: widget.isLoggedIn
          ? Scaffold(
              key: scaffoldKey,
              drawer: Drawer(
                backgroundColor: AppColors.background,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                      ),
                      child: Center(
                        child: Text(
                          'Farmwisely',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home_rounded),
                      title: const Text('Home'),
                      onTap: () {
                        onPageChanged(0);
                        scaffoldKey.currentState
                            ?.closeDrawer(); // Close the drawer
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.grass),
                      title: const Text('My Farm'),
                      onTap: () {
                        onPageChanged(1);
                        scaffoldKey.currentState
                            ?.closeDrawer(); // Close the drawer
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.insert_chart),
                      title: const Text('Analytics'),
                      onTap: () {
                        onPageChanged(2);
                        scaffoldKey.currentState
                            ?.closeDrawer(); // Close the drawer
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () {
                        onPageChanged(3);
                        scaffoldKey.currentState
                            ?.closeDrawer(); // Close the drawer
                      },
                    ),
                    Divider(
                      color: AppColors.grey,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    ListTile(
                      title: const Text('Chat'),
                      onTap: () {
                        Navigator.pushNamed(context, '/chat');
                        scaffoldKey.currentState
                            ?.closeDrawer(); // Close the drawer
                      },
                    ),
                    ListTile(
                      title: const Text('Recommendations'),
                      onTap: () {
                        Navigator.pushNamed(context, '/recommendations');
                        scaffoldKey.currentState
                            ?.closeDrawer(); // Close the drawer
                      },
                    ),
                    ListTile(
                      title: const Text('Weather Forcast'),
                      onTap: () {
                        Navigator.pushNamed(context, '/weather');
                        scaffoldKey.currentState
                            ?.closeDrawer(); // Close the drawer
                      },
                    ),
                    ListTile(
                      title: const Text('Help'),
                      onTap: () {
                        Navigator.pushNamed(context, '/help');
                        scaffoldKey.currentState
                            ?.closeDrawer(); // Close the drawer
                      },
                    ),
                  ],
                ),
              ),
              backgroundColor: const Color.fromRGBO(199, 229, 200, 1),
              appBar: widget.isLoggedIn
                  ? selectedPageIndex == 0
                      ? AppBar(
                          backgroundColor:
                              const Color.fromRGBO(164, 213, 166, 1),
                          leading: IconButton(
                            onPressed: () {
                              scaffoldKey.currentState
                                  ?.openDrawer(); // Open the drawer
                            },
                            icon: const Icon(Icons.menu),
                          ),
                          title: const Center(
                            child: Text('Farmwisely'),
                          ),
                          actions: [
                            IconButton(
                              onPressed: () {
                                onPageChanged(3);
                              },
                              icon: const Icon(Icons.account_circle_sharp),
                            )
                          ],
                        )
                      : null
                  : null,
              body: widget.isLoggedIn
                  ? [
                      Home(onPageChange: onPageChanged), // Pass the callback
                      MyFarm(onPageChange: onPageChanged),
                      Analytics(
                        onPageChange: onPageChanged,
                      ),
                      Settings(onPageChange: onPageChanged),
                    ][selectedPageIndex]
                  : const LoginScreen(),
              bottomNavigationBar: widget.isLoggedIn
                  ? NavigationBar(
                      backgroundColor: const Color.fromRGBO(164, 213, 166, 1),
                      indicatorColor: Colors.green,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      onDestinationSelected: (int index) {
                        // This triggers a rebuild with the updated selectedPageIndex
                        setState(() {
                          selectedPageIndex = index;
                        });
                      },
                      selectedIndex: selectedPageIndex,
                      destinations: const <NavigationDestination>[
                        NavigationDestination(
                          selectedIcon: Icon(
                            Icons.home_rounded,
                            color: Color.fromRGBO(33, 33, 33, 1),
                          ),
                          icon: Icon(
                            Icons.home_outlined,
                            color: Color.fromRGBO(33, 33, 33, 1),
                          ),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          selectedIcon: Icon(
                            Icons.grass,
                            color: Color.fromRGBO(33, 33, 33, 1),
                          ),
                          icon: Icon(
                            Icons.grass_outlined,
                            color: Color.fromRGBO(33, 33, 33, 1),
                          ),
                          label: 'My Farm',
                        ),
                        NavigationDestination(
                          selectedIcon: Icon(
                            Icons.insert_chart,
                            color: Color.fromRGBO(33, 33, 33, 1),
                          ),
                          icon: Icon(
                            Icons.insert_chart_outlined,
                            color: Color.fromRGBO(33, 33, 33, 1),
                          ),
                          label: 'Analytics',
                        ),
                        NavigationDestination(
                          selectedIcon: Icon(Icons.settings,
                              color: Color.fromRGBO(33, 33, 33, 1)),
                          icon: Icon(Icons.settings_outlined,
                              color: Color.fromRGBO(33, 33, 33, 1)),
                          label: 'Settings',
                        ),
                      ],
                    )
                  : null,
            )
          : LoginScreen(),
    );
  }
}
