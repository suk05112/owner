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

  QRCheckScreen({required this.eventKeyword});

  @override
  State<QRCheckScreen> createState() => _QRCheckScreenState();
}

class _QRCheckScreenState extends State<QRCheckScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false; // ✅ 중복 실행 방지
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              formatsAllowed: [BarcodeFormat.qrcode],
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
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((event) async {
      if (_isProcessing) return; // ✅ 중복 실행 방지
      if (event.code == null) return;

      print('QRCheckScreen_onQRViewCreated.listen : result=${event.code}');

      _isProcessing = true; // ✅ 처리 시작
      controller.pauseCamera(); // ✅ QR 스캔 멈추기

      try {
        final scannedCode = event.code!;
        List<String> scannedData = scannedCode.split(',');
        int scannedStoreId = int.tryParse(scannedData[0]) ?? -1;
        String gifticon_id = scannedData[1];

        // 🔹 API 호출하여 store 목록 가져오기
        var response =
            await Api().client.getOwnerStoreList(user?.owner_id ?? -1);

        // 🔹 store_id 리스트 생성
        List<int> storeIdList =
            response.ownerStoreList.map((store) => store.store_id).toList();

        print("list: ${storeIdList}, scannedStoreId: ${scannedStoreId}");
        // 🔹 store_id 검사
        if (storeIdList.contains(scannedStoreId)) {
          print("eventcode: ${event.code}, keyword: ${widget.eventKeyword}");

          final response =
              await Api().client.useGifticon(int.tryParse(gifticon_id) ?? 0);

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
      }
    });
  }
}
