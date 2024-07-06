import 'dart:async';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:image2pdf_easyconvert/images_list.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class SelectedImages extends StatefulWidget {
  final ImagesList imagesList;
  final String screenName;

  const SelectedImages({
    super.key,
    required this.imagesList,
    required this.screenName,
    required TextStyle textStyle,
  });

  @override
  State<SelectedImages> createState() => _SelectedImagesState();
}

class _SelectedImagesState extends State<SelectedImages> {
  double _progressValue = 0;
  bool _isExporting = false;
  int _convertedImage = 0;
  String _fileName = '';
  bool _isPermissionRequested = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (!_isPermissionRequested) {
      _isPermissionRequested = true;
      var status = await Permission.storage.request();
      if (status.isDenied) {
        return;
      }
    }
  }

  Future<void> _showFileNameDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String inputFileName = '';
        return AlertDialog(
          title: const Text('Enter PDF Name'),
          content: TextField(
            onChanged: (value) {
              inputFileName = value;
            },
            decoration: const InputDecoration(hintText: 'Enter PDF Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(inputFileName);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _fileName = result;
      });
      _convertImage();
    }
  }

  Future<void> _convertImage() async {
    setState(() {
      _isExporting = true;
      _progressValue = 0;
      _convertedImage = 0;
    });

    try {
      final pathToSave = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOCUMENTS);
      final pdf = pw.Document();

      for (final imagePath in widget.imagesList.imagePaths) {
        final imageBytes = await File(imagePath.path).readAsBytes();
        final image = img.decodeImage(imageBytes);

        if (image != null) {
          final pdfImage = pw.MemoryImage(imageBytes);
          pdf.addPage(
            pw.Page(build: (pw.Context context) {
              return pw.Center(child: pw.Image(pdfImage));
            }),
          );
        }

        setState(() {
          _convertedImage++;
          _progressValue =
              _convertedImage / widget.imagesList.imagePaths.length;
        });
      }

      final outputFile = File('$pathToSave/${path.basename(_fileName)}.pdf');
      await outputFile.writeAsBytes(await pdf.save());

      MediaScanner.loadMedia(path: outputFile.path);

      if (mounted) {
        setState(() {
          _isExporting = false;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('PDF Saved'),
              content: Text(
                  'Success! PDF saved to your document directory as ${path.basename(_fileName)}.pdf'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _addImages() async {
    final picker = ImagePicker();
    final images = widget.screenName == "Selected Images"
        ? await picker.pickMultiImage()
        : [await picker.pickImage(source: ImageSource.camera)];

    if (images.isNotEmpty) {
      setState(() {
        widget.imagesList.imagePaths.addAll(images.whereType<XFile>());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      widget.imagesList.imagePaths.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.screenName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 233, 6, 6),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (!_isExporting)
            Semantics(
              label: 'Image Grid',
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: widget.imagesList.imagePaths.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.file(
                        File(widget.imagesList.imagePaths[index].path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Semantics(
                          label: 'Remove Image',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (_isExporting)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Exporting ${(_progressValue * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !_isExporting,
        child: Semantics(
          label: 'Add Images From Gallery',
          child: FloatingActionButton(
            onPressed: _addImages,
            backgroundColor: const Color.fromARGB(255, 238, 9, 9),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: !_isExporting,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Semantics(
            label: 'Convert the Image to PDF',
            button: true,
            child: MaterialButton(
              color: const Color.fromARGB(255, 238, 9, 9),
              textColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              onPressed: _showFileNameDialog,
              child: Semantics(
                label: 'Convert The Selected image to Pdf',
                child: const Text(
                  'Convert',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
