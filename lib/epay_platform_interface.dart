import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'epay_method_channel.dart';

abstract class EpayPlatform extends PlatformInterface {
  /// Constructs a EpayPlatform.
  EpayPlatform() : super(token: _token);

  static final Object _token = Object();

  static EpayPlatform _instance = MethodChannelEpay();

  /// The default instance of [EpayPlatform] to use.
  ///
  /// Defaults to [MethodChannelEpay].
  static EpayPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EpayPlatform] when
  /// they register themselves.
  static set instance(EpayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
