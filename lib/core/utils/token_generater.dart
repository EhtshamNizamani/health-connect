import 'dart:convert';
import 'package:crypto/crypto.dart';

// This is a Dart implementation of ZegoCloud's test token generation logic.
class ZegoTokenGenerator {
  static String generateToken({
    required int appId,
    required String serverSecret,
    required String userId,
    int effectiveTimeInSeconds = 3600, // Token is valid for 1 hour
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiredTime = now + effectiveTimeInSeconds;

    // 1. Create the payload object
    final payloadMap = {
      'app_id': appId,
      'user_id': userId,
      'nonce': DateTime.now().millisecondsSinceEpoch,
      'ctime': now,
      'expire': expiredTime,
    };

    // 2. Convert payload to JSON and then Base64Url
    final payloadJson = jsonEncode(payloadMap);
    final payloadBase64 = base64Url.encode(utf8.encode(payloadJson));

    // 3. Create the signature
    final hmacSha256 = Hmac(sha256, utf8.encode(serverSecret));
    final signature = hmacSha256.convert(utf8.encode(payloadBase64));
    final signatureBase64 = base64Url.encode(signature.bytes);

    // 4. Assemble the final token
    final tokenObject = {
      'ver': '1',
      'hash': '4', // Represents HMAC-SHA256
      'nonce': payloadMap['nonce'],
      'expired': expiredTime,
      'iv': '', // Not used in this version
      'data': payloadBase64,
      'sign': signatureBase64,
    };

    // 5. Convert the token object to JSON and then Base64
    final tokenJson = jsonEncode(tokenObject);
    final token = '04${base64.encode(utf8.encode(tokenJson))}';
    
    return token;
  }
}