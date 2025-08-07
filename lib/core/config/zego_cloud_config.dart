import 'package:flutter_dotenv/flutter_dotenv.dart';

class ZegoConfig {
  final int appId;
  final String appSign;
  final String serverSecret; // <<<--- NAYI PROPERTY

  ZegoConfig()
      : appId = int.parse(dotenv.env['ZEGO_CLOUD_APP_ID'] ?? '0'),
        appSign = dotenv.env['ZEGO_CLOUD_APP_SIGN'] ?? '',
        serverSecret = dotenv.env['ZEGO_SERVER_SECRET'] ?? ''; // <<<--- READ KAREIN
}