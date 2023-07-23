import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owner/main.dart';
import 'package:intl/intl.dart';

import 'RegisterStoreCompletePage.dart';

class OperatingHoursSettingPage extends StatefulWidget {
  const OperatingHoursSettingPage({Key? key}) : super(key: key);

  @override
  State<OperatingHoursSettingPage> createState() =>
      _OperatingHoursSettingPageState();
}

class _OperatingHoursSettingPageState extends State<OperatingHoursSettingPage> {
  String radioItem = '';
  String _selectedDate = '';
  bool _isVisible = false;
  bool _isSameEveryDay = false;
  bool _isWeekdDay = false;
  bool _isDiffEveryDay = false;
  DateTime? _chosenDateTime;
  void _showDatePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 250,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime.now(),
                        onDateTimeChanged: (val) {
                          setState(() {
                            _chosenDateTime = val;
                          });
                        }),
                  ),

                  // Close the modal
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  )
                ],
              ),
            ));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final initDate =
        DateFormat('yyyy-MM-dd').parse('2023-01-01' ?? '2000-01-01');
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
            SizedBox(height: 20),
            RadioListTile(
              groupValue: radioItem,
              title: Text('매일 같아요'),
              value: 'Item 1',
              onChanged: (val) {
                _showDatePicker(context);
                setState(() {
                  // radioItem = val!;
                  _isSameEveryDay = true;
                  _isWeekdDay = false;
                  _isDiffEveryDay = false;
                  // print("이거 불림?1 ${_isVisible}");
                });
                // _selectTime(context);
              },
            ),
            Text("시작시간"),
            Text("종료시간"),
            Visibility(
              visible: _isSameEveryDay,
              child: SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  // initialDateTime: initDate,
                  onDateTimeChanged: (DateTime newDateTime) {
                    // var newTod = TimeOfDay.fromDateTime(newDateTime);
                    // _updateTimeFunction(newTod);
                  },
                ),
              ),
            ),
            RadioListTile(
              groupValue: radioItem,
              title: Text('평일/주말 달라요'),
              value: 'Item 2',
              onChanged: (val) {
                Text('adfds');
                // _selectDate(context);
                setState(() {
                  // radioItem = val!;
                  _isSameEveryDay = false;
                  _isWeekdDay = true;
                  _isDiffEveryDay = false;
                });
              },
            ),
            RadioListTile(
              groupValue: radioItem,
              title: Text('매일 달라요'),
              value: 'Item 3',
              onChanged: (val) {
                Text('adfds');
                // _selectDate(context);
                setState(() {
                  // radioItem = val!;
                  _isSameEveryDay = false;
                  _isWeekdDay = false;
                  _isDiffEveryDay = true;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 151, 125, 253),
                // minimumSize: const Size.fromHeight(50), // NEW
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ])),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      // 선택된 시간(pickedTime)을 사용하여 원하는 작업 수행
      print('선택된 시간: ${pickedTime.hour}:${pickedTime.minute}');
    }
  }
}
