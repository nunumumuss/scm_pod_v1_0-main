import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FailScreen extends StatefulWidget {
  const FailScreen({super.key});

  @override
  State<FailScreen> createState() => _FailScreenState();
}

class _FailScreenState extends State<FailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แจ้งเหตุผล')),
      body: Column(
        children: [
          FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FormBuilderDropdown<String>(
                    name: 'dropdown',
                    decoration: const InputDecoration(
                      labelText: 'เลือกเหตุผล...',
                    ),
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required()]),
                    items: const [
                      DropdownMenuItem(
                        value: 'รถเสีย',
                        child: Text('รถเสีย'),
                      ),
                      DropdownMenuItem(
                        value: 'ร้านค้าปิด',
                        child: Text('ร้านค้าปิด'),
                      ),
                      DropdownMenuItem(
                        value: 'เลื่อนออกไป',
                        child: Text('เลื่อนออกไป'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        print(_formKey.currentState?.value);
                      } else {
                        print("Validation failed");
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}