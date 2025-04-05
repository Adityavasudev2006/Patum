import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  Future<String> _buildFilePath(CaptureMode mode) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String dirPath = '${tempDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    final String fileExtension = mode == CaptureMode.photo ? 'jpg' : 'mp4';
    return '$dirPath/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
  }

  Future<void> _uploadFile(String filePath) async {
    final dio = Dio();
    final file = File(filePath);
    final fileName = file.path.split('/').last;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      final response = await dio.post(
        'https://yourserver.com/upload', // Replace with your server URL
        data: formData,
      );
      if (response.statusCode == 200) {
        print('Upload successful');
      } else {
        print('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photoAndVideo(
          photoPathBuilder: (sensors) async {
            final path = await _buildFilePath(CaptureMode.photo);
            return SingleCaptureRequest(path, sensors.first);
          },
          videoPathBuilder: (sensors) async {
            final path = await _buildFilePath(CaptureMode.video);
            return MultipleCaptureRequest({sensors.first: path});
          },
        ),
        onMediaTap: (mediaCapture) async {
          final captureRequest = mediaCapture.captureRequest;

          String? filePath;
          if (captureRequest is SingleCaptureRequest) {
            filePath = captureRequest
                .path; // Correct property for SingleCaptureRequest
          } else if (captureRequest is MultipleCaptureRequest) {
            filePath = captureRequest.fileBySensor.values.first?.path ?? "";
            // Get the first file path from multiple paths
          }

          if (filePath != null) {
            await _uploadFile(filePath);
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
            }
          }
        },
      ),
    );
  }
}
