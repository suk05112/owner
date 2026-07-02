import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/ApiClient.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/screen/Setting/notice_detail_page.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final List<NoticeItem> _items = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasError = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNotices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _page < _totalPages) {
      _fetchNotices();
    }
  }

  Future<void> _fetchNotices({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _page = 1;
      _items.clear();
      _hasError = false;
    }
    setState(() => _isLoading = true);
    try {
      final client = await Api().setPublicClient();
      final response = await client.getNoticeList(_page, 20);
      setState(() {
        _items.addAll(response.data);
        _totalPages = response.pagination.totalPages;
        _page++;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = _items.isEmpty;
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '공지사항'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFE7831)));
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('공지사항을 불러오지 못했습니다.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _fetchNotices(refresh: true),
              child: const Text('다시 시도', style: TextStyle(color: Color(0xFFFE7831))),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text('등록된 공지사항이 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFFFE7831),
      onRefresh: () => _fetchNotices(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _items.length + (_isLoading ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: Color(0xFFFE7831))),
            );
          }
          final item = _items[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoticeDetailPage(noticeId: item.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(item.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
