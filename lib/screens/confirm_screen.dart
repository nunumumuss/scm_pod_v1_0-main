import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final ImagePicker picker = ImagePicker();
  XFile? imageFile;
  String billNo = "init";
  List<String> inputArray = [];
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  void findMatches() {
    billNo = "";
    RegExp regExp = RegExp(r'81\d{8}');
    for (var input in inputArray) {
      Iterable<RegExpMatch> regExpMatches = regExp.allMatches(input);
      for (var match in regExpMatches) {
        setState(() {
          billNo = "Bill No. ${match.group(0)}";
        });
      }
    }
  }

  takePhoto() async {
    var photo = await picker.pickImage(source: ImageSource.camera);
    // var photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      // read text from image
      final inputImage = InputImage.fromFilePath(photo.path);
      final textResult = await textRecognizer.processImage(inputImage);

      inputArray.clear();
      // print('textResult: ${textResult.text}');
      for (TextBlock block in textResult.blocks) {
        inputArray.add(block.text);
      }

      findMatches();

      setState(() {
        imageFile = photo;
      });
    }
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  Widget previewImage() {
    if (imageFile != null) {
      return Center(
        child: Image.file(
          File(imageFile!.path),
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
        ),
      );
    } else {
      return const Center(
        child: Text('แสดงตัวอย่างภาพที่นี่'),
      );
    }
  }

  Future<void> uploadImageToServer() async {
    // convert jpg to base64
    final bytesImage = await File(imageFile!.path).readAsBytes();
    var base64Image = base64Encode(bytesImage);

    // upload base64image to server
    var url = Uri.parse('https://api.codingthailand.com/api/upload');
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'picture': 'data:image/jpeg;base64,$base64Image'}));
    if (response.statusCode == 200) {
      var responseMsg = json.decode(response.body);
      print(responseMsg['data']);
      Get.snackbar('ผลการทำงาน', '${responseMsg['data']['message']}',
          backgroundColor: Colors.green);
      setState(() {
        imageFile = null;
        billNo = "init";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Delivery'),
        backgroundColor: Colors.red.shade400,
        actions: [
          IconButton(
              onPressed: () async {
                if (imageFile != null) {
                  await uploadImageToServer();
                }
              },
              icon: const Icon(Icons.upload_file_rounded)),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  onPressed: () async {
                    await takePhoto();
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('ถ่ายภาพเลขที่บิลสินค้า'))
            ],
          ),
          Expanded(child: Text(billNo)),
          billNo == ""
              ? const Expanded(child: Text("ไม่สามารถอ่าน Bill no ได้"))
              : const Text(''),
          const Divider(),
          Expanded(
            flex: 8,
            child: previewImage()
          ),
          const Divider(),
          Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/fail');                       
                      }, 
                      child: const Text('ส่งไม่สำเร็จ')
                  ),
                ],
                ),
          )
        ],
      ),
    );
  }
}
