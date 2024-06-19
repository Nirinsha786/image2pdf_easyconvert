import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image2pdf_easyconvert/main_page.dart';

void main() {
  runApp(const Image2PDFEasyConvert());
}

class Image2PDFEasyConvert extends StatefulWidget {
  const Image2PDFEasyConvert({super.key});

  @override
  State<Image2PDFEasyConvert> createState() => _Image2PDFEasyConvertState();
}

class _Image2PDFEasyConvertState extends State<Image2PDFEasyConvert> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final PermissionStatus status =
        await Permission.manageExternalStorage.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denied
      // You can show a dialog or message to the user explaining why the permission is necessary
      // and provide an option for the user to grant the permission.
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: MainPage(
        onToggleTheme: _toggleTheme,
        isDarkTheme: _isDarkTheme,
      ),
    );
  }
}
