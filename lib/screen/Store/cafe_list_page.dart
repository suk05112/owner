import 'package:flutter/material.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonWidget.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/screen/Register/DocumentGuidePage.dart';

import '../../common/api/request/store/store.dart';
import '../../common/provier/store_provider.dart';
import 'cafe_detail_page.dart';
import 'package:owner/common/model/user.dart' as my_app;

import 'package:provider/provider.dart';

void main() {
  runApp(const CafeList());
}

class CafeList extends StatefulWidget {
  const CafeList({Key? key}) : super(key: key);

  @override
  State<CafeList> createState() => _CafeListState();
}

class _CafeListState extends State<CafeList> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<Store>? storeList;
  my_app.User? user;
  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    // fetchStoreList가 notifyListeners()를 호출하므로 빌드가 끝난 뒤에 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoreProvider>(context, listen: false)
          .fetchStoreList(user?.owner_id ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF101010)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "매장 관리",
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF000000),
          ),
        ),
        titleSpacing: 20,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentGuidePage(),
                  ),
                );
              },
              child: const Text(
                "+",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                  color: Color(0xFFF27213),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          color: Colors.white,
          child: Consumer<StoreProvider>(
                builder: (context, storeProvider, child) {
                  final isLoading = storeProvider.isLoadingStoreList;
                  List<Store> storeList = storeProvider.storeCards ?? [];
                  return Column(
                    children: [
                      if (isLoading)
                        const LinearProgressIndicator(
                          backgroundColor: Color(0xFFE6E6E6),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF27213)),
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                      try {
                        await Provider.of<StoreProvider>(context, listen: false)
                            .fetchStoreList(user?.owner_id ?? 0);
                      } catch (e) {
                        print("매장 목록 새로고침 실패: $e");
                      }
                    },
                    child: isLoading && storeList.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF27213),
                            ),
                          )
                        : !isLoading && storeList.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    "등록된 매장이 없습니다.\n매장을 추가해주세요.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          ...storeList.map((store) => Padding(
                                                padding: const EdgeInsets.only(bottom: 15),
                                                child: storeCard(store),
                                              )),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ),
    );
  }

  void getStoreList(BuildContext context) async {
    final currentContext = scaffoldKey.currentContext;
    my_app.User? user = Provider.of<UserProvider>(context, listen: false).user;

    try {
      final response = await Api().client.getStoreList(user?.owner_id ?? 0);
      currentContext?.read<StoreProvider>().setStoreCard(response.store);
      print(response);
    } catch (error) {
      currentContext?.read<StoreProvider>().setStoreCard(null);
      // _isFirstSlotLoaded = true;
      showModalDialog(context,
          "서버에서 오류가 발생하였습니다.\n앱 종료 후 다시 접속해 주세요.\n문제가 지속될 경우, 고객센터(service@.com)로 문의부탁드립니다.");
      rethrow;
    }
  }

  Widget storeCard(Store? store) {
    if (store == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CafeDetailScreen(storeId: store.store_id),
          ),
        );
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
        ),
        child: Row(
          children: [
            // 로고 (Figma: 60x60, radius 8, bg #e6e6e6)
            SizedBox(
              width: 60,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: (store.store_logo?.isNotEmpty ?? false)
                    ? Image.network(
                        store.store_logo!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('☕', style: TextStyle(fontSize: 22)),
                        ),
                      )
                    : const Center(
                        child: Text('☕', style: TextStyle(fontSize: 22)),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // 매장 정보 (Figma: 이름 16 Semi Bold #000, 주소 13 Regular #808080)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.store_name,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(store.inspection_status ?? -1),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    store.store_address,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF808080),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '›',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Color(0xFFB3B3B3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    if (status == 1) {
      // 승인완료
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDE0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "승인완료",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFF27213),
            fontFamily: 'Inter',
          ),
        ),
      );
    } else if (status == 0) {
      // 승인대기
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "승인대기",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF808080),
            fontFamily: 'Inter',
          ),
        ),
      );
    } else if (status == 2) {
      // 심사 반려
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "심사 반려",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF808080),
            fontFamily: 'Inter',
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "알수 없음",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF808080),
            fontFamily: 'Inter',
          ),
        ),
      );
    }
  }
}
