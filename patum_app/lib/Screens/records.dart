import 'package:flutter/material.dart';
import 'package:Patum/Components/bottom_bar.dart';
import 'package:Patum/Screens/home.dart';
import 'package:Patum/Screens/profile.dart';

class Records extends StatelessWidget {
  static String id = "records_screen";

  @override
  Widget build(BuildContext context) {
    var listnames = [
      'ID:3458',
      'ID:4567',
      'ID:2939',
      'ID:3678',
      'ID:2854',
      'ID:7836',
      'ID:2637',
      'ID:6392',
    ];
    var ver = [
      'verified',
      'verified',
      'not verified',
      'verified',
      'verified',
      'not verified',
      'verified',
      'not verified',
    ];
    var duration = [
      '00:03:05',
      '01:23:09',
      '00:20:34',
      '00:37:56',
      '01:05:03',
      '00:15:08',
      '00:04:16',
      '00:45:07',
    ];
    var location = [
      'Chennai,Tamil Nadu,India',
      'Kannur,Kerala,India',
      'Thrissur,Kerala,India',
      'Bangalore,Karnataka,India',
      'Mumbai,Maharashtra,India',
      'Cochin,Kerala,India',
      'Kanchipuram,Tamil Nadu,India',
      'Pune,Maharashtra,India',
    ];
    var date = [
      'Nov 23,2024',
      'Dec 30,2024',
      'March 1,2025',
      'Jan 2,2025',
      'Jan 30,2025',
      'Feb 28,2025',
      'Feb 12,2025',
      'Feb 28,2025',
    ];

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal[50],
        title: Text(
          'Records',
          style: TextStyle(
            fontSize: 30.0,
            color: Colors.black,
            fontFamily: 'Pacifico',
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: RecordList(
              ver: ver,
              listnames: listnames,
              duration: duration,
              location: location,
              date: date,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 95, // or any height you want for the navbar
        child: BottomBar(
          homeIconColor: Colors.white,
          recordsIconColor: Colors.red,
          profileIconColor: Colors.white,
          onPressed1: () {
            Navigator.pushNamed(context, MainPage.id);
          },
          onPressed2: () {},
          onPressed3: () {
            Navigator.pushNamed(context, ProfileScreen.id);
          },
        ),
      ),
    );
  }
}

class RecordList extends StatelessWidget {
  const RecordList({
    super.key,
    required this.ver,
    required this.listnames,
    required this.duration,
    required this.location,
    required this.date,
  });

  final List<String> ver;
  final List<String> listnames;
  final List<String> duration;
  final List<String> location;
  final List<String> date;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        String status = ver[index];
        bool isverified = status == 'verified';
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 20,
                shadowColor: Colors.black54,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.play_circle_fill_sharp,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                  title: Text(listnames[index]),
                  subtitle: Text(
                    "Duration: ${duration[index]}\n"
                    "Location: ${location[index]}\n"
                    "Date: ${date[index]}",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    status,
                    style: TextStyle(
                      color: isverified ? Colors.green : Colors.red,
                    ),
                  ),
                  enabled: true,
                  tileColor: Colors.white,
                  hoverColor: Colors.lightGreen[100],
                  focusColor: Colors.green,
                  contentPadding: EdgeInsets.only(
                    top: 20.0,
                    right: 30.0,
                    bottom: 20.0,
                    left: 20.0,
                  ),
                  horizontalTitleGap: 40,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onTap: () {},
                  mouseCursor: SystemMouseCursors.text,
                ),
              ),
            ),
          ],
        );
      },
      itemCount: listnames.length,
    );
  }
}
