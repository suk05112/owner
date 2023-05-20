import 'package:flutter/material.dart';

class InputInfoWidget extends StatefulWidget {
  InputInfoWidget(
      {required this.title, required this.hintText, required this.validator});

  final String title;
  String hintText;
  Function(String?) validator;

  @override
  State<InputInfoWidget> createState() => _InputInfoWidgetState();
}

class _InputInfoWidgetState extends State<InputInfoWidget> {
  TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          Text(widget.title),
          TextFormField(
            controller: inputController,
            keyboardType: TextInputType.text,
            decoration: inputDecoration.copyWith(hintText: widget.hintText),
            validator: (value) {
              return widget.validator(value);
            },
          ),
        ]);
  }

  final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));
}
