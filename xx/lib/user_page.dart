import 'package:flutter/material.dart';
import 'attendance.dart'; // Import the new attendance page
import 'login_page.dart';

class UserPage extends StatefulWidget {
  const UserPage(
      {Key? key,
      required this.userId,
      required this.userName,
      required this.clockTime})
      : super(key: key);
  final String userId;
  final String userName;
  final String clockTime;
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final String adminPassword = "admin123";

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Greetings text with user name
                Text(
                  'Hi ${widget.userName}!',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Card with User ID and Clock-in time
                Card(
                  color: Colors.blue[50],
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.blue, size: 24),
                            const SizedBox(width: 8),
                            Flexible(
                              // Wrapping the text in Flexible to prevent overflow
                              child: Text(
                                'Your ID:${widget.userId} have clocked in at ${widget.clockTime}',
                                style: const TextStyle(fontSize: 16),
                                softWrap: true,
                                overflow: TextOverflow
                                    .clip, // Clip overflow text if any
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Button to view attendance record
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF273671), // Button background color
                    minimumSize: const Size(150, 50), // Minimum size of button
                  ),
                  onPressed: () => _showPasswordDialog(context),
                  child: const Text(
                    'View Attendance Record',
                    style: TextStyle(color: Colors.white), // Text color white
                  ),
                ),

                const SizedBox(height: 20),

                // Back to Face Scan button
                buildBackButton(context),
              ],
            ),
          ),
        ),
      );

  // Build Back Button
  Widget buildBackButton(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(150, 50),
          backgroundColor: const Color(0xFF273671), // Button background color
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back,
              size: 24,
              color: Colors.white,
            ), // Back arrow icon
            SizedBox(width: 8),
            Text(
              'BACK TO FACE SCAN',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        ),
      );

  // Function to show password dialog
  void _showPasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Admin Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true, // Hide password input
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text == adminPassword) {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AttendancePage()),
                  ); // Navigate to AttendancePage
                } else {
                  // Show error message if password is incorrect
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect password')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
