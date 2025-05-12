import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:Patum/Components/modals.dart';

double myLatitude = 0.0;
double myLongitude = 0.0;

final modal = Modal();

class LocationModule {
  static Future<Map<String, double>?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return null;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return null;
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 100,
      ),
    );

    print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    myLatitude = position.latitude;
    myLongitude = position.longitude;

    return {
      "latitude": position.latitude,
      "longitude": position.longitude,
    };
  }

  static Future<void> openGoogleMaps() async {
    final Uri googleUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$myLatitude,$myLongitude");

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.inAppWebView);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  static Future<void> getCurrentLocationAndOpenMaps(
      BuildContext context) async {
    context.loaderOverlay.show(); // Show loading overlay

    try {
      await getCurrentLocation(); // Get location
      await openGoogleMaps(); // Open Google Maps
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch location or open Maps")));
    } finally {
      context.loaderOverlay.hide(); // Hide loading overlay
    }
  }
}
