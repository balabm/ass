// import 'package:flutter/material.dart';
// import 'audio_player_widget.dart';
// import 'fade_in_widget.dart';
// import 'message_animation_widget.dart';

// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isUser;
//   final bool isThinking;
//   final bool isAudioMessage;
//   final String? audioPath;
//   final String? audioBase64; // Add this

//   final void Function(String)? onPlayAudio;

//   const ChatBubble({
//     Key? key,
//     required this.message,
//     required this.isUser,
//     this.isThinking = false,
//     this.isAudioMessage = false,
//     this.audioPath,
//     this.audioBase64, // Add this
//     this.onPlayAudio,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isUser) // For avatar on the left
//             Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: CircleAvatar(
//                 backgroundColor: Colors.purple[200],
//                 child: Text(
//                   'A',
//                   style: TextStyle(color: Colors.white),
//                 ), // Replace with avatar image if available
//               ),
//             ),
//           Flexible(
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 8),
//               decoration: BoxDecoration(
//                 color: isUser ? Colors.teal[100] : Colors.grey[200],
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                   bottomLeft: isUser ? Radius.circular(20) : Radius.zero,
//                   bottomRight: isUser ? Radius.zero : Radius.circular(20),
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     message,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         "18.00",
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                       if (isUser) Icon(Icons.check, size: 16, color: Colors.grey[600])
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isUser) // For avatar on the right
//             Padding(
//               padding: const EdgeInsets.only(left: 8.0),
//               child: CircleAvatar(
//                 backgroundColor: Colors.teal[200],
//                 child: Text(
//                   'U',
//                   style: TextStyle(color: Colors.white),
//                 ), // Replace with avatar image if available
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'audio_player_widget.dart';
import 'fade_in_widget.dart';
import 'message_animation_widget.dart';
import 'package:intl/intl.dart'; // Add this for formatting the timestamp

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isThinking;
  final bool isAudioMessage;
  final String? audioPath;
  final String? audioBase64; // Add this

  final void Function(String)? onPlayAudio;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    this.isThinking = false,
    this.isAudioMessage = false,
    this.audioPath,
    this.audioBase64, // Add this
    this.onPlayAudio,
  }) : super(key: key);

  String _getCurrentTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }
@override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.purple[300],
              child: Text(
                "A", // Assistant avatar
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          const SizedBox(width: 8), // Space between avatar and bubble
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.teal[100] : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft:
                          isUser ? Radius.circular(16) : Radius.circular(0),
                      bottomRight:
                          isUser ? Radius.circular(0) : Radius.circular(16),
                    ),
                  ),
                  child: isAudioMessage && audioPath != null
                      ? AudioPlayerWidget(
                          audioPath: audioPath!,
                          asrText: message,
                          onPlayAudio: onPlayAudio,
                        )
                      : Text(
                          message,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                ),
                const SizedBox(height: 4), // Space between bubble and timestamp
                Text(
                  _getCurrentTime(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // Space for user avatar
          if (isUser)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.teal[300],
              child: Text(
                "U", // User avatar
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}