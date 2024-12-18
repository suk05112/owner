import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/inquiry.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/screen/inquiry_detail_page.dart';
import 'package:provider/provider.dart';
import '../../common/Style/CommonSection.dart';

class InquiryPage extends StatefulWidget {
  const InquiryPage({Key? key}) : super(key: key);

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  late Future<InquiryListResponse?> futureInquiryList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    User? user = Provider.of<UserProvider>(context, listen: false).user;

    futureInquiryList = Api().client.getInquiry(user?.owner_id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("문의하기"),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: kToolbarHeight - 8.0,
                        child: getTabBarWidget(),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[InquiryForm(), InquiryList()],
                        ),
                      )
                    ]))));
  }

  Widget getTabBarWidget() {
    return TabBar(
      controller: _tabController,
      // isScrollable: true,
      indicatorColor: Colors.black,
      labelColor: Colors.black,
      indicatorWeight: 5,
      unselectedLabelColor: Colors.grey,
      tabs: [
        Container(
          alignment: Alignment.center,
          // width: (MediaQuery.of(context).size.width) / 2,
          child: Tab(text: '문의하기'),
        ),
        Container(
            alignment: Alignment.center,
            // width: (MediaQuery.of(context).size.width),
            child: Text(
              "나의 문의내역 보기",
            )),
      ],
      // tabs: _tabs,
    );
  }

  Widget InquiryForm() {
    User? user = Provider.of<UserProvider>(context, listen: false).user;

    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: 5,
        ),
        TextFormField(
          // style: TextStyle(fontSize: 15, height: 0.1),
          controller: titleController,

          decoration: InputDecoration(
            // contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            hintText: '제목을 입력해주세요',

            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 2,
                )),
          ),
          onChanged: (text) async {},
          // validator: (_) => (hasRecipe) ? "Exists" : null,
          validator: (value) {
            return null;
          },
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: TextFormField(
            // style: TextStyle(fontSize: 15, height: 0.1),
            expands: true, // TextFormField를 남은 공간에 맞춤
            textAlignVertical: TextAlignVertical.top,
            maxLines: null,
            controller: contentController,
            decoration: InputDecoration(
              // isDense: true,
              hintText: '내용을 입력해주세요',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    width: 2,
                  )),
            ),
            onChanged: (text) async {},
            // validator: (_) => (hasRecipe) ? "Exists" : null,
            validator: (value) {
              return null;
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // 서버 전송 로직 추가
            var inquiry = Inquiry(
                title: titleController.text, content: contentController.text);
            Api().client.subjectInquiry(user?.owner_id ?? 0, inquiry);
          },
          child: Text('문의하기 제출'),
        )
      ],
    ));
  }

  Widget InquiryList() {
    return Scaffold(
      body: FutureBuilder<InquiryListResponse?>(
          future: futureInquiryList, // 비동기적으로 데이터를 가져오는 Future 객체
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 데이터 로딩 중일 때 로딩 인디케이터 표시
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // 에러가 발생한 경우
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              // 데이터가 정상적으로 로드되었을 때
              List<InquiryResponse> inquiryList =
                  snapshot.data!.inquiryResponse;
              return ListView.separated(
                itemCount: inquiryList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        if (inquiryList[index].response != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InquiryDetailPage(
                                      inquiryResponse: inquiryList[index])));
                        }
                      },
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${inquiryList[index].inquiry_created}"),
                              Text(inquiryList[index].title),
                              Text(inquiryList[index].content)
                            ],
                          ),
                          Spacer(),
                          inquiryList[index].status == "pending"
                              ? Text("답변대기")
                              : Text("답변완료"),
                        ],
                      ));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              );
            } else {
              return Text("문의내역 읽어오기 실패");
            }
          }),
    );
  }
}
