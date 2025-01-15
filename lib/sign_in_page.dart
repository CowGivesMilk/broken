import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dashboard.dart'; // Import the Dashboard page
import 'sign_up_page.dart'; // Import the Sign-Up page

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController(); // Controller for email input
  final _passwordController = TextEditingController(); // Controller for password input
  bool _isLoading = false; // State to manage loading indicator

  // Function to handle sign-in
  void _signIn() async {
    setState(() => _isLoading = true); // Show loading indicator
    try {
      // Call the login function from the API service
      final response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      // Show a success message using a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${response['username']}!')),
      );

      // Navigate to the Dashboard page on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } catch (error) {
      // Show an error message using a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $error')),
      );
    } finally {
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.green, // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Email input field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // Password input field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true, // Hide password text
            ),
            const SizedBox(height: 30),

            // Sign-In button
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn, // Disable button when loading
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // Show loader when loading
                  : const Text('Sign In', style: TextStyle(fontSize: 18)), // Button text
            ),

            const SizedBox(height: 20),

            // Add "Don't have an account?" text button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text(
                "Don't have an account?",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
