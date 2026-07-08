import 'package:flutter/material.dart';
import 'package:owner/common/Style/ColorAsset.dart';
import 'package:owner/common/api/ApiClient.dart';

class PopupCarouselDialog extends StatefulWidget {
  final List<PopupItem> popups;
  final void Function(PopupItem popup) onTapLink;
  final VoidCallback onHideToday;

  const PopupCarouselDialog({
    Key? key,
    required this.popups,
    required this.onTapLink,
    required this.onHideToday,
  }) : super(key: key);

  @override
  State<PopupCarouselDialog> createState() => _PopupCarouselDialogState();
}

class _PopupCarouselDialogState extends State<PopupCarouselDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.popups.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final popup = widget.popups[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onTapLink(popup);
                    },
                    child: Image.network(
                      popup.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorAssset.mainColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (widget.popups.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.popups.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? ColorAssset.mainColor
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                ),
              ),
            ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    widget.onHideToday();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    '오늘 하루 안보기',
                    style: TextStyle(fontSize: 14, color: Color(0xff6A6A6A)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
                child: VerticalDivider(width: 1),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    '닫기',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
