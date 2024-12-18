import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/inquiry.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:provider/provider.dart';
import '../../common/Style/CommonSection.dart';

class InquiryDetailPage extends StatefulWidget {
  const InquiryDetailPage({Key? key, required this.inquiryResponse})
      : super(key: key);
  final InquiryResponse inquiryResponse;
  @override
  State<InquiryDetailPage> createState() => _InquiryDetailPageState();
}

class _InquiryDetailPageState extends State<InquiryDetailPage>
    with SingleTickerProviderStateMixin {
  late InquiryResponse _inquiryResponse;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _inquiryResponse = widget.inquiryResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("나의 문의내역"),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_inquiryResponse.title),
                      Text(_inquiryResponse.content),
                      Text(_inquiryResponse.response ?? "")
                    ]))));
  }
}
