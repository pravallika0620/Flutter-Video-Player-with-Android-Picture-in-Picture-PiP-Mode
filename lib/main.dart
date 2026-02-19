import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
    ),
    home: const VideoPlayerScreen(),
  ));
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  static const platform = MethodChannel('com.fluttercast.pip/controller');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/Flutter',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/video_metadata.json');
        
        final metadata = {
          "videoId": data['id'],
          "videoTitle": data['title'],
          "videoUrl": "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        };
        
        await file.writeAsString(json.encode(metadata));

        _controller = VideoPlayerController.networkUrl(
          Uri.parse(metadata['videoUrl'] as String),
        );

        await _controller!.initialize();

        final prefs = await SharedPreferences.getInstance();
        final lastPos = prefs.getInt('last_playback_position_seconds') ?? 0;
        await _controller!.seekTo(Duration(seconds: lastPos));

        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePosition() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'last_playback_position_seconds',
        _controller!.value.position.inSeconds,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _savePosition();
      platform.invokeMethod('enablePictureInPicture');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          key: const Key('error-message-container'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text("Oops! Connection failed", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('retry-button'),
                onPressed: _initializeData,
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Stack(
                    key: const Key('video-player-container'),
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller!),
                      VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        key: const Key('video-progress-bar'),
                        colors: const VideoProgressColors(
                          playedColor: Colors.deepPurpleAccent,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            key: const Key('play-pause-button'),
                            iconSize: 64,
                            color: Colors.white,
                            icon: Icon(
                              _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        key: const Key('pip-mode-button'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepPurpleAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => platform.invokeMethod('enablePictureInPicture'),
                        icon: const Icon(Icons.picture_in_picture_alt, color: Colors.deepPurpleAccent),
                        label: const Text(
                          'Background Play (PiP)',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }
}