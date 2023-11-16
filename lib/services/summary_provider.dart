import 'package:attendance/screens/home.dart';
import 'package:attendance/widgets/attendance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SummaryEntry {
  final Student student;
  final double attendancePercentage;
  SummaryEntry(this.student, this.attendancePercentage);
}

class SummaryProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;
  List<SummaryEntry> summary = [];
  bool isLoading = false;

  void updateSummary(String subject, Classroom classroom) async {
    isLoading = true;
    notifyListeners();

    var snapshots = await Future.wait([
      db
          .collection("attendances")
          .where("subject", isEqualTo: subject)
          .where("classroom", isEqualTo: classroom.displayName)
          .get(),
      for (final batch in classroom.students.slices(30))
        db
            .collection("students")
            .where("reg_number", whereIn: batch)
            .orderBy("reg_number")
            .get()
    ]);

    List<Set<int>> absenteesAllDays = [];
    for (final doc in snapshots[0].docs) {
      absenteesAllDays.add(Set<int>.from(doc.data()["absentees"]));
    }

    List<Student> allStudents = [];
    for (QuerySnapshot snapshot in snapshots.slice(1)) {
      for (final doc in snapshot.docs) {
        allStudents.add(Student.fromFirestore(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>));
      }
    }

    summary.clear();
    double totalDays = absenteesAllDays.length.toDouble();
    for (final s in allStudents) {
      int count = 0;
      for (final attRecord in absenteesAllDays) {
        if (attRecord.contains(s.regNumber)) count++;
      }
      summary.add(SummaryEntry(s, (totalDays-count) / totalDays));
    }

    isLoading = false;
    notifyListeners();
  }
}
