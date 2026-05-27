import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/provier/mock_store_provider.dart';
import 'package:owner/common/provier/store_provider.dart';
import 'package:owner/common/widget/store_image.dart';
import 'package:owner/flavors.dart';
import 'package:owner/screen/Register/register_store_page.dart';
import 'package:provider/provider.dart';

import '../../common/api/request/store/store.dart';
import '../../common/api/response/menu.dart';
import 'MenuManagementPage.dart';

class CafeDetailScreen extends StatefulWidget {
  const CafeDetailScreen({Key? key, required this.storeId}) : super(key: key);
  final int storeId;

  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  late int _storeId;
  Store? store;
  List<Menu> menuList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _storeId = widget.storeId;
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final Store s;
      List<Menu> menus = [];
      if (F.isMock) {
        s = await Provider.of<MockStoreProvider>(context, listen: false)
            .getDetailStore(_storeId);
        try {
          final res = await Api().client.getMenuList(_storeId);
          menus = res.menuList;
        } catch (_) {}
      } else {
        s = await Provider.of<StoreProvider>(context, listen: false)
            .getDetailStore(_storeId);
        try {
          final res = await Api().client.getMenuList(_storeId);
          menus = res.menuList;
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          store = s;
          menuList = menus;
          isLoading = false;
        });
        if (s.store_photo_urls.length > 1) {
          precacheImage(NetworkImage(s.store_photo_urls[1]), context);
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 61,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Color(0xFF101010)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "매장 상세",
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF101010),
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: store == null
                ? null
                : () async {
                    final result = await Navigator.push<Store>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterStorePage(
                          isRegister: false,
                          store: store,
                        ),
                      ),
                    );
                    if (result != null && mounted)
                      setState(() => store = result);
                  },
            child: const Text(
              "수정",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFFF27213),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(color: Color(0xFFF27213)),
              ),
            )
          : store == null
              ? const Center(child: Text("매장 정보를 불러올 수 없습니다."))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStoreImage(),
                      if (store!.inspection_status == 2)
                        _buildInspectionMsg(store!.inspection_msg ?? ""),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStoreInfo(),
                            _buildAddressPhone(),
                            _buildMenuSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;

  Widget _buildStoreImage() {
    final urls = store!.store_photo_urls;
    if (urls.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        color: const Color(0xFFF7F7F7),
        child: const Center(child: Text("☕", style: TextStyle(fontSize: 48))),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 220,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: urls.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              if (i + 1 < urls.length) {
                precacheImage(NetworkImage(urls[i + 1]), context);
              }
              if (i - 1 >= 0) {
                precacheImage(NetworkImage(urls[i - 1]), context);
              }
            },
            itemBuilder: (context, i) => StoreImage(
              url: urls[i],
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorWidget: Container(
                color: const Color(0xFFF7F7F7),
                child: const Center(
                    child: Text("☕", style: TextStyle(fontSize: 48))),
              ),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInspectionMsg(String msg) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "승인 반려",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            msg,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF808080),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            clipBehavior: Clip.hardEdge,
            child: (store!.store_logo != null && store!.store_logo!.isNotEmpty)
                ? StoreImage(
                    url: store!.store_logo!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorWidget: const Center(
                      child: Text("☕", style: TextStyle(fontSize: 30)),
                    ),
                  )
                : const Center(
                    child: Text("☕", style: TextStyle(fontSize: 30)),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        store!.store_name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Color(0xFF101010),
                          height: 1.33,
                        ),
                      ),
                    ),
                    if (store!.inspection_status == 1 || store!.inspection_status == 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: store!.inspection_status == 1
                              ? const Color(0xFFE6F4EA)
                              : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          store!.inspection_status == 1 ? "운영중" : "심사중",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: store!.inspection_status == 1
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF808080),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  store!.store_description.isEmpty
                      ? "매장 소개가 없습니다."
                      : store!.store_description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF808080),
                    height: 1.9,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPhone() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE6E6E6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  store!.store_address,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF101010),
                    height: 1.43,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                store!.store_telephone,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF101010),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE6E6E6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "등록된 메뉴",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF101010),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MenuManagementPage(
                            storeId: _storeId,
                            initialMenus: menuList,
                          ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "메뉴 관리",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFFF27213),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right,
                        size: 18, color: Color(0xFFF27213)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (menuList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "등록된 메뉴가 없습니다.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF808080),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuList.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: Color(0xFFE6E6E6),
              ),
              itemBuilder: (context, index) {
                final menu = menuList[index];
                final priceStr = menu.price
                    .toString()
                    .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (m) => '${m[1]},');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      StoreImage(
                        url: menu.menu_image_url ?? '',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                        errorWidget: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image_not_supported_outlined,
                              size: 20, color: Color(0xFF808080)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menu.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$priceStr원",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFFF27213),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
