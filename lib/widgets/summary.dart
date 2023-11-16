import 'package:attendance/screens/home.dart';
import 'package:attendance/services/profile_provider.dart';
import 'package:attendance/services/summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Summary extends StatefulWidget {
  final List<Classroom> classrooms;
  const Summary({super.key, required this.classrooms});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  String? selectedSubject;
  Classroom? selectedClassroom;
  @override
  Widget build(BuildContext context) {
    var profileProvider = Provider.of<ProfileProvider>(context);
    var summaryProvider = Provider.of<SummaryProvider>(context);

    final summary = summaryProvider.summary;

    Profile profile = profileProvider.profile;

    return ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton(
                  value: selectedSubject,
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  isExpanded: true,
                  hint: Text(
                    "Select a Subject",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  items: [
                    for (final subject in profile.subjects)
                      DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      )
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  }),
              SizedBox(
                height: 15,
              ),
              DropdownButton(
                  value: selectedClassroom,
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  isExpanded: true,
                  hint: Text(
                    "Select a Classroom",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  items: [
                    for (final classroom in widget.classrooms)
                      DropdownMenuItem(
                        value: classroom,
                        child: Text(classroom.displayName),
                      )
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedClassroom = value as Classroom;
                    });
                  }),
              SizedBox(
                height: 15,
              ),
              OutlinedButton(
                  onPressed: () {
                    if (selectedClassroom == null || selectedSubject == null) {
                      return;
                    }
                    summaryProvider.updateSummary(
                        selectedSubject!, selectedClassroom!);
                  },
                  child: Text("Summarize")),
              SizedBox(
                height: 15,
              ),
              if (summaryProvider.isLoading)
                Expanded(child: Card(child: Center(child: CircularProgressIndicator()))),
              if (!summaryProvider.isLoading && summary.isNotEmpty)
                Expanded(
                    child: Card(
                  elevation: 0,
                  color: Theme.of(context).canvasColor,
                  margin: EdgeInsets.zero,
                  child: ListView(
                    children: [
                      for (final summaryEntity in summary)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            title:
                                Text(summaryEntity.student.regNumber.toString()),
                            subtitle: Text(summaryEntity.student.name),
                            trailing: CircleAvatar(
                              foregroundColor: Colors.black38,
                              backgroundColor: Colors.transparent,
                              child: Text(
                                  (summaryEntity.attendancePercentage * 100).ceil().toString()),
                            ),
                            tileColor: Theme.of(context).primaryColor.withOpacity(
                              summaryEntity.attendancePercentage
                            ),
                          ),
                        )
                    ],
                  ),
                ))
            ],
          ),
        ));
  }
}
