import 'dart:io';

import 'package:fec_corp_app/constants/constants.dart';
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
  bool isLoading = false;
  XFile? imageFile;
  String billNo = "";
  String action = "";
  String remark = "";
  String imgUrl = "";
  List<String> inputArray = [];
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  void findMatches() {
    billNo = "";
    RegExp regExp = RegExp(r'81\d{8}');
    for (var input in inputArray) {
      Iterable<RegExpMatch> regExpMatches = regExp.allMatches(input);
      for (var match in regExpMatches) {
        setState(() {
          // billNo = "Bill No. ${match.group(0)}";
          billNo = match.group(0)!;
        });
      }
    }
  }

  takePhoto() async {
    // var photo = await picker.pickImage(source: ImageSource.camera);
    var photo = await picker.pickImage(source: ImageSource.gallery);
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
    try { 
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

          // Extract the image URL from the response
          String imageUrl = responseMsg['data']['imageUrl']; // Adjust the key according to your response structure

          print('Image URL: $imageUrl');

          // Optionally, you can show the URL in the UI or use it elsewhere
          Get.snackbar('ผลการทำงาน', 'Image uploaded successfully: $imageUrl',
              backgroundColor: Colors.green);
          
          // print(responseMsg['data']);
          // Get.snackbar('ผลการทำงาน', '${responseMsg['data']['message']}',
          //     backgroundColor: Colors.green);

          // Update the UI or state as needed    
          setState(() {
            imageFile = null;
            billNo = " "; 
          });
        } else {
          // Handle error response
          print('Error uploading image: ${response.body}');
          Get.snackbar('Error', 'Failed to upload image',
              backgroundColor: Colors.red);
        }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'An error occurred while uploading the image',
          backgroundColor: Colors.yellow);
    }
  }

  Future<void> postCfDelivery(String billNo, String action, String remark, String imgurl) async { // Accept a list of shipment IDs
    try {
      setState(() {
        isLoading = true;
      });

      String apiUri = '${Constants.apiServer}${Constants.ApiPodCfDelivery}?bill_no=$billNo&action=$action&remark=$remark&img_url=$imgurl '; // Make sure to include the correct base URL
      print(apiUri);
      // Send the POST request
      final res = await http.post(Uri.parse(apiUri)); 
      print('res : ${res.statusCode} ');         

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        // Show a dialog with the success message and a button to confirm
        _showConfirmationDialog(responseData['message']);
      } else if (res.statusCode == 404) {         
        _showConfirmationDialog('ไม่มีข้อมูลที่ยืนยัน In-Transit');
        
      } else {
        _showConfirmationDialog('เกิดข้อผิดพลาด ${res.statusCode} โปรดลองใหม่');
      }
    } catch (e) {
       _showConfirmationDialog('เกิดข้อผิดพลาด $e โปรดลองใหม่');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ผลการดำเนินการ'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Get.offAllNamed('/home'); // Clear stack and go to home
              },
              child: const Text('ฺBack to home'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // bool isBillNoValid;
    bool isBillNoValid = billNo.isNotEmpty;//billNo.isNotEmpty;
    action = '';
    remark = '';
    imgUrl = '';

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
          Expanded(child: Text('Bill No. : $billNo')),
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
                      onPressed: isBillNoValid
                      ? () {
                          //  Get.toNamed('/delivered'); 
                          action = "Delivered";
                          remark = " "; 
                          imgUrl = " "; //$url
                          print('Bill : $billNo action : $action remark : $remark imgUrl : $imgUrl');
                          postCfDelivery(billNo,action,remark,imgUrl);                      
                           }
                         : null, // Button is disabled when onPressed is null
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, 
                        backgroundColor: isBillNoValid
                          ? const Color.fromARGB(255, 5, 124, 221) // text color
                          : Colors.grey, // Disabled color
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('ส่งสำเร็จ')
                  ),
                  // Add space between the buttons
                  const SizedBox(width: 20), // Adjust the width as needed
                  ElevatedButton(
                      onPressed: isBillNoValid
                      ? () {
                            Get.toNamed('/fail');                       
                           } 
                         : null,
                      style: ElevatedButton.styleFrom(
                        // foregroundColor: Colors.white, backgroundColor: Colors.red)), // text color
                        foregroundColor: Colors.white, 
                        backgroundColor: isBillNoValid
                          ? Colors.red // text color
                          : Colors.grey, // Disabled color
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
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


