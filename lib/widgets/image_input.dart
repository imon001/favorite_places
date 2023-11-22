import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickedImage});
  final void Function(File image) onPickedImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _takenImg;

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _takenImg = File(pickedImage.path);
    });
    widget.onPickedImage(_takenImg!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              onPressed: _takePicture,
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Take Picture",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    if (_takenImg != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _takenImg!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
