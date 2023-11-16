import 'package:attendance/screens/home.dart';
import 'package:attendance/services/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weekday_selector/weekday_selector.dart';

class ProfileWidget extends StatefulWidget {
  final List<Classroom> classrooms;
  const ProfileWidget({super.key, required this.classrooms});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  var db = FirebaseFirestore.instance;
  Widget divider = Divider(
    thickness: 2,
    height: 50,
    color: Colors.grey[200],
    endIndent: 20,
    indent: 20,
  );

  int day = DateTime.now().weekday;
  var daySelector = <bool?>[null, ...(List<bool>.filled(6, false))]
    ..[DateTime.now().weekday % 7] = true;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;

    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.photoURL!),
              ),
              SizedBox(height: 15),
              Text(
                user.displayName!,
                style: TextStyle(fontSize: 30),
              ),
              divider,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Subjects",
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                    ),
                    onPressed: () async {
                      String? result = await showDialog(
                          context: context,
                          builder: (context) {
                            var cont = TextEditingController();
                            return AlertDialog(
                              scrollable: true,
                              title: Text("Add Subject"),
                              content: TextFormField(
                                controller: cont,
                              ),
                              actions: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    cont.clear();
                                  },
                                  icon: Icon(Icons.cancel),
                                  label: Text("Cancel"),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (cont.text.isEmpty) return;
                                    Navigator.of(context).pop(cont.text);
                                    cont.clear();
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text("Add"),
                                ),
                              ],
                            );
                          });

                      if (result == null || result.isEmpty) return;

                      await profileProvider.addSubject(result);
                    },
                  )
                ],
              ),
              Row(
                children: profile.subjects.isEmpty
                    ? [
                        Text(
                          "You have not added any subjects",
                          style: TextStyle(color: Colors.grey[400]),
                        )
                      ]
                    : [
                        for (final subject in profile.subjects)
                          GestureDetector(
                            onTap: () {
                              profileProvider.removeSubject(subject);
                            },
                            child: Chip(
                              label: Text(subject),
                              backgroundColor: Colors.grey[100],
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          )
                      ],
              ),
              divider,
              Row(
                children: [
                  Text(
                    "Timetable",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 20),
              WeekdaySelector(
                  onChanged: (newDay) {
                    setState(() {
                      daySelector = <bool?>[
                        null,
                        ...List.filled(6, false, growable: false)
                      ]..[newDay % 7] = true;
                      day = newDay;
                    });
                  },
                  values: daySelector),
              SizedBox(
                height: 10,
              ),
              IntrinsicHeight(
                child: Column(
                  children: profile.timetable[day.toString()]!
                      .mapIndexed((index, period) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).canvasColor,
                          foregroundColor: Colors.black38,
                          child: Text((index + 1).toString()),
                        ),
                        title:
                            Text(period == null ? "Free" : period["subject"]!),
                        trailing:
                            period == null ? null : Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Text(period["classroom"]!, style: TextStyle(color: Colors.black45),),
                            ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black12, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () async {
                          var result = await showDialog(
                              context: context,
                              builder: (context) {
                                String? selectedSubject = period?["subject"];
                                String? selectedClassroom =
                                    period?["classroom"];
                                return StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    title: Text("Edit Period"),
                                    content: IntrinsicHeight(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          DropdownButton(
                                            isExpanded: true,
                                            onChanged: (String? value) {
                                              setState(() {
                                                selectedSubject = value;
                                              });
                                            },
                                            value: selectedSubject,
                                            hint: Text("Select a subject"),
                                            items: [
                                              for (final subject
                                                  in profile.subjects)
                                                DropdownMenuItem(
                                                    value: subject,
                                                    child: Text(subject))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          DropdownButton(
                                            isExpanded: true,
                                            hint: Text("Select the classroom"),
                                            disabledHint:
                                                Text("Select a subject first"),
                                            value: selectedClassroom,
                                            onChanged: (String? value) {
                                              setState(() {
                                                selectedClassroom = value;
                                              });
                                            },
                                            items: selectedSubject == null
                                                ? null
                                                : [
                                                    for (final classroom
                                                        in widget.classrooms)
                                                      DropdownMenuItem(
                                                        value: classroom
                                                            .displayName,
                                                        child: Text(classroom
                                                            .displayName),
                                                      )
                                                  ],
                                          )
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Cancel")),
                                      ElevatedButton(
                                          onPressed: () {
                                            if (selectedSubject == null) return;
                                            Navigator.of(context)
                                                .pop(<String, String>{
                                              "subject": selectedSubject!,
                                              "classroom": selectedClassroom!,
                                            });
                                          },
                                          child: Text("Apply"))
                                    ],
                                  ),
                                );
                              });
                          if (result == null) return;
                          if (result == "Free") result = null;
                          await profileProvider.updateTimetable(
                              day, index, result);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
