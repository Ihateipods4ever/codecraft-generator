import 'package:flutter/material.dart';

// You would create this file for your new screen
// import 'details_screen.dart'; 

// For demonstration, we can define a simple DetailsScreen here
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: const Center(
        child: Text('This is the details page!'),
      ),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Home Screen!'),
            const SizedBox(height: 20), // Adds some space
            ElevatedButton(
              child: const Text('Go to Details'),
              onPressed: () {
                // This is the navigation logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
