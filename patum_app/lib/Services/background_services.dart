import 'dart:async';
import 'package:Patum/Services/location_module.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String? policeNumber;
String? medicalNumber;
String? stateName;

double? global_latitude;
double? global_longitude;

class BackgroundServices {
  static Timer? _timer;

  static void startTimer() async {
    // Cancel any existing timer to avoid duplicates
    _timer?.cancel();

    await _onTimerTick();

    // Start a new periodic timer
    _timer = Timer.periodic(const Duration(seconds: 600), (timer) async {
      await _onTimerTick();
    });
  }

  static void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _onTimerTick() async {
    final location = await LocationModule.getCurrentLocation();
    global_latitude = location!["latitude"];
    global_longitude = location["longitude"];

    final statesSnapshot =
        await FirebaseFirestore.instance.collection("states").get();

    for (var doc in statesSnapshot.docs) {
      final data = doc.data();
      final double latStart = double.parse(data["lat-s"]);
      final double latEnd = double.parse(data["lat-e"]);
      final double lngStart = double.parse(data["lng-s"]);
      final double lngEnd = double.parse(data["lng-e"]);

      if (global_latitude! >= latStart &&
          global_latitude! <= latEnd &&
          global_longitude! >= lngStart &&
          global_longitude! <= lngEnd) {
        stateName = data["name"];

        // 🔍 Fetch emergency contact info for this state
        final emergencyQuery = await FirebaseFirestore.instance
            .collection("state_emergency_contacts")
            .where("name", isEqualTo: stateName?.toLowerCase()) // ensure match
            .limit(1)
            .get();

        if (emergencyQuery.docs.isNotEmpty) {
          final emergencyData = emergencyQuery.docs.first.data();
          policeNumber = emergencyData["police_no"] ?? '';
          medicalNumber = emergencyData["medical_no"] ?? '';
        } else {
          policeNumber = '1212121212';
          medicalNumber = '1212121212';
        }
        return; // Exit after finding the matching state
      }
    }
  }
}
