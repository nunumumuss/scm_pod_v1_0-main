import 'dart:io';

import 'package:fec_corp_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReverseDeliveryScreen extends StatefulWidget {
  const ReverseDeliveryScreen({super.key});

  @override
  State<ReverseDeliveryScreen> createState() => _ReverseDeliveryScreenState();
}

class _ReverseDeliveryScreenState extends State<ReverseDeliveryScreen> {
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  List<dynamic> billData = [];
  XFile? imageFile;
  String billNo = "กรุณาถ่ายรูปบิล";
  List<String> inputArray = [];
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  String? selectedReason; // Variable to hold selected reason

  Future<void> getData(String billNo) async {
    try {
      setState(() {
        isLoading = true;
      });

      String apiUri = '${Constants.apiServer}${Constants.ApiPodCfDelivery}?bill_no=${billNo}';
      // print(apiUri);
      final res = await http.get(Uri.parse(apiUri));
      String resBody = utf8.decode(res.bodyBytes);
      if (res.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(resBody);
        List<Map<String, dynamic>> resData = List<Map<String, dynamic>>.from(jsonData['results']);
        print(res.body);
        print(resData);
        setState(() {
          billData = resData;
        });
      } else if (res.statusCode == 404) {
        setState(() {
          error = "ไม่มีข้อมูล";
        });
      } else {
        setState(() {
          error = "เกิดข้อผิดพลาด ${res.statusCode} โปรดลองใหม่";
        });
      }
    } catch (e) {
      setState(() {
        error = "เกิดข้อผิดพลาด โปรดลองใหม่";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
   
  Future<void> postRvDelivery(String billNo, String reason) async { // Accept a list of shipment IDs
    try {
      setState(() {
        isLoading = true;
      });

      String apiUri = '${Constants.apiServer}${Constants.ApiPodRvDelivery}?bill_no=${billNo}&remark=${reason} '; // Make sure to include the correct base URL
      print(apiUri);
      // Send the POST request
      final res = await http.post(Uri.parse(apiUri));          

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        // Show a dialog with the success message and a button to confirm
        _showConfirmationDialog(responseData['message']);
      } else if (res.statusCode == 404) {         
        _showConfirmationDialog('ไม่มีข้อมูลที่ยืนยัน Loaded');
        
      } else {
        _showConfirmationDialog('เกิดข้อผิดพลาด ${res.statusCode} โปรดลองใหม่');
      }
    } catch (e) {
       _showConfirmationDialog('เกิดข้อผิดพลาด ${e} โปรดลองใหม่');
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
  // Function to show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ข้อผิดพลาด'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }
  void findMatches() {
    billNo = "";
    RegExp regExp = RegExp(r'81\d{8}');
    for (var input in inputArray) {
      Iterable<RegExpMatch> regExpMatches = regExp.allMatches(input);
      for (var match in regExpMatches) {
        setState(() {
          billNo = "${match.group(0)}";          
        });
      }
    }
    if (billNo != ""){
      
      getData(billNo.trim()); 
      print(billData);
    }
    print(billNo);
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
        title: const Text('Reverse Delivery'),
        backgroundColor: Colors.red.shade400,
        // actions: [
        //   IconButton(
        //       onPressed: () async {
        //         if (imageFile != null) {
        //           await uploadImageToServer();
        //         }
        //       },
        //       icon: const Icon(Icons.upload_file_rounded)),
        // ],
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
                label: const Text('ถ่ายภาพเลขที่บิลสินค้า'),
              ),
            ],
          ),
          const Divider(),
          // Display the bill data
          billNo == ""
              ? const Expanded(child: Text("ไม่สามารถอ่าน Bill no ได้"))
              : billData.isNotEmpty 
                ?Expanded(
                  flex: 8,
                  child: Column(
                    children: [ 
                      Text('Bill No: ${billData[0]["billno"]}'),
                      Text('Customer Name: ${billData[0]["cusname"]}'),
                      Text('Load Status: ${billData[0]["load_stat"]}  ${billData[0]["cfdate"]}'), 
                      // Text('Confirmation Date: ${billData[0]["cfdate"]}'),
                      Text(
                          'Delivery Status: ${billData[0]["do_stat"]} ${billData[0]["cddate"]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, // Set font to bold
                            color: Color.fromARGB(255, 228, 14, 7), // Change to your desired color
                          ),
                      ),
                      // Text('Confirmation Date: ${billData[0]["cddate"]}'),
                      Text('Remark: ${billData[0]["rem"]}'),
                      const Text(
                          'สถานะการส่งสินค้าต้องเป็น Delivered เท่านั้น จึงจะยกเลิกได้',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Set font to bold
                            color: Color.fromARGB(255, 228, 14, 7), // Change to your desired color
                          ),
                      ),
                      // Text('สถานะการส่งสินค้าต้องเป็น Delivered เท่านั้น จุึงจะยกเลิกได้'),
                      // Show button if Delivery Status is 'Delivered'
                      const Divider(),
                      if (billData[0]["do_stat"] == 'Delivered')                         
                        Column(
                          children: [
                            DropdownButton<String>(
                            hint: const Text('เลือกเหตุผล'),
                            value: selectedReason,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedReason = newValue;
                              });
                            },
                            items: <String>['กดผิด', 'บิลผิด', 'อื่นๆ']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                            const SizedBox(height: 10), // Add spacing
                            ElevatedButton(
                              onPressed: () {
                                if (selectedReason != null) {
                                  postRvDelivery(billNo,selectedReason!); // Call the API when the button is pressed
                                  print('Reason for cancellation: $selectedReason');
                                } else {
                                  // Show an error message if no reason is selected
                                  _showErrorDialog('กรุณาเลือกเหตุผล');
                                }
                                
                              },
                              // child: const Text('ยกเลิกสถานะการส่งสินค้า'),
                              style: ElevatedButton.styleFrom(
                                // foregroundColor: Colors.white, backgroundColor: Colors.red)), // text color
                                foregroundColor: Colors.white, 
                                backgroundColor:  Colors.red, // text color
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                textStyle: const TextStyle(fontSize: 18),
                              ), child: const Text('ยกเลิกสถานะการส่งสินค้า')
                            ),
                          ],
                        ),                       
                    ],
                  ),
                )
              : Expanded(child: Text('ไม่มีข้อมูล Bill No:$billNo')),
              Expanded(
                flex: 8,
                child: previewImage()
              ),
              // const Divider(),
          // Preview Image
          // Expanded(
          //   flex: 8,
          //   child: previewImage(),
          // ),
        ],
      ),
    );
  }
}
