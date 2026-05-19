import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AppYoutubePlayer extends StatefulWidget {
  final String youtubeId; // Có thể truyền ID hoặc URL đầy đủ
  final bool autoPlay;

  const AppYoutubePlayer({
    super.key,
    required this.youtubeId,
    this.autoPlay = false,
  });

  @override
  State<AppYoutubePlayer> createState() => _AppYoutubePlayerState();
}

class _AppYoutubePlayerState extends State<AppYoutubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Tự động kiểm tra nếu là URL thì convert sang ID
    String videoId = widget.youtubeId;
    if (videoId.contains('youtube.com') || videoId.contains('youtu.be')) {
      videoId = YoutubePlayer.convertUrlToId(videoId) ?? '';
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).primaryColor,
        progressColors: ProgressBarColors(
          playedColor: Theme.of(context).primaryColor,
          handleColor: Theme.of(context).primaryColor.withOpacity(0.8),
        ),
      ),
    );
  }
}
