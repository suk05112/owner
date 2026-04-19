import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owner/main.dart';
import 'package:intl/intl.dart';

import 'RegisterStoreCompletePage.dart';

class SettingOpeningDatePage extends StatefulWidget {
  const SettingOpeningDatePage({Key? key}) : super(key: key);

  @override
  State<SettingOpeningDatePage> createState() => _SettingOpeningDatePageState();
}

class _SettingOpeningDatePageState extends State<SettingOpeningDatePage> {
  String radioItem = '';
  String _selectedDate = '';
  bool _isVisible = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final initDate =
        DateFormat('yyyy-MM-dd').parse('2023-01-01' ?? '2000-01-01');
    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // SizedBox(),
            Container(
              height: 40,
              margin: const EdgeInsets.fromLTRB(10, 100, 30, 0),
              // color: Colors.red,
            ),
            Container(
                // decoration:
                // BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                  const Text(
                    "영업 개시일 설정",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                  const SizedBox(height: 20),
                  RadioListTile(
                    groupValue: radioItem,
                    title: const Text('승인 후 즉시'),
                    value: 'Item 1',
                    onChanged: (val) {
                      setState(() {
                        _isVisible = false;
                        // radioItem = val!;
                        print("이거 불림?1 $_isVisible");
                      });
                    },
                  ),
                  RadioListTile(
                    groupValue: radioItem,
                    title: const Text('날짜 선택'),
                    value: 'Item 2',
                    onChanged: (val) {
                      const Text('adfds');
                      // _selectDate(context);
                      setState(() {
                        _isVisible = true;
                        // radioItem = val!;
                        print("이거 불림?1 $_isVisible");
                      });
                    },
                  ),
                  _isVisible
                      ? SizedBox(
                          height: 150,
                          child: CupertinoDatePicker(
                            minimumYear: 1900,
                            maximumYear: DateTime.now().year,
                            initialDateTime: initDate,
                            maximumDate: DateTime.now(),
                            onDateTimeChanged: (val) {
                              setState(
                                () {
                                  // dateSelected = val;
                                },
                              );
                            },
                            mode: CupertinoDatePickerMode.date,
                          ),
                        )
                      : const SizedBox(height: 150)
                ])),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(children: [
                SizedBox(
                  width: double.infinity, // <-- Your width
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 151, 125, 253),
                      // minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterStoreCompletePage()));
                    },
                    child: const Text('확인'),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = (DateFormat.yMMMd()).format(selected);
      });
    }
  }
}
