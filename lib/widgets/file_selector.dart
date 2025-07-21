import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';

class ImageFileSelector extends StatefulWidget {
  final Function(File?) onImageSelected;

  const ImageFileSelector({super.key, required this.onImageSelected});

  @override
  State<ImageFileSelector> createState() => _ImageFileSelectorState();
}

class _ImageFileSelectorState extends State<ImageFileSelector> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        widget.onImageSelected(_image);
      } else {
        print('No image selected.');
        widget.onImageSelected(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.formFillColor,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            const Icon(Icons.image_outlined, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: AppText.body(
                _image == null
                    ? 'IMG2015--462-36'
                    : _image!.path.split('/').last,
                color: _image == null ? Colors.grey : Colors.black,
              ),
            ),
            const Icon(Icons.upload_file, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
