import 'dart:async';
import 'dart:io';

import 'package:chatting/bindings.dart';
import 'package:chatting/myVoids.dart';
import 'package:chatting/src/audio_state.dart';
import 'package:chatting/src/globals.dart';
import 'package:chatting/src/widgets/flow_shader.dart';
import 'package:chatting/src/widgets/lottie_animation.dart';
import 'package:chatting/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:record/record.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../admin/chatRoom.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final AnimationController controller;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {

  final double lockerHeight = 200;
  double timerWidth = 0;

  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;

  DateTime? startTime;
  Timer? timer;
  String recordDuration = "00:00";
   Record record =Record();

  bool isLocked = false;
  bool showLottie = false;

  @override
  void initState() {
    super.initState();
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticInOut),
      ),
    );
    widget.controller.addListener(() {
      setState(() {

      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth = 100.w - 2 * Globals.defaultPadding - 4;
    timerAnimation = Tween<double>(begin: timerWidth + Globals.defaultPadding, end: 0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
    lockerAnimation = Tween<double>(begin: lockerHeight + Globals.defaultPadding, end: 0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    record.dispose();
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  /// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Future<void> uploadToFirebase(String filePath) async {
    // Create a reference to Firebase Storage
    final firebaseStorage = FirebaseStorage.instance;
    final storageRef = firebaseStorage.ref().child('audio_files/${layCtr.selectedChatRoomID}-${cUser.name}-${layCtr.selectedUser.name}/${DateTime.now().millisecondsSinceEpoch}.m4a');

    // Upload the audio file to Firebase Storage
    File file = File(filePath);
    await storageRef.putFile(file);

    // Get the download URL of the uploaded file
    final downloadUrl = await storageRef.getDownloadURL();

    // Save the URL to Firestore
    final firestore = FirebaseFirestore.instance;

    layCtr.sendMessage(downloadUrl);

    print('File uploaded and URL saved to Firestore: $downloadUrl');
  }


  Widget cancelSlider() {
    return Positioned(
      right: -timerAnimation.value-15,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: cancelSliderCol,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              showLottie ? const LottieAnimation() : Text(recordDuration,style: TextStyle(color: Colors.white),),
              const SizedBox(width: 55),
              FlowShader(
                child: Row(
                  children: const [
                    Icon(Icons.keyboard_arrow_left,color: Colors.white,),
                    Text("Slide to cancel",style: TextStyle(color: Colors.white),)
                  ],
                ),
                duration: const Duration(seconds: 3),
                flowColors: const [Colors.white, Colors.grey],
              ),
              const SizedBox(width: 55),
            ],
          ),
        ),
      ),
    );
  }
  bool checkIsLocked(Offset offset) {
    return (offset.dy < -35);
  }
  bool isCancelled(Offset offset, BuildContext context) {
    return (offset.dx < -(MediaQuery.of(context).size.width * 0.2));
  }


  Widget audioButton() {
    return GestureDetector(
      child: Transform.scale(
        scale: buttonScaleAnimation.value,
        child: Container(
          child: const Icon(Icons.mic,color: Colors.white,),
          height: size,
          width: size,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: orangeCol,
          ),
        ),
      ),
      onLongPressDown: (_) {
        debugPrint("onLongPressDown");
        widget.controller.forward();
      },
      onLongPressEnd: (details) async { /// IF RELEASE
        debugPrint("onLongPressEnd");

        if (isCancelled(details.localPosition, context)) {///cancel
          Vibrate.feedback(FeedbackType.heavy);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          setState(() {
            showLottie = true;
          });

          Timer(const Duration(milliseconds: 1440), () async {
            widget.controller.reverse();
            debugPrint("Cancelled recording");
            var filePath = await record.stop();
            debugPrint(filePath);
            File(filePath!).delete();
            debugPrint("Deleted $filePath");
            showLottie = false;
          });


        } else if (checkIsLocked(details.localPosition)) { /// keep recording if locked
          widget.controller.reverse();

          Vibrate.feedback(FeedbackType.heavy);
          debugPrint("Locked recording");
          debugPrint(details.localPosition.dy.toString());
          setState(() {
            isLocked = true;
          });
        } else { /// send
          widget.controller.reverse();

          Vibrate.feedback(FeedbackType.success);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          var filePath = await Record().stop();
          AudioState.files.add(filePath!);
         // Globals.audioListKey.currentState!.insertItem(AudioState.files.length - 1);

          if (filePath != null) {
            await uploadToFirebase(filePath);
          }
          debugPrint(filePath);
        }
      },
      onLongPressCancel: () {
        debugPrint("onLongPressCancel");
        widget.controller.reverse();
      },
      onLongPress: () async {
        debugPrint("onLongPress");
        Vibrate.feedback(FeedbackType.success);
        if (await Record().hasPermission()) {
          record = Record();
          await record.start(/// start .......
            path: Globals.documentPath + "audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
            encoder: AudioEncoder.AAC,
            bitRate: 128000,
            samplingRate: 44100,
          );
          startTime = DateTime.now();
          timer = Timer.periodic(const Duration(seconds: 1), (_) {
            final minDur = DateTime.now().difference(startTime!).inMinutes;
            final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
            String min = minDur < 10 ? "0$minDur" : minDur.toString();
            String sec = secDur < 10 ? "0$secDur" : secDur.toString();
            setState(() {
              recordDuration = "$min:$sec";
            });
          });
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        //lockSlider(),
        cancelSlider(),
        audioButton(),
        //if (isLocked) timerLocked(),
      ],
    );
  }

  /// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Widget lockSlider() {
    return Positioned(
      bottom: -lockerAnimation.value,
      child: Container(
        height: lockerHeight,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: Colors.black,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const FaIcon(FontAwesomeIcons.lock, size: 20),
            const SizedBox(height: 8),
            FlowShader(
              direction: Axis.vertical,
              child: Column(
                children: const [
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget timerLocked() {
    return Positioned(
      right: 0,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 25),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              Vibrate.feedback(FeedbackType.success);
              timer?.cancel();
              timer = null;
              startTime = null;
              recordDuration = "00:00";

              var filePath = await Record().stop();
              AudioState.files.add(filePath!);
              //Globals.audioListKey.currentState!.insertItem(AudioState.files.length - 1);
              debugPrint(filePath);
              setState(() {
                isLocked = false;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(recordDuration),
                FlowShader(
                  child: const Text("Tap lock to stop"),
                  duration: const Duration(seconds: 3),
                  flowColors: const [Colors.white, Colors.grey],
                ),
                const Center(
                  child: FaIcon(
                    FontAwesomeIcons.lock,
                    size: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
