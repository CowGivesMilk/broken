import 'package:flutter/material.dart';
import 'dashboard.dart'; // Import the Dashboard page
import 'sign_in_page.dart';  // Import the SignInPage
import 'sign_up_page.dart';  // Import the SignUpPage
import 'driver.dart';        // Import the DriverSignInPage

void main() {
  runApp(const SahayatriApp());
}

class SahayatriApp extends StatelessWidget {
  const SahayatriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sahayatri',
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => const SahayatriHome(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const Dashboard(), // Dashboard route
        '/driver': (context) => const DriverSignInPage(), // Driver sign-in route
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

class SahayatriHome extends StatefulWidget {
  const SahayatriHome({super.key});

  @override
  _SahayatriHomeState createState() => _SahayatriHomeState();
}

class _SahayatriHomeState extends State<SahayatriHome> {
  int _tapCount = 0;  // Counter for bus logo taps

  void _handleBusLogoTap() {
    setState(() {
      _tapCount++;
    });

    if (_tapCount >= 5) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF32CD32), // Green gradient start
              Color(0xFFE9FFE9), // Light green gradient end
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              'Sahayatri',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              'Your Travel Buddy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _handleBusLogoTap,
              child: Image.asset(
                'assets/bus.png',
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.directions_bus,
                    size: 200,
                    color: Colors.green.shade200,
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
            // Sign In Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Sign Up Button
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Sign In as Driver Button
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/driver');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Sign In as Driver',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.drive_eta,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
