import 'package:attendance/services/profile_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weekday_selector/weekday_selector.dart';

class EditTimetable extends StatefulWidget {
  const EditTimetable({super.key});

  @override
  State<EditTimetable> createState() => _EditTimetableState();
}

class _EditTimetableState extends State<EditTimetable> {
  int day = DateTime.now().weekday;
  var daySelector = <bool?>[null, ...(List<bool>.filled(6, false))]
    ..[DateTime.now().weekday % 7] = true;

  @override
  Widget build(BuildContext context) {
    var profileProvider = Provider.of<ProfileProvider>(context);
    Profile profile = profileProvider.profile;

    return Expanded(
      child: Column(
        children: [
          WeekdaySelector(
              onChanged: (day) {
                setState(() {
                  daySelector = <bool?>[
                    null,
                    ...List.filled(6, false, growable: false)
                  ]..[day % 7] = true;
                });
              },
              values: daySelector),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: profile.timetable[day.toString()]!.mapIndexed((index, entry) {
                return entry == null 
                  ? ListTile(
                    leading: CircleAvatar(child: Text(index.toString())),
                    title: Text("Free"),
                  ) : ListTile(
                    leading: CircleAvatar(child: Text(index.toString())),
                    subtitle: Text(entry["subject"]!),
                    title: Text(entry["classroom"]!),
                  );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
