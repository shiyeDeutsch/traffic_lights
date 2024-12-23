import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: TrafficLightsDemo()));
}

class TrafficLightsDemo extends StatefulWidget {
  @override
  State<TrafficLightsDemo> createState() => _TrafficLightsDemoState();
}

class _TrafficLightsDemoState extends State<TrafficLightsDemo> {
  final Random _rand = Random();
  final int _numLights = 1000;    
  // 9 seconds for a full cycle     
  final double _cycleLength = 9.0;

  bool _sync = false;                
  late ValueNotifier<double> _timeNotifier;
  late List<double> _offsets;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // Holds the "global" time for all traffic lights
    _timeNotifier = ValueNotifier<double>(0.0);

    // Generate random offsets for each traffic light
    _offsets = List.generate(_numLights, (_) => _rand.nextDouble() * 5);

    // Update time every 100 milliseconds
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      _timeNotifier.value += 0.1; 
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }
// Toggle sync mode
  void _toggleSync() {
    setState(() => _sync = !_sync);  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sync ? 'Synchronized' : 'Chaos' ' mode'),
        actions: [
          TextButton(
            onPressed: _toggleSync,
          child: Text(
            'change to ${_sync ? 'Chaos' : 'Sync'}',
            style: const TextStyle(color: Colors.red),
          ),
          ),
        ],
      ),
      body: GridView.builder(
      
        itemCount: _numLights,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, i) {
          return ValueListenableBuilder<double>(
          
            valueListenable: _timeNotifier,
            builder: (context, time, child) {
              // Calculate the local time for this light
              // Use the offset unless we are in "sync" mode
              double localTime = time - (_sync ? 0 : _offsets[i]);

              // If it's "before" starting, show red
              if (localTime <= 0) {
                return TrafficLight(red: true, yellow: false, green: false);
              }

              // Determine where in the cycle (9 seconds) we are
              double t = localTime % _cycleLength;

              bool red = false, yellow = false, green = false;
              if (t < 3) {
                red = true;
              } else if (t < 4.5) {
                red = true;
                yellow = true;
              } else if (t < 7.5) {
                green = true;
              } else {
                yellow = true;
              }
              return TrafficLight(red: red, yellow: yellow, green: green);
            },
          );
        },
      ),
    );
  }
}

class TrafficLight extends StatelessWidget {
  final bool red;
  final bool yellow;
  final bool green;

  const TrafficLight({
    this.red = false,
    this.yellow = false,
    this.green = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
 //     padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircle(Colors.red, red),
          SizedBox(height: 8),
          _buildCircle(Colors.yellow, yellow),
          SizedBox(height: 8),
          _buildCircle(Colors.green, green),
        ],
      ),
    );
  }

  Widget _buildCircle(Color color, bool on) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: on ? color : Colors.grey[700],
        shape: BoxShape.circle,
      ),
    );
  }
}
