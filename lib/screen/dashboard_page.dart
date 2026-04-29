import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/user.dart' as my_app;
import 'package:owner/common/provier/dashboard_stats_provider.dart';
import 'package:owner/common/provier/mock_dashboard_stats_provider.dart';
import 'package:owner/common/provier/mock_store_provider.dart';
import 'package:owner/common/provier/selected_store_provider.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/flavors.dart';
import 'package:owner/screen/Account/account_management_page.dart';
import 'package:owner/screen/Settlement/settlement_page.dart';
import 'package:owner/screen/Store/cafe_detail_page.dart';
import 'package:owner/screen/Store/cafe_list_page.dart';
import 'package:owner/screen/Store/MenuManagementPage.dart';
import 'package:provider/provider.dart';
import '../../common/api/request/store/store.dart';

class DashboardPage extends StatefulWidget {
  final void Function(BuildContext context)? onNavigateToStoreManagement;

  const DashboardPage({
    Key? key,
    this.onNavigateToStoreManagement,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  my_app.User? user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeProvider =
          Provider.of<SelectedStoreProvider>(context, listen: false);
      if (!storeProvider.isLoaded) {
        _loadDashboardData();
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  /// 매장 목록 로드 후 선택 매장 기준으로 대시보드 통계 API 호출 (앱 최초 실행·당겨서 새로고침 시)
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      user = Provider.of<UserProvider>(context, listen: false).user;
      final storeProvider =
          Provider.of<SelectedStoreProvider>(context, listen: false);

      if (user != null && user!.owner_id > 0) {
        List<Store> stores;
        if (F.isMock) {
          stores = await Provider.of<MockStoreProvider>(context, listen: false)
              .getStoreList(user!.owner_id);
          storeProvider.setStores(stores);
          final statsProvider =
              Provider.of<MockDashboardStatsProvider>(context, listen: false);
          final selectedStoreId = storeProvider.selectedStoreId;
          if (selectedStoreId != null) {
            await statsProvider.refreshStats(selectedStoreId);
          }
        } else {
          final storeListResponse =
              await Api().client.getStoreList(user!.owner_id);
          stores = storeListResponse.store;
          storeProvider.setStores(stores);
          final statsProvider =
              Provider.of<DashboardStatsProvider>(context, listen: false);
          statsProvider.clearIfDifferentStore(storeProvider.selectedStoreId);
          final selectedStoreId = storeProvider.selectedStoreId;
          if (selectedStoreId != null) {
            await statsProvider.refreshStats(selectedStoreId);
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Consumer<SelectedStoreProvider>(
      builder: (context, storeProvider, _) {
        final stores = storeProvider.stores;
        final selectedStore = storeProvider.selectedStore;
        final hasNoStores = storeProvider.hasNoStores;

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
                              // 매장 없을 때 안내
                              if (hasNoStores)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEDE0),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFF27213)
                                              .withOpacity(0.3)),
                                    ),
                                    child: const Text(
                                      "등록된 매장이 없습니다.\n'매장관리' 메뉴에서 매장을 추가해주세요.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF101010),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              // 매장 드롭다운 (Figma 1785-362: 버튼 36h/12radius, 메뉴 12radius/#e6e6e6, 항목 44h, 선택 #f27213 Semi Bold)
                              if (stores.length > 1) ...[
                                _StoreDropdown(
                                  selectedStore: selectedStore!,
                                  stores: stores,
                                  onSelected: (Store s) {
                                    storeProvider.setSelectedStore(s);
                                    final statsProvider =
                                        Provider.of<DashboardStatsProvider>(
                                            context,
                                            listen: false);
                                    statsProvider
                                        .clearIfDifferentStore(s.store_id);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                              // 통계 카드들 (QR 사용 시에만 API로 갱신된 값 표시)
                              if (F.isMock)
                                Consumer<MockDashboardStatsProvider>(
                                  builder: (context, statsProvider, _) =>
                                      _buildStatsSection(
                                    issuedCount: statsProvider.issuedCount,
                                    usedCount: statsProvider.usedCount,
                                    unusedCount: statsProvider.unusedCount,
                                  ),
                                )
                              else
                                Consumer<DashboardStatsProvider>(
                                  builder: (context, statsProvider, _) =>
                                      _buildStatsSection(
                                    issuedCount: statsProvider.issuedCount,
                                    usedCount: statsProvider.usedCount,
                                    unusedCount: statsProvider.unusedCount,
                                  ),
                                ),
                              const SizedBox(height: 24),
                              _buildQuickMenuSection(storeProvider),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection({
    required int issuedCount,
    required int usedCount,
    required int unusedCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "발행된 교환권",
            value: _formatNumber(issuedCount),
            iconColor: const Color(0xFFF27213),
            backgroundColor: const Color(0xFFF27213).withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: "사용된 교환권",
            value: _formatNumber(usedCount),
            iconColor: const Color(0xFFF27213),
            backgroundColor: const Color(0xFFF27213).withOpacity(0.1),
            valueColor: const Color(0xFFF27213),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: "미사용 교환권",
            value: _formatNumber(unusedCount),
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

  void _showNoStoreMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("등록된 매장이 없습니다. 매장을 추가해주세요."),
      ),
    );
  }

  Widget _buildQuickMenuSection(SelectedStoreProvider storeProvider) {
    final hasNoStores = storeProvider.hasNoStores;
    final selectedStoreId = storeProvider.selectedStoreId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "빠른 메뉴",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101010),
          ),
        ),
        const SizedBox(height: 10),
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
                  if (hasNoStores) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CafeList(),
                      ),
                    );
                    return;
                  }
                  if (selectedStoreId == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CafeDetailScreen(storeId: selectedStoreId),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFE6E6E6)),
              _buildQuickMenuButton(
                icon: Icons.restaurant_menu,
                title: "메뉴 관리",
                onTap: () {
                  if (hasNoStores || selectedStoreId == null) {
                    _showNoStoreMessage();
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MenuManagementPage(storeId: selectedStoreId),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFE6E6E6)),
              _buildQuickMenuButton(
                icon: Icons.account_balance_wallet,
                title: "정산",
                onTap: () {
                  if (hasNoStores || selectedStoreId == null) {
                    _showNoStoreMessage();
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SettlementPage(storeId: selectedStoreId),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFE6E6E6)),
              _buildQuickMenuButton(
                icon: Icons.account_balance,
                title: "계좌관리",
                onTap: () {
                  if (hasNoStores || selectedStoreId == null) {
                    _showNoStoreMessage();
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AccountManagementPage(storeId: selectedStoreId),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF101010),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF101010),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF101010),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma 1785-362: 매장선택 드롭다운 — 트리거 36h/12radius, 메뉴 12radius #e6e6e6, 항목 44h, 선택 #f27213 Semi Bold
class _StoreDropdown extends StatelessWidget {
  const _StoreDropdown({
    required this.selectedStore,
    required this.stores,
    required this.onSelected,
  });

  final Store selectedStore;
  final List<Store> stores;
  final void Function(Store) onSelected;

  static const Color _textColor = Color(0xFF101010);
  static const Color _selectedColor = Color(0xFFF27213);
  static const Color _borderColor = Color(0xFFE6E6E6);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, minHeight: 44),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    selectedStore.store_name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                      height: 20 / 14,
                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    size: 20, color: _textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<Store>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _borderColor),
      ),
      color: Colors.white,
      elevation: 0,
      items: stores.map((Store s) {
        final isSelected = s.store_id == selectedStore.store_id;
        return PopupMenuItem<Store>(
          value: s,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  s.store_name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? _selectedColor : _textColor,
                    height: 20 / 14,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, size: 16, color: _selectedColor),
            ],
          ),
        );
      }).toList(),
    ).then((Store? value) {
      if (value != null) onSelected(value);
    });
  }
}
