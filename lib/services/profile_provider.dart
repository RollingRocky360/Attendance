import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile {
  final List<String> subjects;
  final Map<String, List<Map<String, String>?>> timetable;
  Profile(this.subjects, this.timetable);

  factory Profile.fromFirestore(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    Map<String, List<Map<String, String>?>> tt = {};
    for (final e in (data["timetable"] as Map<String, dynamic>).entries) {
      tt[e.key] = [
        for (final period in e.value) 
          period == null ? null : <String, String>{
            "subject": period["subject"]!,
            "classroom": period["classroom"]!
          }
      ];
    }
    return Profile(List<String>.from(data["subjects"]), tt);
  }
}

class ProfileProvider extends ChangeNotifier {
  final User user;
  late Profile profile;
  final db = FirebaseFirestore.instance;
  bool loading = false;
  ProfileProvider(this.user);

  void init() async {
    loading = true;
    notifyListeners();

    Map<String, List<Map<String, String>?>> tt = {};
    for (int i = 0; i < 7; i++) {
      tt[i.toString()] = List<Map<String, String>?>.filled(7, null);
    }
    DocumentSnapshot snap = await db.collection("profiles").doc(user.uid).get();
    if (!snap.exists) {
      profile = Profile([], tt);
      await db
          .collection("profiles")
          .doc(user.uid)
          .set({"subjects": profile.subjects, "timetable": profile.timetable});
    } else {
      profile = Profile.fromFirestore(snap);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addSubject(String subject) async {
    await FirebaseFirestore.instance
        .collection("profiles")
        .doc(user.uid)
        .update({
      "subjects": FieldValue.arrayUnion([subject])
    });
    profile.subjects.add(subject);
    notifyListeners();
  }

  Future<void> removeSubject(String subject) async {
    await db.collection("profiles").doc(user.uid).update({
      "subjects": FieldValue.arrayRemove([subject])
    });
    profile.subjects.remove(subject);
    notifyListeners();
  }

  Future<void> updateTimetable(int day, int period, Map<String, String>? entry) async {
    profile.timetable[day.toString()]![period] = entry;
    await db
        .collection("profiles")
        .doc(user.uid)
        .update({"timetable": profile.timetable});
    notifyListeners();
  }
}
