import 'package:attendance/services/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Timetable extends StatefulWidget {
  final Function takeAttendance;

  const Timetable({super.key, required this.takeAttendance});

  @override
  State<Timetable> createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  DateTime selectedDate = DateTime.now();
  final db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    var profileProvider = Provider.of<ProfileProvider>(context);
    Profile profile = profileProvider.profile;
    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            EasyInfiniteDateTimeLine(
              firstDate: DateTime(2023, DateTime.august, 7),
              lastDate: DateTime(2023, DateTime.november, 27),
              focusDate: selectedDate,
              disabledDates: [],
              dayProps: EasyDayProps(
                  todayHighlightStyle: TodayHighlightStyle.withBackground,
                  dayStructure: DayStructure.dayStrDayNum,
                  height: 56,
                  width: 56),
              onDateChange: (newDate) {
                print(newDate);
                if (newDate.weekday == DateTime.sunday) return;
                setState(() {
                  selectedDate = newDate;
                });
              },
            ),
            SizedBox(
              height: 25,
            ),
            IntrinsicHeight(
              child: Column(
                  children: profile.timetable[selectedDate.weekday.toString()]!
                      .mapIndexed((index, period) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).canvasColor,
                      foregroundColor: Colors.black38,
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(period == null ? "Free" : period["subject"]!),
                    trailing: period == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Text(
                              period["classroom"]!,
                              style: TextStyle(color: Colors.black45),
                            ),
                          ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black12, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      if (period == null) return;
                      widget.takeAttendance(
                        period["classroom"],
                        index,
                        period["subject"],
                        selectedDate
                      );
                    },
                  ),
                );
              }).toList()),
            )
          ],
        ),
      ),
    );
  }
}
