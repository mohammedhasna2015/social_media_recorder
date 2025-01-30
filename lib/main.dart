import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:uuid/uuid.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 140, left: 4, right: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: FutureBuilder(
                future: getFilePath(),
                builder: (context, snapShot) {
                  final path = snapShot.data ?? '';
                  return SocialMediaRecorder(
                    pathRecord: path,
                    sendRequestFunction: (soundFile) {
                      // print("the current path is ${soundFile.path}");
                    },
                    encode: AudioEncoderType.AAC,
                  );
                }),
          ),
        ),
      ),
    );
  }

  Future<String> getFilePath() async {
    try {
      // Get the appropriate directory based on platform
      final Directory directory = await getApplicationDocumentsDirectory();
      final String basePath = directory.path;

      // Create audio subdirectory to keep files organized
      final String audioDirectory = '$basePath/audio_recordings';
      final Directory audioDir = Directory(audioDirectory);

      // Create directory if it doesn't exist
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      // Generate unique filename with timestamp for better organization
      final uuid = const Uuid().v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String filename = '${uuid}_$timestamp.m4a';

      // Construct final path
      final String filePath = '${audioDir.path}/$filename';

      // Store path for later use

      return filePath;
    } catch (e) {
      // Log error and rethrow with more context
      print('Error creating audio file path: $e');
      throw Exception('Failed to create audio file path: $e');
    }
  }
}
