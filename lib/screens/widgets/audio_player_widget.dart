// lib/screens/widgets/audio_player_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final String? asrText;
  final String? audioBase64;  // Add this
  final Function(String)? onPlayAudio;

  const AudioPlayerWidget({
    Key? key,
    required this.audioPath,
    this.asrText,
    this.audioBase64,
    this.onPlayAudio,
  }) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isLoading = true;
  double _playbackProgress = 0.0;
  late AnimationController _progressController;
  Duration _audioDuration = Duration.zero;
  FlutterSoundPlayer? _audioPlayer;
  final Duration _currentPosition = Duration.zero;
  String? _localAudioPath;

  @override
  void initState() {
    super.initState();
    
    _initializeAudio();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _progressController.addListener(() {
      setState(() {
        _playbackProgress = _progressController.value;
      });
    });
  }

  Future<void> _initializeAudio() async {
    try {
      if (widget.audioBase64 != null) {
        final bytes = base64Decode(widget.audioBase64!);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav');
        await file.writeAsBytes(bytes);
        _localAudioPath = file.path;
      } else {
        _localAudioPath = widget.audioPath;
      }
      print('Audio file path: $_localAudioPath');
      print('File exists: ${File(_localAudioPath!).existsSync()}');
      print('File size: ${await File(_localAudioPath!).length()} bytes');
      await _initializePlayer();
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

Future<void> _initializePlayer() async {
  try {
    // Close any existing player instance
    if (_audioPlayer != null) {
      await _audioPlayer!.closePlayer();
      _audioPlayer = null;
    }

    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();
    
    // Only try to load duration if we have a valid audio path
    if (_localAudioPath != null && File(_localAudioPath!).existsSync()) {
      await _loadAudioDuration();
    } else {
      print('Audio file does not exist at path: $_localAudioPath');
    }
  } catch (e) {
    print('Error initializing player: $e');
    // Reset player state on error
    _audioPlayer = null;
  }
}
Future<void> _loadAudioDuration() async {
  if (_audioPlayer == null || !_audioPlayer!.isOpen()) {
    print('Audio player not initialized');
    return;
  }

  try {
    setState(() => _isLoading = true);
    
    // First check if the file exists and is readable
    final file = File(_localAudioPath!);
    if (!await file.exists()) {
      throw Exception('Audio file does not exist');
    }

    // Set up player parameters
    await _audioPlayer!.setSubscriptionDuration(const Duration(milliseconds: 500));
    
    // Try to get duration without actually playing
    Duration? duration;
    
    try {
      duration = await _audioPlayer!.startPlayer(
        fromURI: _localAudioPath,
        whenFinished: () {
          _audioPlayer?.stopPlayer();
          if (mounted) setState(() => _isPlaying = false);
        },
      );
      // Immediately stop after getting duration
      await _audioPlayer!.stopPlayer();
    } catch (e) {
      print('Error getting duration: $e');
      // If we can't get duration, set a default or leave as 0
      duration = Duration.zero;
    }

    if (mounted) {
      setState(() {
        _audioDuration = duration ?? Duration.zero;
        _progressController.duration = _audioDuration;
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error loading audio duration: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _audioDuration = Duration.zero;
        _progressController.duration = _audioDuration;
      });
    }
  }
}
void _togglePlayback() {
  setState(() {
    _isPlaying = !_isPlaying;
  });
  widget.onPlayAudio?.call(widget.audioPath);

  if (_isPlaying) {
    print('Starting playback');
    _audioPlayer!.startPlayer(
      fromURI: _localAudioPath,
      whenFinished: () {
        print('Playback finished');
        setState(() {
          _isPlaying = false;
          _playbackProgress = 0;
        });
        _audioPlayer!.stopPlayer();
      },
    );

    _progressController.forward(from: _playbackProgress);
  } else {
    print('Pausing playback');
    _audioPlayer!.pausePlayer();
    _progressController.stop();
  }
}
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade50.withOpacity(0.9),
            Colors.white.withOpacity(0.95),
            Colors.teal.shade50.withOpacity(0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Outer shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          // Inner highlight
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            spreadRadius: -1,
            offset: const Offset(-4, -4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio Controls Row
                Row(
                  children: [
                    GestureDetector(
                      onTap: _togglePlayback,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            ),
                            child: Slider(
                              value: _playbackProgress,
                              onChanged: (value) async {
                                setState(() => _playbackProgress = value);
                                final position =
                                    (_audioDuration.inMilliseconds * value).round();
                                await _audioPlayer?.seekToPlayer(
                                  Duration(milliseconds: position),
                                );
                              },
                              activeColor: Colors.teal,
                              inactiveColor: Colors.grey.shade300,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_currentPosition),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _formatDuration(_audioDuration),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // ASR Text Section
                if (widget.asrText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                    
                     
                      child: Row(
                        children: [
                          // const Icon(
                          //   Icons.mic,
                          //   color: Colors.teal,
                          // ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.asrText!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _audioPlayer?.closePlayer();
    super.dispose();
  }
}