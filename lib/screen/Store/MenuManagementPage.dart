import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/widget/common_app_bar.dart';
import 'package:owner/common/widget/store_image.dart';
import 'package:owner/screen/Store/EditMenuPage.dart';
import '../../common/api/response/menu.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key, required this.storeId});
  final int storeId;

  @override
  State<MenuManagementPage> createState() => _MenuManagementPagetate();
}

class _MenuManagementPagetate extends State<MenuManagementPage> {
  List<Menu>? menu;
  String? _error;
  late int _storeId;

  static const Color _borderColor = Color(0xFFE6E6E6);
  static const Color _hintColor = Color(0xFF808080);
  static const Color _primary = Color(0xFFF27213);
  static const Color _textColor = Color(0xFF101010);

  @override
  void initState() {
    super.initState();
    _storeId = widget.storeId;
    _initRetrieval();
  }

  Future<void> _initRetrieval() async {
    try {
      final value = await Api().client.getMenuList(_storeId);
      setState(() {
        menu = value.menuList;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = '메뉴를 불러오지 못했습니다. 다시 시도해 주세요.';
      });
    }
  }

  Future<void> _navigateToEdit({Menu? menu, int? menuId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMenuPage(
          storeId: widget.storeId,
          menu: menu,
          menuId: menuId,
        ),
      ),
    );

    if (result.runtimeType == Menu) {
      setState(() {
        if (menuId != null) {
          final index = this.menu!.indexWhere((m) => m.menu_id == menuId);
          if (index != -1) this.menu![index] = result;
        } else {
          this.menu!.add(result);
        }
      });
    } else if (result.runtimeType == int) {
      setState(() {
        this.menu!.removeWhere((item) => item.menu_id == result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "메뉴 관리"),
      backgroundColor: Colors.white,
      body: _error != null
          ? _buildError()
          : menu == null
              ? const Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(color: _primary),
                  ),
                )
              : menu!.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: _hintColor),
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(fontSize: 14, color: _hintColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() => _error = null);
              _initRetrieval();
            },
            child: const Text('다시 시도', style: TextStyle(color: _primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Column(
      children: [
        Expanded(
          child: Center(
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
                  child: const Icon(Icons.restaurant_menu,
                      size: 36, color: _hintColor),
                ),
                const SizedBox(height: 16),
                const Text(
                  "등록된 메뉴가 없습니다.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: menu!.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: _borderColor),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _navigateToEdit(
                  menu: menu![index],
                  menuId: menu![index].menu_id,
                ),
                child: _buildMenuItem(menu![index]),
              );
            },
          ),
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildMenuItem(Menu item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          StoreImage(
            url: item.menu_image_url ?? '',
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
            errorWidget: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
              ),
              child: const Icon(Icons.image_not_supported_outlined,
                  size: 28, color: _hintColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_formatPrice(item.price)}원",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _hintColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: _hintColor),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
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
            onPressed: () => _navigateToEdit(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "메뉴 추가",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return result.toString();
  }
}
