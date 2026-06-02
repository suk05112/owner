import 'package:flutter/material.dart';
import 'package:owner/common/api/API.dart';
import 'package:owner/common/model/user.dart';
import 'package:owner/common/provier/gifticon_provider.dart';
import 'package:owner/common/provier/user_provider.dart';
import 'package:owner/common/widget/CommonDialog.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCheckScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/qr_check_screen';

  final String eventKeyword; // 특정 키워드

  const QRCheckScreen({super.key, required this.eventKeyword});

  @override
  State<QRCheckScreen> createState() => _QRCheckScreenState();
}

class _QRCheckScreenState extends State<QRCheckScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  bool _isLoading = false;
  User? user;

  @override
  void initState() {
    user = Provider.of<UserProvider>(context, listen: false).user;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 스캐너'),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  formatsAllowed: const [BarcodeFormat.qrcode],
                  overlay: QrScannerOverlayShape(
                    borderRadius: 10,
                    borderColor: Colors.blue,
                    borderLength: 30,
                    borderWidth: 5,
                    cutOutSize: screenSize.width / 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            const ColoredBox(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((event) async {
      if (_isProcessing) return; // ✅ 중복 실행 방지
      if (event.code == null) return;

      _isProcessing = true;
      controller.pauseCamera();
      setState(() => _isLoading = true);

      try {
        final scannedCode = event.code!;
        List<String> scannedData = scannedCode.split(',');
        int scannedStoreId = int.tryParse(scannedData[0]) ?? -1;
        String gifticonId = scannedData[1];

        var response =
            await Api().client.getOwnerStoreList(user?.owner_id ?? -1);

        List<int> storeIdList = [];
        for (final store in response.ownerStoreList) {
          storeIdList.add(store.store_id);
        }

        if (storeIdList.contains(scannedStoreId)) {
          final response =
              await Api().client.useGifticon(int.tryParse(gifticonId) ?? 0);

          if (mounted) {
            Navigator.pop(context, response.result);
          }
        } else {
          if (mounted) {
            Navigator.pop(context, -1);
          }
        }
      } catch (e) {
        print("QR 처리 중 오류 발생: $e");
        CommonDialog.show(
            context: context,
            title: "QR코드 스캔 실패",
            content: "처리 중 오류가 발생했습니다. 다시 스캔해주세요.",
            buttonText: "확인",
            onPressed: () {
              Navigator.pop(context);
            });
      } finally {
        _isProcessing = false;
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }
}
