import 'package:attendance/screens/rss.dart';
import 'package:attendance/widgets/profile.dart';
import 'package:attendance/widgets/summary.dart';
import 'package:attendance/widgets/timetable.dart';
import 'package:attendance/widgets/attendance.dart';
import 'package:attendance/services/auth.dart';
import 'package:attendance/services/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class Classroom {
  final String id;
  final int batch;
  final String department;
  final String displayName;
  final String section;
  final List<int> students;

  Classroom(this.id, this.batch, this.department, this.displayName,
      this.section, this.students);

  factory Classroom.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return Classroom(
      snapshot.id,
      data["batch"],
      data["department"],
      data["display_name"],
      data["section"],
      List<int>.from(data["students"]),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  List<Classroom> classrooms = [];
  Classroom? attendanceClassroom;
  String? attendanceSubject;
  int? attendanceSerial;
  DateTime? attendanceDate;
  final db = FirebaseFirestore.instance;

  void takeAttendance(
      String classroom, int serial, String subject, DateTime date) {
    setState(() {
      attendanceClassroom =
          classrooms.firstWhere((element) => element.displayName == classroom);
      attendanceSerial = serial;
      attendanceSubject = subject;
      attendanceDate = date;
      _index = 1;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      QuerySnapshot snap =
          await db.collection("classrooms").orderBy("display_name").get();
      for (var docSnapshot in snap.docs) {
        classrooms.add(Classroom.fromFirestore(
            docSnapshot as QueryDocumentSnapshot<Map<String, dynamic>>));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var profileProvider = Provider.of<ProfileProvider>(context);

    final views = <Widget>[
      Timetable(takeAttendance: takeAttendance),
      Attendance(
          classroom: attendanceClassroom,
          serial: attendanceSerial,
          subject: attendanceSubject,
          date: attendanceDate),
      Summary(classrooms: classrooms),
      ProfileWidget(classrooms: classrooms)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => RSSFeed()
                ));
              },
              icon: Icon(Icons.rss_feed)),
          IconButton(onPressed: AuthService.logout, icon: Icon(Icons.logout))
        ],
      ),
      body: profileProvider.loading
          ? Center(child: CircularProgressIndicator())
          : views[_index],
      bottomNavigationBar: NavigationBar(
        height: 65,
        onDestinationSelected: (int selectedIndex) {
          setState(() {
            _index = selectedIndex;
          });
        },
        selectedIndex: _index,
        destinations: [
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              label: "Timetable",
              selectedIcon: Icon(Icons.calendar_month)),
          NavigationDestination(
              selectedIcon: Icon(Icons.people),
              icon: Icon(Icons.people_outlined),
              label: "Attendance"),
          NavigationDestination(
              selectedIcon: Icon(Icons.summarize),
              icon: Icon(Icons.summarize_outlined),
              label: "Summary"),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            label: "Profile",
            selectedIcon: Icon(Icons.person),
          )
        ],
      ),
    );
  }
}
