import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'epay_platform_interface.dart';

/// An implementation of [EpayPlatform] that uses method channels.
class MethodChannelEpay extends EpayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('epay');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
