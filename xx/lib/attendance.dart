import 'package:flutter/material.dart';
import 'localdb.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<List<Map<String, dynamic>>> attendanceData;

  @override
  void initState() {
    super.initState();
    attendanceData = getAllAttendanceRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: attendanceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error loading attendance records'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance records found'));
          }

          List<Map<String, dynamic>> users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('ID: ${users[index]['id']}'),
                subtitle: Text('Name: ${users[index]['name']}, '
                    'Clock Time: ${users[index]['clockTime']}'),
              );
            },
          );
        },
      ),
    );
  }

  // Function to fetch attendance records
  Future<List<Map<String, dynamic>>> getAllAttendanceRecords() async {
    UserHelper userHelper = UserHelper();
    return await userHelper.getAllUser();
  }
}
