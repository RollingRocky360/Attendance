import 'package:attendance/screens/home.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Student {
  final String id;
  final int regNumber;
  final String name;

  Student(this.id, this.regNumber, this.name);

  factory Student.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    return Student(snapshot.id, data["reg_number"], data["name"]);
  }
}

class Attendance extends StatefulWidget {
  final Classroom? classroom;
  final int? serial;
  final String? subject;
  final DateTime? date;

  const Attendance({
    super.key,
    required this.classroom,
    required this.serial,
    required this.subject,
    required this.date
  });

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  Set<int> absentees = {};
  List<Student> allStudents = [];
  bool loading = true;
  bool defaultToAbsent = false;
  bool titleRegNumber = true;
  DocumentReference? existingDoc;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.classroom == null) return;

    loading = true;
    defaultToAbsent = false;
    titleRegNumber = true;
    var dateString = "${widget.date!.day}:${widget.date!.month}";
    Future.wait([
      db
          .collection("attendances")
          .where("subject", isEqualTo: widget.subject)
          .where("serial", isEqualTo: widget.serial)
          .where("classroom", isEqualTo: widget.classroom!.displayName)
          .where("date", isEqualTo: dateString)
          .limit(1)
          .get(),
      for (final batch in widget.classroom!.students.slices(30))
        db
            .collection("students")
            .where("reg_number", whereIn: batch)
            .orderBy("reg_number")
            .get()
    ]).then((snapshots) {
      var existingDocs = snapshots[0].docs;
      if (existingDocs.isNotEmpty) {
        absentees = Set<int>.from(existingDocs[0].data()["absentees"]);
        existingDoc = existingDocs[0].reference;
      }
      for (QuerySnapshot snapshot in snapshots.slice(1)) {
        for (final doc in snapshot.docs) {
          allStudents.add(Student.fromFirestore(
              doc as QueryDocumentSnapshot<Map<String, dynamic>>));
        }
      }
      setState(() {
        allStudents.sort(((a, b) => a.regNumber.compareTo(b.regNumber)));
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    if (widget.classroom == null || widget.serial == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text("Please select a slot from your timetable."),
        ),
      );
    }

    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${widget.classroom!.displayName} ${widget.subject} ${widget.date!.day}-${widget.date!.month}-${widget.date!.year}",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      titleRegNumber = !titleRegNumber;
                    });
                  },
                  icon: Icon(Icons.swap_vert)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (defaultToAbsent) {
                        absentees
                            .removeAll(allStudents.map((e) => e.regNumber));
                      } else {
                        absentees.addAll(allStudents.map((e) => e.regNumber));
                      }
                      defaultToAbsent = !defaultToAbsent;
                    });
                  },
                  icon: Icon(Icons.swap_horiz)),
              IconButton(
                  onPressed: () async {
                    final data = {
                      "prof_id": user.uid,
                      "subject": widget.subject,
                      "serial": widget.serial,
                      "classroom": widget.classroom!.displayName,
                      "date": "${widget.date!.day}:${widget.date!.month}",
                      "absentees": absentees,
                    };
                    if (existingDoc == null) {
                      existingDoc =
                          await db.collection("attendances").add(data);
                    } else {
                      await existingDoc!.set(data);
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          showCloseIcon: true,
                          content: Text("Attendance Saved!")));
                    }
                  },
                  icon: Icon(Icons.save))
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: Card(
              elevation: 0,
              color: Theme.of(context).canvasColor,
              margin: EdgeInsets.zero,
              child: ListView(
                children: [
                  for (final s in allStudents)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          side: BorderSide(color: Theme.of(context).primaryColor, width: 1)
                        ),
                        onTap: () {
                          setState(() {
                            absentees.contains(s.regNumber)
                                ? absentees.remove(s.regNumber)
                                : absentees.add(s.regNumber);
                          });
                        },
                        selected: absentees.contains(s.regNumber),
                        selectedTileColor: Theme.of(context).primaryColor,
                        selectedColor: Theme.of(context).colorScheme.onPrimary,
                        subtitle: Text(
                            titleRegNumber ? s.name : s.regNumber.toString()),
                        title: Text(
                            titleRegNumber ? s.regNumber.toString() : s.name),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
