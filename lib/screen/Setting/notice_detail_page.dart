import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/api/ApiClient.dart';
import 'package:owner/common/widget/common_app_bar.dart';

class NoticeDetailPage extends StatefulWidget {
  final int noticeId;

  const NoticeDetailPage({super.key, required this.noticeId});

  @override
  State<NoticeDetailPage> createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends State<NoticeDetailPage> {
  NoticeDetail? _detail;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final client = await Api().setPublicClient();
      final response = await client.getNoticeDetail(widget.noticeId);
      setState(() {
        _detail = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
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
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFE7831)));
    }
    if (_hasError || _detail == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('공지사항을 불러오지 못했습니다.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _fetchDetail,
              child: const Text('다시 시도', style: TextStyle(color: Color(0xFFFE7831))),
            ),
          ],
        ),
      );
    }
    final detail = _detail!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(detail.createdAt),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            detail.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            detail.content,
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.7),
          ),
        ],
      ),
    );
  }
}
