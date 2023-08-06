#include "include/epay/epay_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "epay_plugin.h"

void EpayPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  epay::EpayPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
