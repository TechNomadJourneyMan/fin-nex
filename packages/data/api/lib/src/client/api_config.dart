/// Configuration for the PocketFlow API client.
class ApiConfig {
  /// Default constructor.
  const ApiConfig({
    required this.baseUrl,
    this.clientVersion = 'pocketflow-flutter/0.1.0',
    this.defaultLocale = 'ru-RU',
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.envToken,
  });

  /// Base URL, e.g. `https://api.finnex.kz/v1`.
  final String baseUrl;

  /// Value sent in the `X-Client-Version` header.
  final String clientVersion;

  /// Default `Accept-Language`.
  final String defaultLocale;

  /// Dio connect timeout.
  final Duration connectTimeout;

  /// Dio receive timeout.
  final Duration receiveTimeout;

  /// Dio send timeout.
  final Duration sendTimeout;

  /// Optional `X-Env-Token` for non-prod environments.
  final String? envToken;
}
