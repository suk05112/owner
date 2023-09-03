import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/main.dart';
import 'package:intl/intl.dart';

import '../../common/Style/TextAsset.dart';
import '../../common/model/OperatingHours.dart';
import 'RegisterStoreCompletePage.dart';
import 'package:flutter/cupertino.dart';

class OperatingHoursSettingPage extends StatefulWidget {
  const OperatingHoursSettingPage({Key? key}) : super(key: key);

  @override
  State<OperatingHoursSettingPage> createState() =>
      _OperatingHoursSettingPageState();
}

// const colors = [
//   Color(0xFF64c636),
//   Color(0xFFf2c32c),
//   Color(0xFF00a9ce),
// ];

class _OperatingHoursSettingPageState extends State<OperatingHoursSettingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _selectedColor = Color(0xff9D9BFF);
  final _unselectedColor = Color(0xffCAC9FF);
  final _tabs = [
    Tab(text: '매일 같아요'),
    Tab(text: '평일/주말 달라요'),
    Tab(text: '매일 달라요'),
  ];

  final _iconTabs = [
    Tab(icon: Icon(Icons.home)),
    Tab(icon: Icon(Icons.search)),
    Tab(icon: Icon(Icons.settings)),
  ];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("운영시간 관리하기"),
          backgroundColor: ColorAssset.color1,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Container(
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 21),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "운영시간",
                            style: TextAssset.header3,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: kToolbarHeight - 8.0,
                            decoration: BoxDecoration(
                              color: Color(0xffCAC9FF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: getTabBarWidget(),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(2, 20, 2, 20),
                            height: 300,
                            width: double.infinity,
                            child: TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                getEverydayWidget(),
                                getWeekdayWeekendWidget(),
                                getDailyWidget()
                              ],
                            ),
                          ),
                          Text(
                            "정기 휴무일",
                            style: TextAssset.header3,
                          ),
                          Text(
                            "임시 휴무일",
                            style: TextAssset.header3,
                          ),
                          Text(
                            "공휴일 휴무",
                            style: TextAssset.header3,
                          ),
                          Text(
                            "추가안내",
                            style: TextAssset.header3,
                          ),
                        ])))));
  }

  Widget getTabBarWidget() {
    return TabBar(
      controller: _tabController,
      // isScrollable: true,
      indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0), color: _selectedColor),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      tabs: [
        Container(
          width: (MediaQuery.of(context).size.width - 80) / 4,
          child: Tab(text: '매일 같아요'),
        ),
        Container(
            width: (MediaQuery.of(context).size.width - 60) / 3,
            child: Text(
              "평일/주말 달라요",
              style: TextAssset.body2,
            )
            // Tab(text: '평일/주말 달라요'),
            ),
        Container(
          width: (MediaQuery.of(context).size.width - 80) / 4,
          child: Tab(text: '매일 달라요'),
        ),
      ],
      // tabs: _tabs,
    );
  }

  //매일 같아요
  Widget getEverydayWidget() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("영업시간"),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
              onTap: () {
                print("touch 됨");
                showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      // <-- SEE HERE
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.0),
                      ),
                    ),
                    builder: (context) {
                      return getSettingTimeWidget();
                    });
              },
              child: Container(
                width: 270,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xffE4E7EE), width: 1)),
                child: Center(
                    child: Text(
                  "09:00    ~    20:00",
                  textAlign: TextAlign.center,
                )),
              ))
        ],
      )
    ]);
  }

  Widget getSettingTimeWidget() {
    _myFunction() => print("Being pressed!");

    return SizedBox(
        height: 335,
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(
                onPressed: () {
                  print("touch");
                },
                child: Text("취소")),
            TextButton(
                onPressed: () {
                  print("touch");
                },
                child: Text("확인"))
          ]),
          Container(
              height: MediaQuery.of(context).size.height / 4,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                    1969,
                    1,
                    1,
                    TimeOfDay(hour: 15, minute: 0).hour,
                    TimeOfDay(hour: 15, minute: 0).minute),
                onDateTimeChanged: (DateTime newDateTime) {
                  var newTod = TimeOfDay.fromDateTime(newDateTime);
                  _myFunction;
                },
                use24hFormat: false,
                minuteInterval: 1,
              ))
        ]));
  }

  //평일 주말 달라요
  Widget getWeekdayWeekendWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("평일"),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("영업시간"),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
              onTap: () {
                print("touch 됨");
              },
              child: Container(
                width: 270,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xffE4E7EE), width: 1)),
                child: Center(
                    child: Text(
                  "09:00    ~    20:00",
                  textAlign: TextAlign.center,
                )),
              ))
        ],
      ),
      Text("주말"),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("영업시간"),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
              onTap: () {
                print("touch 됨");
              },
              child: Container(
                width: 270,
                height: 40,
                decoration: OperatingHoursBox.boxSyle,
                child: Center(
                    child: Text(
                  "09:00    ~    20:00",
                  textAlign: TextAlign.center,
                )),
              ))
        ],
      )
    ]);
  }

  //매일 달라요
  Widget getDailyWidget() {
    return Column(children: [
      //월요일
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("월요일"),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
              onTap: () {
                print("touch 됨");
              },
              child: Container(
                width: 270,
                height: 40,
                decoration: OperatingHoursBox.boxSyle,
                child: Center(
                    child: Text(
                  "09:00    ~    20:00",
                  textAlign: TextAlign.center,
                )),
              ))
        ],
      ),
      SizedBox(
        height: 18,
      ),
      //화요일
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("화요일"),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
              onTap: () {
                print("touch 됨");
              },
              child: Container(
                width: 270,
                height: 40,
                decoration: OperatingHoursBox.boxSyle,
                child: Center(
                    child: Text(
                  "09:00    ~    20:00",
                  textAlign: TextAlign.center,
                )),
              ))
        ],
      )
    ]);
  }
}

class OperatingHoursBox {
  static var boxSyle = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: Color(0xffE4E7EE), width: 1));
}

class PreferencesSelectTime extends StatefulWidget {
  String _title;
  TimeOfDay _timeOfDay;
  Function _updateTimeFunction;

  PreferencesSelectTime(this._title, this._timeOfDay, this._updateTimeFunction);

  @override
  PreferencesSelectTimeState createState() =>
      PreferencesSelectTimeState(_title, _timeOfDay, _updateTimeFunction);
}

class PreferencesSelectTimeState extends State<PreferencesSelectTime> {
  String _title;
  TimeOfDay _timeOfDay;
  Function _updateTimeFunction;
  PreferencesSelectTimeState(
      this._title, this._timeOfDay, this._updateTimeFunction);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height / 4,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime:
                  DateTime(1969, 1, 1, _timeOfDay.hour, _timeOfDay.minute),
              onDateTimeChanged: (DateTime newDateTime) {
                var newTod = TimeOfDay.fromDateTime(newDateTime);
                _updateTimeFunction(newTod);
              },
              use24hFormat: false,
              minuteInterval: 1,
            )));
  }
}
