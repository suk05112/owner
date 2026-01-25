import 'package:flutter/material.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonWidget.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/screen/Register/DocumentGuidePage.dart';
import 'package:owner/common/widget/common_app_bar.dart';

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

    Provider.of<StoreProvider>(context, listen: false)
        .fetchStoreList(user?.owner_id ?? 0);

    print("init state:: StoreProvider.fetchStoreList 호출 후 ");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CommonAppBar(
          title: "매장 관리",
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Consumer<StoreProvider>(
                builder: (context, storeProvider, child) {
                  List<Store> storeList = storeProvider.storeCards ?? [];
                  return RefreshIndicator(
                    onRefresh: () async {
                      try {
                        await Provider.of<StoreProvider>(context, listen: false)
                            .fetchStoreList(user?.owner_id ?? 0);
                      } catch (e) {
                        print("매장 목록 새로고침 실패: $e");
                      }
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // 매장 추가 버튼
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const DocumentGuidePage(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                        vertical: 6,
                                      ),
                                      minimumSize: const Size(0, 48),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      "+ 매장 추가",
                                      style: TextStyle(
                                        color: Color(0xFFF27213),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // 매장 리스트
                                ...storeList.map((store) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: storeCard(store),
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
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
                  builder: (context) => CafeDetailScreen(
                        storeId: store.store_id,
                      )));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE6E6E6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 로고 영역
              SizedBox(
                width: 64,
                height: 64,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: (store.store_logo?.isNotEmpty ?? false)
                      ? Image.network(
                          store.store_logo!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                '☕',
                                style: TextStyle(fontSize: 24),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: DefaultTextStyle(
                            style: const TextStyle(fontSize: 24),
                            child: const Text(
                              '☕',
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // 매장 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            store.store_name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101010),
                              fontFamily: 'Inter',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(store.inspection_status ?? -1),
                      ],
                    ),
                    const SizedBox(height: 4),
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF808080),
                        fontFamily: 'Inter',
                      ),
                      child: Text(
                        store.store_address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 화살표 아이콘
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF101010),
                size: 20,
              ),
            ],
          ),
        ));
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
