import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';

mixin AudioHandler<T extends StatefulWidget> on State<T> {
  FlutterSoundRecorder? audioRecorder;
  FlutterSoundPlayer? audioPlayer;
  bool isRecording = false;
  bool isPlaying = false;
  String? recordedFilePath;
  DateTime? recordingStartTime;
  Timer? recordingTimer;
  Duration recordingDuration = Duration.zero;

  Future<void> initializeAudio() async {
    audioRecorder = FlutterSoundRecorder();
    audioPlayer = FlutterSoundPlayer();
    await initializeRecorder();
    await initializePlayer();
  }

  Future<void> initializeRecorder() async {
    await audioRecorder!.openRecorder();
    await audioRecorder!.setSubscriptionDuration(const Duration(milliseconds: 10));
    print("Recorder initialized");
  }

  Future<void> initializePlayer() async {
  try {
    if (audioPlayer == null) {
      audioPlayer = FlutterSoundPlayer();
    }
    
    if (!audioPlayer!.isOpen()) {
      await audioPlayer!.openPlayer();
      await audioPlayer!.setSubscriptionDuration(const Duration(milliseconds: 100));
    }
    print("Player initialized");
  } catch (e) {
    print("Error initializing player: $e");
    // Try to recover by creating a new instance
    audioPlayer = FlutterSoundPlayer();
    await audioPlayer!.openPlayer();
  }
}


  void disposeAudio() {
    recordingTimer?.cancel();
    audioRecorder?.closeRecorder();
    audioPlayer?.closePlayer();
    audioRecorder = null;
    audioPlayer = null;
  }

  Future<void> startRecording() async {
  try {
    Directory tempDir = await getTemporaryDirectory();
    // Generate unique filename using timestamp
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    recordedFilePath = path.join(tempDir.path, 'audio_$timestamp.wav');

     // Make sure recorder is initialized
    if (!audioRecorder!.isRecording) {
      await initializeRecorder();
    }

    await audioRecorder!.startRecorder(
      toFile: recordedFilePath,
      codec: Codec.pcm16WAV,
      sampleRate: 16000, // Specify a standard sample rate
      numChannels: 1,    // Mono recording
    );

    setState(() {
      isRecording = true;
      recordingStartTime = DateTime.now();
      recordingDuration = Duration.zero;
    });

    recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (recordingStartTime != null && mounted) {
        setState(() {
          recordingDuration = DateTime.now().difference(recordingStartTime!);
        });
      }
    });

    print("Recording started at: $recordedFilePath");
  } catch (e) {
    print("Error starting recording: $e");
    // Try to recover
    await initializeRecorder();
  }
}

  Future<void> cancelRecording() async {
    try {
      recordingTimer?.cancel();
      await audioRecorder!.stopRecorder();
      if (recordedFilePath != null && File(recordedFilePath!).existsSync()) {
        await File(recordedFilePath!).delete();
      }
      if (mounted) {
        setState(() {
          isRecording = false;
          recordingStartTime = null;
          recordingDuration = Duration.zero;
        });
      }
      print("Recording cancelled");
    } catch (e) {
      print("Error cancelling recording: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      recordingTimer?.cancel();
      await audioRecorder!.stopRecorder();
      if (mounted) {
        setState(() {
          isRecording = false;
          recordingStartTime = null;
          recordingDuration = Duration.zero;
        });
      }
      print("Recording stopped");
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }
Future<void> playAudio(String audioPath) async {
  try {
    print('Playing audio from path: $audioPath');
    
    // Check if file exists and is valid
    if (!File(audioPath).existsSync()) {
      print('Audio file does not exist at path: $audioPath');
      return;
    }

    if (isPlaying) {
      print('Stopping current playback');
      await audioPlayer!.stopPlayer();
      setState(() => isPlaying = false);
      return;
    }

    // Make sure the player is properly initialized
    if (!audioPlayer!.isOpen()) {
      await initializePlayer();
    }

    print('Starting playback');
    await audioPlayer!.startPlayer(
      fromURI: audioPath,
      codec: Codec.pcm16WAV, // Specify the codec since you're recording in WAV
      whenFinished: () {
        print('Playback finished');
        if (mounted) {
          setState(() => isPlaying = false);
        }
      },
    );
    
    setState(() => isPlaying = true);
  } catch (e) {
    print('Error playing audio: $e');
    // Reset playing state in case of error
    setState(() => isPlaying = false);
    
    // Try to reinitialize player if there was an error
    try {
      await audioPlayer!.closePlayer();
      await initializePlayer();
    } catch (reinitError) {
      print('Error reinitializing player: $reinitError');
    }
  }
}

  Future<String> zipRecordedAudio() async {
    Directory tempDir = await getTemporaryDirectory();
    String zipFilePath = path.join(tempDir.path, 'audio_zip.zip');

    final zipEncoder = ZipFileEncoder();
    zipEncoder.create(zipFilePath);
    zipEncoder.addFile(File(recordedFilePath!));
    zipEncoder.close();

    return zipFilePath;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes % 60);
    final seconds = twoDigits(duration.inSeconds % 60);
    return "${hours != '00' ? '$hours:' : ''}$minutes:$seconds";
  }
}
