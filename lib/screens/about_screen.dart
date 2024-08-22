import 'package:fec_corp_app/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  Map<String, dynamic> data = {};
  var products = [
    'หม้อหุงข้าว',
    'พัดลม',
    'กระติกน้ำร้อน',
    'เตาอบ',
    'กาด้มน้ำ',
    'เครื่องปั่น',
    'เครื่องทำแซนด์วิช',
    'หม้อทอดไรน้ำมัน',
    'เครื่องทำน้ำอุ่น',
    'เตารีด'
    ];

  @override
  void initState() {
    data = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(),
      key: _key,
      appBar: AppBar(
        leading: IconButton.outlined(
            onPressed: () {
              _key.currentState!.openDrawer();
            },
            icon: const Icon(Icons.menu)),
        // title: Text('เกี่ยวกับ ${data['companyName']}'),
        title: const Text('เกี่ยวกับเรา'),
        backgroundColor: const Color.fromARGB(255, 225, 55, 55),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/b01.jpg'),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('บริษัทกรุงไทยการไฟฟ้า จำกัด',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(),
                  const Text(
                      'ตัวแทนจัดจำหน่ายเครื่องใช้ไฟฟ้าแบรนด์ “ชาร์ป (SHARP)” ก่อตั้งขึ้น เมื่อวันที่ 13 พฤศจิกายน พ.ศ. 2515 โดยมีบริษัท เฟดเดอรัล อีเลคตริค จำกัด เป็นบริษัทในเครือสำหรับการผลิตเครื่องใช้ไฟฟ้าเพื่อจำหน่ายในประเทศไทย โดยอยู่ภายใต้การควบคุมคุณภาพ มาตรฐาน การสนับสนุนทางด้านวิศวกรรมการผลิตและเทคโนโลยีต่าง ๆ จาก บริษัท ชาร์ป คอร์ปอเรชั่น ประเทศญี่ปุ่น นอกจากนี้ยังมีการผลิตเครื่องใช้ ไฟฟ้า ภายใต้เครื่องหมายการค้าชั้นนำอีกหลายประเภทเพื่อส่งไปจำหน่ายยังทวีปต่าง ๆ ',
                      textAlign: TextAlign.start),                   
                  const Divider(),
                  const Row(
                    children: [
                      Expanded(
                          child: Icon(Icons.contact_mail, color: Colors.red)),
                      Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: admin@thaicity.co.th',
                                  style: TextStyle(color: Colors.red)),
                              Text(
                                  'คล้งสินค้า บางพลี: 64/1 หมู่ 4 ถนนกิ่งแก้ว ตำบลราชาเทวะ อำเภอบางพลี จังหวัดสมุทรปราการ 10540  \nคลังสินค้า สุวินทวงศ์:97 หมู่ที่ 20 ตำบลศาลาแดง อำเภอบางน้ำเปรี้ยว จ.ฉะเชิงเทรา 24000  ')
                            ],
                          )),
                    ],
                  ),
                  const Divider(),
                  const Text('สินค้าของเรา',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 5.0,
                    children: [
                      for (var item in products)
                        Chip(
                          label: Text(item),
                          backgroundColor: Colors.grey.shade100,
                          avatar: const Icon(Icons.star),
                        )
                    ],
                  ),
                  const Divider(),
                  const Text('คลังสินค้าของเรา',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/wh_sw.png'),
                            radius: 40,
                          ),
                          const SizedBox(width: 8), // Space between avatar and text
                          const Text(
                            'สุวินทวงศ์', // Replace with your desired text
                            style: TextStyle(fontSize: 16), // Customize text style as needed
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/wh_sw.png'),
                            radius: 40,
                          ),
                          const SizedBox(width: 8), // Space between avatar and text
                          const Text(
                            'บางพลี', // Replace with your desired text
                            style: TextStyle(fontSize: 16), // Customize text style as needed
                          ),
                        ],
                      ),
                    ],
                  )                   
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
