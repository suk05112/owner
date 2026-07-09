import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// 업로드 직전 이미지를 리사이즈/압축한다.
///
/// - EXIF 회전을 픽셀에 반영 (copyResize 내부에서 bakeOrientation 처리)
/// - 긴 변이 [maxSide]를 넘으면 비율 유지 축소, 넘지 않으면 원본 크기 유지
/// - JPEG [quality]로 인코딩
///
/// decode/resize/encode는 무거우므로 [compute]로 백그라운드 isolate에서 실행해
/// UI 스레드 블로킹을 막는다. 처리에 실패하면 원본 파일을 그대로 반환한다.
Future<File> prepareUploadImage(
  String srcPath, {
  int maxSide = 1280,
  int quality = 85,
}) async {
  final srcFile = File(srcPath);
  try {
    final bytes = await srcFile.readAsBytes();
    final jpgBytes = await compute(
      _resizeEncode,
      _ResizeParams(bytes, maxSide, quality),
    );
    if (jpgBytes == null) return srcFile;

    final dir = await getTemporaryDirectory();
    final outPath =
        '${dir.path}/upload_${DateTime.now().microsecondsSinceEpoch}.jpg';
    return File(outPath).writeAsBytes(jpgBytes);
  } catch (e) {
    // 처리 실패 시 원본 업로드로 폴백
    print('prepareUploadImage 실패, 원본 사용: $e');
    return srcFile;
  }
}

class _ResizeParams {
  final Uint8List bytes;
  final int maxSide;
  final int quality;

  _ResizeParams(this.bytes, this.maxSide, this.quality);
}

/// isolate 진입점. 최상위 함수여야 compute로 넘길 수 있다.
Uint8List? _resizeEncode(_ResizeParams p) {
  final decoded = img.decodeImage(p.bytes);
  if (decoded == null) return null;

  final longer = decoded.width >= decoded.height ? decoded.width : decoded.height;

  // copyResize는 EXIF 방향이 있으면 내부에서 bakeOrientation을 수행한다.
  // 긴 변이 maxSide 이하여도 방향 반영을 위해 원본 크기로 한 번 통과시킨다.
  final img.Image resized = longer > p.maxSide
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? p.maxSide : null,
          height: decoded.height > decoded.width ? p.maxSide : null,
          maintainAspect: true,
          interpolation: img.Interpolation.average,
        )
      : img.bakeOrientation(decoded);

  return img.encodeJpg(resized, quality: p.quality);
}
