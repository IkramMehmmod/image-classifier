import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fruit_classifier_app/screens/result_page.dart';
import 'package:fruit_classifier_app/helpers/tflite_helper.dart';

class ImagePreview extends StatefulWidget {
  final File image;

  ImagePreview({required this.image});

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool _loading = false;
  TFLiteHelper tfliteHelper = TFLiteHelper();
  String _prediction = "";
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    tfliteHelper.loadModel();
  }

  Future<void> _processImage() async {
    setState(() {
      _loading = true;
    });

    try {
      Map<String, dynamic> result =
          await tfliteHelper.classifyImage(widget.image);
      int? predictedIndex = result["prediction"];
      double? confidence = result["confidence"];

      if (predictedIndex != null && confidence != null) {
        setState(() {
          _prediction = _mapClassIndexToLabel(predictedIndex);
          _confidence = confidence;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultPage(
              image: widget.image,
              prediction: _prediction,
              confidence: _confidence,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Error processing image: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _mapClassIndexToLabel(int index) {
    List<String> labels = [
      'Apple',
      'Banana',
      'Blueberry',
      'Cherry',
      'Grapes',
      'Kiwi',
      'Mango',
      'Orange',
      'Strawberry',
      'Watermelon'
    ];
    return labels[index];
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Preview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[100]!, Colors.green[300]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'imagePreview',
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          widget.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  'Is this the image you want to classify?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back),
                        label: Text('Select Again',
                            style: TextStyle(fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green[800],
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _processImage,
                        icon: const Icon(Icons.check),
                        label: const Text('Process Image',
                            style: TextStyle(fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
