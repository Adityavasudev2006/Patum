import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:Patum/Components/location_module.dart';
import 'package:Patum/Screens/records.dart';
import 'package:Patum/Components/camera_module.dart';
import 'package:Patum/Components/call_module.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:Patum/Screens/chatbot.dart';
import 'package:Patum/Components/const.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(Patum());
}

class Patum extends StatelessWidget {
  // The root widget
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      overlayWidgetBuilder: (_) => Center(
        child: SpinKitSpinningLines(
          color: Colors.blue, // Set animation color to blue
          size: 50.0, // Adjust size if needed
        ),
      ),
      child: MaterialApp(
        home: MainPage(),
        routes: {
          'home': (context) => MainPage(),
          'records': (context) => Records(),
          'chatbot': (context) => const ChatBot(),
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  IconData aLogo = Icons.warning;
  final player = AudioPlayer();

  void changeAlertStatus() {
    setState(() {
      if (aLogo == Icons.warning) {
        aLogo = Icons.close;
        playAudioLoop();
      } else {
        aLogo = Icons.warning;
        stopAudioLoop();
      }
    });
  }

  Future<void> stopAudioLoop() async {
    await player.stop();
    player.setLoopMode(LoopMode.off);
  }

  Future<void> playAudioLoop() async {
    try {
      await player.setAsset('assets/AlertSound.mp3');
      player.setLoopMode(LoopMode.one);
      await player.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void do_nothing() {
    // Nothing here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF2FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFEFF2FA),
        title: Text(
          'Patum',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 35,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image.asset(
                      'assets/doctor_logo.png',
                      width: 60.0,
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          ' Hello Aditya!',
                          style: TextStyle(
                            color: Color(0xFF868C9F),
                          ),
                        ),
                        MainTextButton(
                          ButtonText: 'Complete Profile',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Records()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          ' Chennai',
                          style: TextStyle(
                            color: Color(0xFF868C9F),
                          ),
                        ),
                        MainTextButton(
                          ButtonText: 'See your location',
                          onPressed: () async {
                            await LocationModule.getCurrentLocationAndOpenMaps(
                                context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Icon(
                      Icons.location_on,
                      size: 35.0,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      'Emergency help',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 40.0,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'needed?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 40.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'Just press the button to call',
                      style: TextStyle(
                          color: Color(0xFF868C9F),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    AlertButton(
                        alertStatusLogo: aLogo,
                        onPressed: () {
                          setState(() {
                            changeAlertStatus();
                          });
                        }),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'Not sure what to do?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Go through the options below',
                      style: TextStyle(
                          color: Color(0xFF868C9F),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliderOptions(),
          BottomBar(
            homeIconColor: Colors.red,
            recordsIconColor: Colors.white,
            profileIconColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class MainTextButton extends StatelessWidget {
  const MainTextButton({
    super.key,
    required this.ButtonText,
    required this.onPressed,
  });

  final String ButtonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero), // Remove padding
        minimumSize: WidgetStateProperty.all(Size.zero), // Remove minimum size
        tapTargetSize:
            MaterialTapTargetSize.shrinkWrap, // Remove extra tap area
        visualDensity: VisualDensity.compact, // Remove extra density
      ),
      child: Text(
        ButtonText,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AlertButton extends StatelessWidget {
  const AlertButton({
    super.key,
    required this.alertStatusLogo,
    required this.onPressed,
  });

  final IconData alertStatusLogo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 6.0,
      constraints: BoxConstraints.tightFor(
        width: 150.0,
        height: 150.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(
        alertStatusLogo,
        color: Colors.white,
        size: 60.0,
      ),
      fillColor: Colors.red,
    );
  }
}

class SliderOptions extends StatelessWidget {
  const SliderOptions({
    super.key,
  });

  void do_nothing() {
    //Doing Nothing.
  }

  void call_police() {
    pNumber = policeNumber;
    CallModule.callNumber();
  }

  void call_medical() {
    pNumber = medicalNumber;
    CallModule.callNumber();
  }

  void call_emergency() {
    pNumber = emergencyNumber;
    CallModule.callNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            clickableOptions(
              optionText: 'Alert Police',
              logoPlace: 'assets/police_logo.png',
              onPressed: () {
                call_police();
              },
            ),
            clickableOptions(
              optionText: 'Medical Care',
              logoPlace: 'assets/doctor_logo.png',
              onPressed: () {
                call_medical();
              },
            ),
            clickableOptions(
              optionText: 'Record Crime',
              logoPlace: 'assets/record_crime_logo.png',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraPage()),
                );
              },
            ),
            clickableOptions(
              optionText: 'Emergency Call',
              logoPlace: 'assets/emergency_contacts_logo.png',
              onPressed: () {
                call_emergency();
              },
            ),
            clickableOptions(
              optionText: 'Report Crime',
              logoPlace: 'assets/report_crime_logo.png',
              onPressed: () {
                LocationModule.getCurrentLocation(context);
              },
            ),
            clickableOptions(
              optionText: 'Queries',
              logoPlace: 'assets/qna_logo.png',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatBot()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.homeIconColor,
    required this.recordsIconColor,
    required this.profileIconColor,
  });

  final Color homeIconColor;
  final Color recordsIconColor;
  final Color profileIconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 17.0, 0.0, 23.0),
      color: Colors.teal,
      margin: EdgeInsets.only(top: 10.0),
      width: double.infinity,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.home,
                size: 35.0,
                color: homeIconColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'records');
              },
              child: Icon(
                Icons.import_contacts_sharp,
                size: 28.0,
                color: recordsIconColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'profile');
              },
              child: Icon(
                Icons.person,
                size: 30.0,
                color: profileIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class clickableOptions extends StatelessWidget {
  const clickableOptions({
    super.key,
    required this.optionText,
    required this.logoPlace,
    required this.onPressed,
  });

  final String optionText;
  final String logoPlace;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38.0),
        child: Container(
          width: 160,
          color: Colors.white,
          margin: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                optionText,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 5.0,
              ),
              Image.asset(
                logoPlace,
                width: 60.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
