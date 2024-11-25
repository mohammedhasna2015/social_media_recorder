library social_media_recorder;

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:social_media_recorder/provider/sound_record_notifier.dart';
import 'package:social_media_recorder/widgets/lock_record.dart';
import 'package:social_media_recorder/widgets/show_counter.dart';
import 'package:social_media_recorder/widgets/show_mic_with_text.dart';
import 'package:social_media_recorder/widgets/sound_recorder_when_locked_design.dart';

import '../audio_encoder_type.dart';

class SocialMediaRecorder extends StatefulWidget {
  /// use it for change back ground of cancel
  final Color? cancelTextBackGroundColor;

  /// function reture the recording sound file
  final Function(File soundFile) sendRequestFunction;

  /// recording Icon That pressesd to start record
  final Widget? recordIcon;

  /// recording Icon when user locked the record
  final Widget? recordIconWhenLockedRecord;

  /// use to change the backGround Icon when user recording sound
  final Color? recordIconBackGroundColor;

  /// use to change the Icon backGround color when user locked the record
  final Color? recordIconWhenLockBackGroundColor;

  /// use to change all recording widget color
  final Color? backGroundColor;
  final Color? voiceButtonColor;

  /// use to change the counter style
  final TextStyle? counterTextStyle;

  /// text to know user should drag in the left to cancel record
  final String? slideToCancelText;

  /// use to change slide to cancel textstyle
  final TextStyle? slideToCancelTextStyle;

  /// this text show when lock record and to tell user should press in this text to cancel recod
  final String? cancelText;
  final bool isAr;

  /// use to change cancel text style
  final TextStyle? cancelTextStyle;

  /// Chose the encode type
  final AudioEncoderType encode;

  /// use if you want change the raduis of un record
  final BorderRadius? radius;

  // use to change the counter back ground color
  final Color? counterBackGroundColor;
  final int? slideToCancelValue;
  // use to change lock icon to design you need it
  final Widget? lockButton;
  // use it to change send button when user lock the record
  final Widget? sendButtonIcon;
  final int? timeRecordLimitation;
  // ignore: sort_constructors_first
  const SocialMediaRecorder({
    this.sendButtonIcon,
    this.isAr = true,
    required this.sendRequestFunction,
    this.recordIcon,
    this.voiceButtonColor,
    this.lockButton,
    this.counterBackGroundColor,
    this.recordIconWhenLockedRecord,
    this.recordIconBackGroundColor = Colors.blue,
    this.recordIconWhenLockBackGroundColor = Colors.blue,
    this.backGroundColor,
    this.cancelTextStyle,
    this.counterTextStyle,
    this.slideToCancelTextStyle,
    this.slideToCancelText = " Slide to Cancel >",
    this.cancelText = "Cancel",
    this.encode = AudioEncoderType.AAC,
    this.cancelTextBackGroundColor,
    this.radius,
    Key? key,
    this.timeRecordLimitation,
    this.slideToCancelValue,
  }) : super(key: key);

  @override
  _SocialMediaRecorder createState() => _SocialMediaRecorder();
}

class _SocialMediaRecorder extends State<SocialMediaRecorder> {
  late SoundRecordNotifier soundRecordNotifier;

  @override
  void initState() {
    soundRecordNotifier = SoundRecordNotifier(
      sendRequestFunction: widget.sendRequestFunction,
      timeRecordLimitation: widget.timeRecordLimitation,
      slideToCancelValue: widget.slideToCancelValue,
    );
    soundRecordNotifier.isShow = false;
    soundRecordNotifier.voidInitialSound();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => soundRecordNotifier),
        ],
        child: Consumer<SoundRecordNotifier>(
          builder: (context, value, _) {
            return Directionality(
                textDirection: TextDirection.rtl, child: makeBody(value));
          },
        ));
  }

  Widget makeBody(SoundRecordNotifier state) {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (scrollEnd) {
            state.updateScrollValue(scrollEnd.globalPosition, context);
          },
          onHorizontalDragEnd: (x) {},
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: recordVoice(state),
          ),
        )
      ],
    );
  }

  Future<bool> _checkStorage() async {
    var isAndroid13OrHigher = false;
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      isAndroid13OrHigher = androidInfo.version.sdkInt >= 33;
    }
    final permission = (isAndroid13OrHigher || Platform.isIOS)
        ? Permission.photos
        : Permission.storage;
    final data = await checkPermission(
      permission: permission,
      title: widget.isAr ? 'تفعيل الارشيف' : 'Permission storage required',
      body: widget.isAr
          ? 'تفعيل الارشيف'
          : 'فعل الخيار للاستفادة من الرسائل الصوتية',
    );
    if (Platform.isAndroid) {
      final data1 = await checkPermission(
        permission: Permission.manageExternalStorage,
        title: widget.isAr ? 'تفعيل الارشيف' : 'Permission storage required',
        body: widget.isAr
            ? 'تفعيل الحافظة'
            : 'فعل الخيار للاستفادة من الرسائل الصوتية',
      );
      return data1;
    } else {
      return data;
    }
  }

  Future<bool> checkPermission({
    required Permission permission,
    required String title,
    required String body,
  }) async {
    PermissionStatus status = await permission.request();
    print('permission status: $status');
    if (status.isGranted) {
      return true;
    } else {
      showPermissionDialog(context, title, body);
    }
    // Recheck permission after dialog
    return await permission.status.isGranted;
  }

  void showPermissionDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Permission Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${title ?? ''}'),
            SizedBox(height: 16),
            Text('${body ?? ''}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget recordVoice(SoundRecordNotifier state) {
    if (state.lockScreenRecord == true) {
      return SoundRecorderWhenLockedDesign(
        cancelText: widget.cancelText,
        sendButtonIcon: widget.sendButtonIcon,
        cancelTextBackGroundColor: widget.cancelTextBackGroundColor,
        cancelTextStyle: widget.cancelTextStyle,
        counterBackGroundColor: widget.counterBackGroundColor,
        recordIconWhenLockBackGroundColor:
            widget.recordIconWhenLockBackGroundColor ?? Colors.blue,
        counterTextStyle: widget.counterTextStyle,
        recordIconWhenLockedRecord: widget.recordIconWhenLockedRecord,
        sendRequestFunction: widget.sendRequestFunction,
        soundRecordNotifier: state,
      );
    }

    return Listener(
      onPointerDown: (details) async {
        final result = await checkPermission(
            permission: Permission.microphone,
            title: widget.isAr
                ? 'تفعيل المايكروفون'
                : 'Permission Microphone required',
            body: widget.isAr
                ? 'فعل الخيار للاستفادة من الرسائل الصوتية'
                : 'we need this permission To make calls & voice messages activate this feature');
        if (result) {
          final data = await _checkStorage();
          if (data) {
            state.setNewInitialDraggableHeight(details.position.dy);
            state.resetEdgePadding(showSound: false);
            soundRecordNotifier.isShow = true;
            state.record();
          }
        }
      },
      onPointerUp: (details) async {
        if (!state.isLocked) {
          if (state.buttonPressed) {
            if (state.second > 1 || state.minute > 0) {
              String path = state.mPath;
              widget.sendRequestFunction(File(path));
              state.resetEdgePadding(
                showSound: false,
                sendSound: true,
              );
            } else {
              state.resetEdgePadding(showSound: true);
            }
          } else {
            state.resetEdgePadding(showSound: true);
          }
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: soundRecordNotifier.isShow ? 0 : 300),
        height: 50,
        width: (soundRecordNotifier.isShow)
            ? MediaQuery.of(context).size.width
            : 40,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(right: state.edge),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: soundRecordNotifier.isShow
                      ? BorderRadius.circular(12)
                      : widget.radius != null && !soundRecordNotifier.isShow
                          ? widget.radius
                          : BorderRadius.circular(0),
                  color: widget.voiceButtonColor ?? Colors.grey.shade100,
                ),
                child: Stack(
                  children: [
                    ShowMicWithText(
                      counterBackGroundColor: widget.counterBackGroundColor,
                      backGroundColor: widget.recordIconBackGroundColor,
                      recordIcon: widget.recordIcon,
                      shouldShowText: soundRecordNotifier.isShow,
                      soundRecorderState: state,
                      slideToCancelTextStyle: widget.slideToCancelTextStyle,
                      slideToCancelText: widget.slideToCancelText,
                    ),
                    if (soundRecordNotifier.isShow)
                      ShowCounter(
                          counterBackGroundColor: widget.counterBackGroundColor,
                          soundRecorderState: state),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: LockRecord(
                soundRecorderState: state,
                lockIcon: widget.lockButton,
              ),
            )
          ],
        ),
      ),
    );
  }
}
