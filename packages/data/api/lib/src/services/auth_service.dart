import 'package:dio/dio.dart';

import '../dto/auth_dto.dart';
import '../interceptors/auth_interceptor.dart';
import '_dio_helpers.dart';

/// Typed client for the `/auth/*` and `/me` endpoints.
class AuthService {
  /// Default constructor.
  AuthService(this._dio);

  final Dio _dio;

  /// Register a new user.
  Future<SignInResponse> signUp(SignUpRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/auth/sign-up',
          data: request.toJson(),
          options: Options(extra: <String, dynamic>{
            AuthInterceptor.skipAuthExtraKey: true,
          }),
        );
        return SignInResponse.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Sign in an existing user.
  Future<SignInResponse> signIn(SignInRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/auth/sign-in',
          data: request.toJson(),
          options: Options(extra: <String, dynamic>{
            AuthInterceptor.skipAuthExtraKey: true,
          }),
        );
        return SignInResponse.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Request an OTP code.
  Future<OtpRequestResponse> requestOtp(OtpRequestRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/auth/otp/request',
          data: request.toJson(),
          options: Options(extra: <String, dynamic>{
            AuthInterceptor.skipAuthExtraKey: true,
          }),
        );
        return OtpRequestResponse.fromJson(
          res.data ?? const <String, dynamic>{},
        );
      });

  /// Verify an OTP code and return tokens.
  Future<SignInResponse> verifyOtp(OtpVerifyRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/auth/otp/verify',
          data: request.toJson(),
          options: Options(extra: <String, dynamic>{
            AuthInterceptor.skipAuthExtraKey: true,
          }),
        );
        return SignInResponse.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Rotate the refresh + access tokens.
  Future<AuthTokensDto> refresh(String refreshToken) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: RefreshRequest(refreshToken: refreshToken).toJson(),
          options: Options(extra: <String, dynamic>{
            AuthInterceptor.skipAuthExtraKey: true,
          }),
        );
        return AuthTokensDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Sign out the current session.
  Future<void> signOut() => DioServiceHelpers.guard(() async {
        await _dio.post<void>('/auth/sign-out');
      });

  /// Sign out every device.
  Future<void> signOutAll() => DioServiceHelpers.guard(() async {
        await _dio.post<void>('/auth/sign-out-all');
      });
}
