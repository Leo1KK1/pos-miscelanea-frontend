import 'package:flutter/foundation.dart';

class ApiConfig {
  static const _configuredUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    final value = _configuredUrl.isNotEmpty
        ? _configuredUrl
        : kDebugMode
            ? (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
                ? 'http://10.0.2.2:3000'
                : 'http://localhost:3000')
            : '';
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        (uri.scheme != 'https' && !(kDebugMode && uri.scheme == 'http'))) {
      throw const ApiConfigurationException();
    }
    return uri.replace(path: '').toString().replaceFirst(RegExp(r'/$'), '');
  }
}

class ApiConfigurationException implements Exception {
  const ApiConfigurationException();
}
