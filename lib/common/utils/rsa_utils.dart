import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';

class RsaUtils {
  static String encryptPassword(String password, String publicKeyPem) {
    final pemStripped = publicKeyPem
        .replaceAll('-----BEGIN PUBLIC KEY-----', '')
        .replaceAll('-----END PUBLIC KEY-----', '')
        .replaceAll('\n', '')
        .trim();
    final keyBytes = base64.decode(pemStripped);

    final asn1Parser = ASN1Parser(Uint8List.fromList(keyBytes));
    final topSeq = asn1Parser.nextObject() as ASN1Sequence;
    final bitString = topSeq.elements![1] as ASN1BitString;
    final pkParser = ASN1Parser(bitString.stringValues as Uint8List);
    final pkSeq = pkParser.nextObject() as ASN1Sequence;

    final modulus = (pkSeq.elements![0] as ASN1Integer).integer!;
    final exponent = (pkSeq.elements![1] as ASN1Integer).integer!;

    final publicKey = RSAPublicKey(modulus, exponent);

    final cipher = OAEPEncoding.withSHA256(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final input = Uint8List.fromList(utf8.encode(password));
    final encrypted = cipher.process(input);

    return base64.encode(encrypted);
  }
}
