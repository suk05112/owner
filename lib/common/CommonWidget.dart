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

void showModalDialog(BuildContext context, String message) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Text("dialog");
        // return LoplatDialogCenterConfirm(
        //   children: [
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Expanded(
        //           child : Padding(
        //             padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
        //             child: Center(
        //               child: Text(message, textAlign: TextAlign.center,
        //               style: const TextStyle(
        //                   color: Colors.black,
        //                   fontSize: 18,
        //                   fontFamily: 'AppleSDGothicNeo',
        //                     fontWeight: FontWeight.w700,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        //   confirmLabel: '확인',
        // );
      });
}
