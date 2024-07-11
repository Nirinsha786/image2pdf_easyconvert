import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

class CreatedPDFsPage extends StatefulWidget {
  final String directoryPath;

  const CreatedPDFsPage({super.key, required this.directoryPath});

  @override
  State<CreatedPDFsPage> createState() => _CreatedPDFsPageState();
}

class _CreatedPDFsPageState extends State<CreatedPDFsPage> {
  List<FileSystemEntity> _pdfFiles = [];
  final List<FileSystemEntity> _selectedFiles = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadPDFFiles();
  }

  Future<void> _loadPDFFiles() async {
    try {
      final directory = Directory(widget.directoryPath);
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.pdf',),)
          .toList();
      setState(() {
        _pdfFiles = files;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading PDF files: $e');
      }
    }
  }

  void _toggleSelection(FileSystemEntity file) {
    setState(() {
      if (_selectedFiles.contains(file)) {
        _selectedFiles.remove(file);
      } else {
        _selectedFiles.add(file);
      }
    });
  }

  Future<void> _openPDFFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        if (kDebugMode) {
          print('Error opening file: ${result.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening file: $e');
      }
    }
  }

  Future<void> _sharePDFFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing file: $e');
      }
    }
  }

  Future<void> _deleteSelectedFiles() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Semantics(
          label: 'This Deletes the selected pdf File',
          child: const Text('Confirm Delete',),),
        content:
            Semantics(
              label: 'By clicking on this it will confirm that u want to delete the File',
              child: const Text('Are you sure you want to delete the selected files?',),),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Semantics(
              label: 'On clicking this it will cancel the Deleting Process',
              child: const Text('No',),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Semantics(
              label: 'On clicking this it will Execute the Deleting Process',
              child: const Text('Yes',),),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        for (var file in _selectedFiles) {
          await file.delete();
        }
        setState(() {
          _pdfFiles.removeWhere((file) => _selectedFiles.contains(file));
          _selectedFiles.clear();
          _isSelectionMode = false;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting files: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'This Opens the Pdf Which are converted and Saved',
          child: Semantics(
            label: 'This Opens the Pdf Which are converted and Saved',
            child: Text(
              _isSelectionMode
                  ? '${_selectedFiles.length} selected'
                  : 'View Saved PDF',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE30606),
        foregroundColor: Colors.white,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  for (var file in _selectedFiles) {
                    _sharePDFFile(file.path);
                  }
                },
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedFiles,
                ),
              ]
            : [],
      ),
      body: ListView.builder(
        itemCount: _pdfFiles.length,
        itemBuilder: (context, index) {
          final file = _pdfFiles[index];
          final isSelected = _selectedFiles.contains(file);
          return GestureDetector(
            onLongPress: () {
              setState(() {
                _isSelectionMode = true;
                _toggleSelection(file);
              });
            },
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(file);
              } else {
                _openPDFFile(file.path);
              }
            },
            child: Semantics(
              label: 'List of All Saved Pdf Select One',
              child: ListTile(
                leading: _isSelectionMode
                    ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(file),
                    )
                    : const Icon(Icons.picture_as_pdf,
                        size: 40, color: Colors.red,),
                title: Text(
                  path.basename(file.path),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
