import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// URL이 "asset:" 접두어로 시작하면 AssetImage로, 아니면 NetworkImage로 로드합니다.
/// mock 모드에서 fixture JSON에 "asset:assets/mock/images/..." 형태의 경로를 넣어 활용합니다.
class StoreImage extends StatelessWidget {
  const StoreImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  }) : super(key: key);

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  static const _prefix = 'asset:';

  bool get _isAsset => url.startsWith(_prefix);
  String get _assetPath => url.substring(_prefix.length);

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (_isAsset) {
      image = Image.asset(
        _assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        errorWidget: (_, __, ___) => _fallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _fallback() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFF7F7F7),
          child: const Icon(Icons.image_not_supported_outlined,
              color: Color(0xFF808080)),
        );
  }
}
