import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:uuid/uuid.dart';

class SoundRecordNotifier extends ChangeNotifier {
  GlobalKey key = GlobalKey();

  /// This Timer Just For wait about 1 second until starting record
  Timer? _timer;

  Timer? _timerLimitRecord;

  /// This time for counter wait about 1 send to increase counter
  Timer? _timerCounter;

  /// Use last to check where the last draggable in X
  double last = 0;

  /// recording mp3 sound Object
  Record recordMp3 = Record();

  /// recording mp3 sound to check if all permisiion passed
  bool _isAcceptedPermission = false;

  /// used to update state when user draggable to the top state
  double currentButtonHeihtPlace = 0;

  /// used to know if isLocked recording make the object true
  /// else make the object isLocked false
  bool isLocked = false;

  /// when pressed in the recording mic button convert change state to true
  /// else still false
  bool isShow = false;

  /// to show second of recording
  late int second;

  /// to show minute of recording
  late int minute;

  /// to know if pressed the button
  late bool buttonPressed;

  /// used to update space when dragg the button to left
  late double edge;
  late bool loopActive;

  /// store final path where user need store mp3 record
  late bool startRecord;

  /// store the value we draggble to the top
  late double heightPosition;

  /// store status of record if lock change to true else
  /// false
  late bool lockScreenRecord;
  late String mPath;
  late AudioEncoderType encode;
  late Function(File soundFile) sendRequestFunction;
  late Function(bool isRecordStart) isRecordStart;
  // ignore: sort_constructors_first
  SoundRecordNotifier({
    this.edge = 0.0,
    this.minute = 0,
    this.second = 0,
    this.buttonPressed = false,
    this.loopActive = false,
    this.mPath = '',
    this.startRecord = false,
    this.heightPosition = 0,
    this.lockScreenRecord = false,
    this.encode = AudioEncoderType.AAC,
    required this.sendRequestFunction,
    required this.isRecordStart,
  });

  /// To increase counter after 1 sencond
  void _mapCounterGenerater() {
    _timerCounter = Timer(const Duration(seconds: 1), () {
      _increaseCounterWhilePressed();
      _mapCounterGenerater();
    });
  }

  /// used to reset all value to initial value when end the record
  resetEdgePadding() async {
    isLocked = false;
    edge = 0;
    buttonPressed = false;
    second = 0;
    minute = 0;
    isShow = false;
    key = GlobalKey();
    heightPosition = 0;
    lockScreenRecord = false;
    if (_timer != null) _timer!.cancel();
    if (_timerCounter != null) _timerCounter!.cancel();
    if (_timerLimitRecord != null) _timerLimitRecord!.cancel();
    recordMp3.stop();
    notifyListeners();
  }

  /// used to change the draggable to top value
  setNewInitialDraggableHeight(double newValue) {
    currentButtonHeihtPlace = newValue;
  }

  /// used to change the draggable to top value
  /// or To The X vertical
  /// and update this value in screen
  updateScrollValue(Offset currentValue, BuildContext context) async {
    if (buttonPressed == true) {
      final x = currentValue;

      /// take the diffrent between the origin and the current
      /// draggable to the top place
      double hightValue = currentButtonHeihtPlace - x.dy;

      /// if reached to the max draggable value in the top
      if (hightValue >= 50) {
        isLocked = true;
        lockScreenRecord = true;
        hightValue = 50;
        notifyListeners();
      }
      if (hightValue < 0) hightValue = 0;
      heightPosition = hightValue;
      lockScreenRecord = isLocked;
      notifyListeners();

      /// this operation for update X oriantation
      /// draggable to the left or right place
      try {
        RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset.zero);
        if (position.dx <= MediaQuery.of(context).size.width * 0.6) {
          resetEdgePadding();
        } else if (x.dx >= MediaQuery.of(context).size.width) {
          edge = 0;
          edge = 0;
        } else {
          if (x.dx <= MediaQuery.of(context).size.width * 0.5) {}
          if (last < x.dx) {
            edge = edge -= x.dx / 200;
            if (edge < 0) {
              edge = 0;
            }
          } else if (last > x.dx) {
            edge = edge += x.dx / 200;
          }
          last = x.dx;
        }
        // ignore: empty_catches
      } catch (e) {}
      notifyListeners();
    }
  }

  /// this function to manage counter value
  /// when reached to 60 sec
  /// reset the sec and increase the min by 1
  _increaseCounterWhilePressed() {
    if (loopActive) {
      return;
    }

    loopActive = true;

    second = second + 1;
    buttonPressed = buttonPressed;
    if (second == 60) {
      second = 0;
      minute = minute + 1;
    }

    notifyListeners();
    loopActive = false;
    notifyListeners();
  }

  Future<String> getFilePath() async {
    String _sdPath = "";
    Directory tempDir = await getTemporaryDirectory();
    _sdPath = tempDir.path;
    var d = Directory(_sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    var uuid = const Uuid();
    String uid = uuid.v4();
    String storagePath = _sdPath + "/" + uid + '.m4a';
    mPath = storagePath;
    return storagePath;
  }

  /// this function to start record voice
  record() async {
    if (!_isAcceptedPermission) {
      await Permission.microphone.request();
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      _isAcceptedPermission = true;
    } else {
      buttonPressed = true;
      final filePath = await getFilePath();
      mPath = filePath;
      _timer = Timer(const Duration(milliseconds: 900), () {
        recordMp3.start(path: filePath);
        isRecordStart.call(true);
      });
      // Set a timer to stop recording after 60 seconds
      _timer = Timer(const Duration(seconds: 60), () {
        sendRequestFunction.call(File(mPath));
        resetEdgePadding();
      });
      _mapCounterGenerater();
      notifyListeners();
    }
    notifyListeners();
  }

  /// to check permission
  voidInitialSound() async {
    if (Platform.isIOS) _isAcceptedPermission = true;

    startRecord = false;
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        _isAcceptedPermission = true;
      }
    }
  }
}
