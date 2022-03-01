import 'dart:io';

import 'package:camera_upload/api/firebase_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UploadTask? task;
  File? file;
  File? image;
  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No file selected';
    final imageName = image != null ? basename(image!.path) : 'No image selected';
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Camera Upload'),
            ElevatedButton(
              onPressed: selectFile,
              child: Text('Select File'),
            ),
            Text(fileName),
            ElevatedButton(
              onPressed: uploadFile,
              child: Text('Upload File'),
            ),
            //buildUploadStatus(task!),
            image != null
                ? Image.file(
                    image!,
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  )
                : const FlutterLogo(
                    size: 160,
                  ),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.gallery),
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.camera),
              child: Text('Camera'),
            ),
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload Image'),
            ),
            task != null ? buildUploadStatus(task!) : Container(),

          ],
        ),
      ),
    );
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to pick image : $e');
      }
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() {
      file = File(path);
    });
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});
    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link : $urlDownload');
  }

  Future uploadImage() async{
    if (image == null) return;

    final imageName = basename(image!.path);
    final destination = 'images/$imageName';

    task = FirebaseApi.uploadFile(destination, image!);
    setState(() {});
    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link : $urlDownload');

  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(0);
            return Text(
              '$percentage %',
              style: const TextStyle(fontSize: 20),
            );
          } else {
            return Container();
          }
        },
      );
}
