import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_note/welcome_screeen.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import "package:universal_html/html.dart" show AnchorElement;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  File _selectedFile = File('');
  Color _selectedStrokeColor = Colors.black;
  Color _selectedCanvasColor = Colors.white;

  void _showColorPicker(BuildContext context) {
    print(_selectedStrokeColor);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Stroke Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedStrokeColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedStrokeColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    print(_selectedStrokeColor);
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Discard Canvas'),
          content: const Text(
              'Do you want to discard the current canvas and start over?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _signaturePadKey.currentState!.clear();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showCanvasColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Canvas Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedCanvasColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedCanvasColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveImage() async {
    ui.Image data =
        await _signaturePadKey.currentState!.toImage(pixelRatio: 2.0);
    final byteData = await data.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes = byteData!.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    if (kIsWeb) {
      AnchorElement(
        href:
            'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(imageBytes)}',
      )
        ..setAttribute('download', 'Output.png')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName =
          Platform.isWindows ? '$path\\Output.png' : '$path/Output.png';
      final File file = File(fileName);
      _selectedFile = file;
      await file.writeAsBytes(imageBytes, flush: true);
      OpenFile.open(fileName);
    }

    print('Started uploading');

    print(_selectedFile);
    print('It\'s done');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SignCapture App'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      height: 600,
                      width: double.infinity,
                      child: SfSignaturePad(
                        key: _signaturePadKey,
                        backgroundColor: _selectedCanvasColor,
                        strokeColor: _selectedStrokeColor,
                        minimumStrokeWidth: 2.0,
                        maximumStrokeWidth: 4.0,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          _showColorPicker(context);
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.palette),
                            Text('Pen Color'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          _signaturePadKey.currentState!.clear();
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.brush),
                            Text('Clear'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      InkWell(
                        onTap: _saveImage,
                        child: const Column(
                          children: [
                            Icon(Icons.save),
                            Text('Save'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          _showCanvasColorPicker(context);
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.format_paint),
                            Text('Canvas Color'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: _clearCanvas,
                        child: const Column(
                          children: [
                            Icon(Icons.clear),
                            Text('Discard'),
                          ],
                        ),
                      ),
                    ],
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
