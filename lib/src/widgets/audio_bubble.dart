import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chatting/src/globals.dart';
import 'package:chatting/styles.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AudioBubble extends StatefulWidget {
  const AudioBubble({Key? key, required this.filepath}) : super(key: key);

  final String filepath;

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {
  final player = AudioPlayer();
  Duration? duration;

  @override
  void initState() {
    super.initState();

    //player.setFilePath(widget.filepath).then((value) { // offline
    player.setUrl(widget.filepath).then((value) {//online
      setState(() {
        duration = value;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //SizedBox(width: MediaQuery.of(context).size.width * 0.4),
          SizedBox(
            width: 50.w,
            child: Container(
              height: 35,
              //width: 50,
              padding: const EdgeInsets.only(left: 12, right: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Globals.borderRadius - 10),
                color: blueCol,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const SizedBox(height: 4),
                  Row(
                    children: [
                      StreamBuilder<PlayerState>(
                        stream: player.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                            return GestureDetector(
                              child: const Icon(Icons.play_arrow,color: Colors.white,),
                              onTap: player.play,
                            );
                          } else if (playing != true) {
                            return GestureDetector(
                              child: const Icon(Icons.play_arrow,color: Colors.white,),
                              onTap: player.play,
                            );
                          } else if (processingState != ProcessingState.completed) {
                            return GestureDetector(
                              child: const Icon(Icons.pause,color: Colors.white,),
                              onTap: player.pause,
                            );
                          } else {
                            return GestureDetector(
                              child: const Icon(Icons.replay,color: Colors.white,),
                              onTap: () {
                                player.seek(Duration.zero);
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StreamBuilder<Duration>(
                          stream: player.positionStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: snapshot.data!.inMilliseconds / (duration?.inMilliseconds ?? 1),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        prettyDuration(
                                            snapshot.data! == Duration.zero
                                                ? duration ?? Duration.zero
                                                : snapshot.data!),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return const LinearProgressIndicator();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String prettyDuration(Duration d) {
    var min = d.inMinutes < 10 ? "0${d.inMinutes}" : d.inMinutes.toString();
    var sec = d.inSeconds < 10 ? "0${d.inSeconds}" : d.inSeconds.toString();
    return min + ":" + sec;
  }
}


/// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
class BblChat extends StatefulWidget {
  final bool isSender;
  final bool tail;
  final Color color;
  final bool sent;
  final bool delivered;
  final bool seen;
  final Widget widget;
  final bool isVoice;
  final TextStyle textStyle;
  final BoxConstraints? constraints;

  const BblChat({
    Key? key,
    this.isSender = true,
    this.constraints,
    required this.widget,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.isVoice = false,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
  }) : super(key: key);

  @override
  _BblChatState createState() => _BblChatState();
}

class _BblChatState extends State<BblChat> {
  // Remove the AnimationController and its initialization
  // Remove the `_opacityAnimation` animation

  @override
  void initState() {
    super.initState();
    // No initialization needed since we are removing the animation
  }

  @override
  void dispose() {
    // No need to dispose of AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (widget.sent) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (widget.delivered) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (widget.seen) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Align(
      alignment: widget.isSender ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: CustomPaint(
          painter: SpecialChatBubbleThree(
              color: widget.color,
              alignment: widget.isSender ? Alignment.topRight : Alignment.topLeft,
              tail: widget.tail
          ),
          // Replace AnimatedOpacity with Opacity set to 1.0
          child: Opacity(
            opacity: 1.0, // No animation, always opaque
            child: Container(
              constraints: widget.constraints ?? BoxConstraints(maxWidth: 55.w),
              margin: widget.isSender
                  ? stateTick
                  ? const EdgeInsets.fromLTRB(7, 7, 14, 7)
                  : const EdgeInsets.fromLTRB(7, 7, 17, 7)
                  : const EdgeInsets.fromLTRB(17, 7, 7, 7),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: stateTick
                        ? const EdgeInsets.only(left: 4, right: 20)
                        : const EdgeInsets.only(left: 4, right: 4),
                    child: widget.widget,
                  ),
                  if (stateIcon != null && stateTick)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: stateIcon,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
