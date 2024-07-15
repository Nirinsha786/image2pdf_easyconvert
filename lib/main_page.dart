import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image2pdf_easyconvert/created_pdfs_page.dart';
import 'package:image2pdf_easyconvert/custom_icon_button.dart';
import 'package:image2pdf_easyconvert/images_list.dart';
import 'package:image2pdf_easyconvert/selected_images.dart';
import 'package:image_picker/image_picker.dart';

class MainPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const MainPage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ImagesList imagesList = ImagesList();

  void _pickGalleryImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      imagesList.clearImagesList();
      imagesList.imagePaths.addAll(images);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectedImages(
            imagesList: imagesList,
            screenName: "Selected Images",
            textStyle:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  void _captureCameraImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      imagesList.clearImagesList();
      imagesList.imagePaths.add(image);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectedImages(
            imagesList: imagesList,
            screenName: "Selected Image",
            textStyle:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  void _showCreatedPDFs() async {
    final pathToSave = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOCUMENTS,
    );
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatedPDFsPage(directoryPath: pathToSave),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'This is the Main Page Were u can convert Image to Pdf',
          child: const Text(
            "Image to PDF Converter",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xff232946),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffb8c1ec),
        actions: [
          Semantics(
            label: 'Theme Mode',
            child: IconButton(
              icon: Semantics(
                label: 'This will change the theme',
                child: Icon(
                  
                  widget.isDarkTheme ? Icons.nights_stay : Icons.wb_sunny,
                  color: const Color(0xff232946),
                ),
              ),
              onPressed: widget.onToggleTheme,
            ),
          ),
        ],
      ),
  
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              label: 'Pick Image From Phone Gallery',
              child: CustomIconButton(
                icon: Icons.photo,
                color: const Color(0xff232946),
                backgroundColor: const Color(0xffeebbc3),
                onTap: _pickGalleryImages,
                tooltip: "Pick an image from gallery",
                title: "Pick from gallery",
              ),
            ),
            Semantics(
              label: 'Capture Image From Phone Camera',
              child: CustomIconButton(
                icon: Icons.camera,
                color: const Color(0xff232946),
                backgroundColor: const Color(0xffeebbc3),
                onTap: _captureCameraImage,
                tooltip: "Capture an image from camera",
                title: "Capture an image",
              ),
            ),
            Semantics(
              label: 'To View All Saved PDF',
              child: CustomIconButton(
                icon: Icons.storage,
                color: const Color(0xff232946),
                backgroundColor: const Color(0xffeebbc3),
                onTap: _showCreatedPDFs,
                tooltip: "Can see saved PDF's",
                title: "View Saved PDFs",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
    required String buttonText,
    required double fontSize,
  }) {
    return Semantics(
      label: label,
      child: MaterialButton(
        color: const Color(0xFFEE0909),
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const Gap(10),
            Text(
              buttonText,
              style: TextStyle(
                fontSize: fontSize,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(1, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
