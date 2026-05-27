import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/inquiry.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:provider/provider.dart';

class InquiryPage extends StatefulWidget {
  const InquiryPage({Key? key}) : super(key: key);

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  late Future<InquiryListResponse?> _futureInquiryList;
  final Set<int> _expandedItems = {};

  static const Color _borderColor = Color(0xFFE6E6E6);
  static const Color _hintColor = Color(0xFF808080);
  static const Color _primary = Color(0xFFF27213);
  static const Color _textColor = Color(0xFF101010);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchInquiry();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _fetchInquiry() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    setState(() {
      _futureInquiryList = Api().client.getInquiry(user?.owner_id ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "문의하기",
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _buildTabBar(),
        ),
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [_buildInquiryForm(), _buildInquiryList()],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: _primary,
      labelColor: _textColor,
      unselectedLabelColor: _hintColor,
      indicatorWeight: 2,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      tabs: const [
        Tab(text: '문의하기'),
        Tab(text: '나의 문의내역'),
      ],
    );
  }

  Widget _buildInquiryForm() {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '제목',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: '제목을 입력해주세요',
                    hintStyle: const TextStyle(fontSize: 14, color: _hintColor),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '내용',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  maxLines: 10,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: '내용을 입력해주세요',
                    hintStyle: const TextStyle(fontSize: 14, color: _hintColor),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildSubmitButton(user),
      ],
    );
  }

  Widget _buildSubmitButton(User? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final inquiry = Inquiry(
                title: _titleController.text,
                content: _contentController.text,
              );
              Api().client.subjectInquiry(user?.owner_id ?? 0, inquiry);
              CommonDialog.show(
                context: context,
                title: "등록완료",
                content: "문의하기 등록이 완료되었습니다.",
                buttonText: "확인",
                onPressed: () async {
                  _titleController.clear();
                  _contentController.clear();
                  await _fetchInquiry();
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '문의 제출',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInquiryList() {
    return FutureBuilder<InquiryListResponse?>(
      future: _futureInquiryList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: _primary),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: _hintColor),
                const SizedBox(height: 12),
                const Text(
                  '문의 내역을 불러오지 못했습니다.',
                  style: TextStyle(fontSize: 14, color: _hintColor),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _fetchInquiry,
                  child: const Text('다시 시도', style: TextStyle(color: _primary)),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final inquiryList = snapshot.data!.inquiryResponse;
          if (inquiryList.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: _borderColor),
                    ),
                    child: const Icon(Icons.inbox_outlined,
                        size: 36, color: _hintColor),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '문의 내역이 없습니다.',
                    style: TextStyle(fontSize: 14, color: _hintColor),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: _primary,
            onRefresh: _fetchInquiry,
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: inquiryList.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: _borderColor),
              itemBuilder: (context, index) {
                final item = inquiryList[index];
                final isExpanded = _expandedItems.contains(index);
                final isAnswered = item.status != "pending";

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedItems.remove(index);
                      } else {
                        _expandedItems.add(index);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.inquiry_created}',
                                    style: const TextStyle(
                                        fontSize: 12, color: _hintColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: _textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAnswered
                                    ? const Color(0xFFEDF7ED)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isAnswered ? '답변완료' : '답변대기',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isAnswered
                                      ? const Color(0xFF2E7D32)
                                      : _primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 20,
                              color: _hintColor,
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Text(
                              item.response?.isNotEmpty == true
                                  ? item.response!
                                  : '답변 대기 중입니다.',
                              style: const TextStyle(
                                  fontSize: 14, color: _textColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(
          child: Text('문의 내역을 불러오지 못했습니다.',
              style: TextStyle(fontSize: 14, color: _hintColor)),
        );
      },
    );
  }
}
