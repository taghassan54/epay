import 'package:flutter_test/flutter_test.dart';
import 'package:epay/epay.dart';
import 'package:epay/epay_platform_interface.dart';
import 'package:epay/epay_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEpayPlatform
    with MockPlatformInterfaceMixin
    implements EpayPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EpayPlatform initialPlatform = EpayPlatform.instance;

  test('$MethodChannelEpay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEpay>());
  });

  test('getPlatformVersion', () async {
    Epay epayPlugin = Epay(ip: '172.16.0.92',port: 6666, deviceId: 'EKIOSK01');
    MockEpayPlatform fakePlatform = MockEpayPlatform();
    EpayPlatform.instance = fakePlatform;

    expect(await epayPlugin.getPlatformVersion(), '42');
  });
}
