import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/user.dart' as my_app;
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/screen/Settlement/settlement_page.dart';
import 'package:owner/screen/Store/cafe_list_page.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToStoreManagement;

  const DashboardPage({
    Key? key,
    this.onNavigateToStoreManagement,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  my_app.User? user;
  int _issuedCount = 0; // 발행된 교환권
  int _usedCount = 0; // 사용된 교환권
  int _unusedCount = 0; // 미사용 교환권
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      user = Provider.of<UserProvider>(context, listen: false).user;

      if (user != null && user!.owner_id > 0) {
        final ownerId = user!.owner_id;

        // 매장 목록 가져오기
        final storeListResponse = await Api().client.getStoreList(ownerId);
        final stores = storeListResponse.store;

        // 모든 매장의 통계 합산
        int totalIssued = 0;
        int totalUsed = 0;
        int totalUnused = 0;

        for (var store in stores) {
          try {
            final statistics = await Api().client.getStoreStatistics(store.store_id);
            totalIssued = totalIssued + statistics.total_issued as int;
            totalUsed = totalUsed + statistics.total_used as int;
            totalUnused = totalUnused + statistics.total_unused as int;
          } catch (e) {
            print("Error loading statistics for store ${store.store_id}: $e");
          }
        }

        setState(() {
          _issuedCount = totalIssued;
          _usedCount = totalUsed;
          _unusedCount = totalUnused;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading dashboard data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CommonAppBar(title: "홈"),
        Expanded(
          child: Container(
            color: Colors.white,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 통계 카드들 (3개)
                          _buildStatsSection(),
                          const SizedBox(height: 24),
                          // 빠른 메뉴
                          _buildQuickMenuSection(),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "발행된 교환권",
            value: _formatNumber(_issuedCount),
            iconColor: const Color(0xFFF27213),
            backgroundColor: const Color(0xFFF27213).withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: "사용된 교환권",
            value: _formatNumber(_usedCount),
            iconColor: const Color(0xFFF27213),
            backgroundColor: const Color(0xFFF27213).withOpacity(0.1),
            valueColor: const Color(0xFFF27213),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: "미사용 교환권",
            value: _formatNumber(_unusedCount),
            iconColor: const Color(0xFF101010),
            backgroundColor: const Color(0xFFF7F7F7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color iconColor,
    required Color backgroundColor,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_giftcard,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF808080),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF101010),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "빠른 메뉴",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101010),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE6E6E6),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildQuickMenuButton(
                icon: Icons.store,
                title: "매장 관리",
                onTap: () {
                  if (widget.onNavigateToStoreManagement != null) {
                    widget.onNavigateToStoreManagement!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CafeList(),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1, color: Color(0xFFE6E6E6)),
              _buildQuickMenuButton(
                icon: Icons.restaurant_menu,
                title: "메뉴 관리",
                onTap: () {
                  // TODO: 메뉴 관리 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CafeList(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFE6E6E6)),
              _buildQuickMenuButton(
                icon: Icons.account_balance_wallet,
                title: "정산",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettlementPage(storeId: -1),
                    ),
                  );
                },
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF101010),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF101010),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFF101010),
            ),
          ],
        ),
      ),
    );
  }
}
