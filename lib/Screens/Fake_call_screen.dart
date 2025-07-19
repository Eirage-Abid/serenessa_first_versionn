// fake_call_screen.dart (Updated)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Import for playing sound

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({Key? key}) : super(key: key);

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  final player = AudioPlayer();
  bool _isCallPickedUp = false;
  String _callerName = 'Baba'; // You can make this dynamic
  String _callerNumber = '03131302336'; // You can make this dynamic
  Duration _callDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRinging();
  }

  Future<void> _startRinging() async {
    await player.play(AssetSource('sounds/ringing.mp3')); // Start playing the ringing sound
  }

  Future<void> _pickupCall() async {
    setState(() {
      _isCallPickedUp = true;
    });
    await player.stop(); // Stop the ringing sound
    await player.play(AssetSource('sounds/silent.mp3')); // Play a silent sound for the "on call" state
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = _callDuration + const Duration(seconds: 1);
      });
    });
  }

  void _endFakeCall() {
    setState(() {
      _isCallPickedUp = false;
    });
    player.stop();
    _timer?.cancel();
    Navigator.of(context).pop(); // Go back to the previous screen
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    player.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              _isCallPickedUp ? Icons.phone_in_talk : Icons.call,
              size: 100,
              color: _isCallPickedUp ? Colors.greenAccent : Colors.white,
            ),
            const SizedBox(height: 30),
            Text(
              _callerName,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _callerNumber,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 50),
            Text(
              _isCallPickedUp ? _formatDuration(_callDuration) : 'Incoming Call...',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (!_isCallPickedUp)
                  ElevatedButton(
                    onPressed: _endFakeCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isCallPickedUp ? _endFakeCall : _pickupCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCallPickedUp ? Colors.redAccent : Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _isCallPickedUp ? 'End Call' : 'Pick Up',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}