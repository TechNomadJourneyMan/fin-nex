import 'user_dto.dart';

/// Auth method discriminator for `/auth/sign-in` and `/auth/sign-up`.
enum AuthMethod {
  /// Phone OTP flow.
  phone,

  /// Apple Sign In.
  apple,

  /// Google Sign In.
  google;

  /// Wire code (lower-case).
  String get code => name;
}

/// `/auth/sign-in` request body.
class SignInRequest {
  /// Default constructor.
  const SignInRequest({
    required this.method,
    this.phone,
    this.idToken,
    this.locale,
    this.timezone,
  });

  /// Auth method.
  final AuthMethod method;

  /// E.164 phone (required for [AuthMethod.phone]).
  final String? phone;

  /// OAuth id token (required for [AuthMethod.apple]/[AuthMethod.google]).
  final String? idToken;

  /// BCP-47 locale.
  final String? locale;

  /// IANA timezone.
  final String? timezone;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method.code,
        if (phone != null) 'phone': phone,
        if (idToken != null) 'id_token': idToken,
        if (locale != null) 'locale': locale,
        if (timezone != null) 'timezone': timezone,
      };
}

/// `/auth/sign-up` request body.
class SignUpRequest {
  /// Default constructor.
  const SignUpRequest({
    required this.method,
    this.phone,
    this.idToken,
    this.locale,
    this.timezone,
    this.marketingConsent = false,
    this.referralCode,
  });

  /// Auth method.
  final AuthMethod method;

  /// E.164 phone.
  final String? phone;

  /// OAuth id token.
  final String? idToken;

  /// BCP-47 locale.
  final String? locale;

  /// IANA timezone.
  final String? timezone;

  /// Marketing opt-in.
  final bool marketingConsent;

  /// Optional referral code.
  final String? referralCode;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method.code,
        if (phone != null) 'phone': phone,
        if (idToken != null) 'id_token': idToken,
        if (locale != null) 'locale': locale,
        if (timezone != null) 'timezone': timezone,
        'marketing_consent': marketingConsent,
        if (referralCode != null) 'referral_code': referralCode,
      };
}

/// Auth token bundle.
class AuthTokensDto {
  /// Default constructor.
  const AuthTokensDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    this.expiresAt,
  });

  /// JWT.
  final String accessToken;

  /// Opaque refresh token.
  final String refreshToken;

  /// Seconds until access token expiry.
  final int expiresIn;

  /// Always `Bearer` today.
  final String tokenType;

  /// Server-computed absolute expiry (UTC), when supplied.
  final DateTime? expiresAt;

  /// Parse from JSON.
  factory AuthTokensDto.fromJson(Map<String, dynamic> json) => AuthTokensDto(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresIn: (json['expires_in'] as num).toInt(),
        tokenType: (json['token_type'] as String?) ?? 'Bearer',
        expiresAt: json['expires_at'] is String
            ? DateTime.parse(json['expires_at'] as String)
            : null,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
        'token_type': tokenType,
        if (expiresAt != null)
          'expires_at': expiresAt!.toUtc().toIso8601String(),
      };
}

/// Full sign-in/sign-up response (tokens + user).
class SignInResponse {
  /// Default constructor.
  const SignInResponse({required this.tokens, this.user});

  /// Tokens.
  final AuthTokensDto tokens;

  /// Authenticated user.
  final UserDto? user;

  /// Parse from JSON.
  factory SignInResponse.fromJson(Map<String, dynamic> json) => SignInResponse(
        tokens: AuthTokensDto.fromJson(json),
        user: json['user'] is Map<String, dynamic>
            ? UserDto.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        ...tokens.toJson(),
        if (user != null) 'user': user!.toJson(),
      };
}

/// `/auth/otp/request` body.
class OtpRequestRequest {
  /// Default constructor.
  const OtpRequestRequest({required this.phone, this.purpose = 'sign_in'});

  /// E.164 phone number.
  final String phone;

  /// `sign_in | sign_up | change_phone`.
  final String purpose;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'phone': phone,
        'purpose': purpose,
      };
}

/// `/auth/otp/request` response.
class OtpRequestResponse {
  /// Default constructor.
  const OtpRequestResponse({
    required this.requestId,
    required this.expiresIn,
    required this.resendAfter,
  });

  /// Server-issued OTP request id.
  final String requestId;

  /// Seconds until OTP expiry.
  final int expiresIn;

  /// Cooldown before a resend is allowed.
  final int resendAfter;

  /// Parse from JSON.
  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) =>
      OtpRequestResponse(
        requestId: json['request_id'] as String,
        expiresIn: (json['expires_in'] as num).toInt(),
        resendAfter: (json['resend_after'] as num?)?.toInt() ?? 60,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'request_id': requestId,
        'expires_in': expiresIn,
        'resend_after': resendAfter,
      };
}

/// `/auth/otp/verify` body.
class OtpVerifyRequest {
  /// Default constructor.
  const OtpVerifyRequest({required this.requestId, required this.code});

  /// OTP request id from [OtpRequestResponse].
  final String requestId;

  /// 6-digit code.
  final String code;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'request_id': requestId,
        'code': code,
      };
}

/// `/auth/refresh` body.
class RefreshRequest {
  /// Default constructor.
  const RefreshRequest({required this.refreshToken});

  /// Existing refresh token.
  final String refreshToken;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'refresh_token': refreshToken,
      };
}
