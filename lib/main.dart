import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'simple_frame_app.dart';

void main() => runApp(const MainApp());

final _log = Logger("MainApp");

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

/// SimpleFrameAppState mixin helps to manage the lifecycle of the Frame connection outside of this file
class MainAppState extends State<MainApp> with SimpleFrameAppState {

  String _message = 'Connect to Frame, Start the Application, then Click "Say Hello!"';

  MainAppState() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  /// send a simple message to the frame display
  Future<void> run() async {
    currentState = ApplicationState.running;
    if (mounted) setState(() {});

    try {
      await frame!.sendString('frame.display.text("Hello, World!", 50, 100)', awaitResponse: false);
      await Future.delayed(const Duration(milliseconds: 150));
      await frame!.sendString('frame.display.show()', awaitResponse: false);
      _message = 'Hello World sent!';
    } catch (e) {
      _log.fine('Error executing application logic: $e');
    }

    currentState = ApplicationState.ready;
    if (mounted) setState(() {});
  }

  Future<void> cancel() async {
    currentState = ApplicationState.ready;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // work out the states of the footer buttons based on the app state
    List<Widget> pfb = [];

    switch (currentState) {
      case ApplicationState.disconnected:
        pfb.add(TextButton(onPressed: scanOrReconnectFrame, child: const Text('Connect')));
        pfb.add(const TextButton(onPressed: null, child: Text('Start')));
        pfb.add(const TextButton(onPressed: null, child: Text('Disconnect')));
        break;

      case ApplicationState.initializing:
      case ApplicationState.scanning:
      case ApplicationState.connecting:
      case ApplicationState.stopping:
      case ApplicationState.disconnecting:
        pfb.add(const TextButton(onPressed: null, child: Text('Connect')));
        pfb.add(const TextButton(onPressed: null, child: Text('Start')));
        pfb.add(const TextButton(onPressed: null, child: Text('Disconnect')));
        break;

      case ApplicationState.connected:
        pfb.add(const TextButton(onPressed: null, child: Text('Connect')));
        pfb.add(TextButton(onPressed: startApplication, child: const Text('Start')));
        pfb.add(TextButton(onPressed: disconnectFrame, child: const Text('Disconnect')));
        break;

      case ApplicationState.ready:
        pfb.add(const TextButton(onPressed: null, child: Text('Connect')));
        pfb.add(TextButton(onPressed: stopApplication, child: const Text('Stop')));
        pfb.add(const TextButton(onPressed: null, child: Text('Disconnect')));
        break;

      case ApplicationState.running:
        pfb.add(const TextButton(onPressed: null, child: Text('Connect')));
        pfb.add(TextButton(onPressed: stopApplication, child: const Text('Stop')));
        pfb.add(const TextButton(onPressed: null, child: Text('Disconnect')));
        break;
    }

    return MaterialApp(
      title: 'Hello World!',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Hello World!"),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 150),
                Text(_message),
              ]
            ),
          )
        ),
        floatingActionButton: currentState == ApplicationState.ready ?
          FloatingActionButton(onPressed: run, child: const Icon(Icons.message_outlined)) :
          FloatingActionButton(onPressed: cancel, child: const Icon(Icons.cancel)),
        persistentFooterButtons: pfb,
      ),
    );
  }
}
