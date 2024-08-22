import 'dart:convert';

import 'package:fec_corp_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final authService = AuthService();
  bool isLoading = false;

  Future<void> _login(Map<dynamic, dynamic> formValues) async {
    setState(() {
      isLoading = true;
    });
    var response = await authService.login(
        email: formValues['email'],
        password: formValues['password']);
    if (response.statusCode == 200) {
      //get and update profile from server
      await authService.getProfile();
      setState(() {
        isLoading = false;
      });
      // Get.offNamedUntil('/home', (route) => false);
      Get.offNamedUntil('/home', (route) => false);
    } else {
      setState(() {
        isLoading = false;
      });
      var feedback = json.decode(response.body);
      Get.snackbar('ผลการทำงาน', '${feedback['message']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading == true ? const Center(child: CircularProgressIndicator()) : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color.fromARGB(255, 247, 251, 252), Color.fromARGB(255, 238, 239, 240)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset('assets/images/logo02.png'),
                  const SizedBox(height: 40),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
                      child: Column(
                        children: [
                          FormBuilder(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                FormBuilderTextField(
                                  name: 'email',
                                  initialValue: 'fec-corp1@gmail.com',
                                  maxLines: 1,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    filled: true,
                                    fillColor: Colors.yellow.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(errorText: 'ป้อนข้อมูลอีเมล์ด้วย'),
                                    FormBuilderValidators.email(errorText: 'รูปแบบอีเมล์ไม่ถูกต้อง'),
                                  ]),
                                ),
                                const SizedBox(height: 30),
                                FormBuilderTextField(
                                  name: 'password',
                                  initialValue: '123456',
                                  maxLines: 1,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    filled: true,
                                    fillColor: Colors.yellow.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText: 'ป้อนข้อมูลรหัสผ่านด้วย'),
                                    FormBuilderValidators.minLength(3, errorText: 'รหัสผ่านต้อง 3 ตัวอักษรขึ้นไป'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: MaterialButton(
                                  height: 50,
                                  color: Colors.blue.shade900,
                                  textColor: Colors.white,
                                  child: const Text('Log In', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                      _formKey.currentState!.save();
                                      if (_formKey.currentState!.validate()) {
                                        await _login(_formKey.currentState!.value);
                                      }
                                  },
                                ) 
                              ),
                                                          ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}