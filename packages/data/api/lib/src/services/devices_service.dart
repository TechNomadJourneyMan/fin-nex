import 'package:dio/dio.dart';

import '../dto/device_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/devices`.
class DevicesService {
  /// Default constructor.
  DevicesService(this._dio);

  final Dio _dio;

  /// List registered devices.
  Future<List<DeviceDto>> list() => DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/devices');
        final data =
            (res.data?['data'] as List<dynamic>?) ?? const <dynamic>[];
        return data
            .map((dynamic e) =>
                DeviceDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      });

  /// Register the current device.
  Future<DeviceDto> register(RegisterDeviceRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/devices',
          data: request.toJson(),
        );
        return DeviceDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Unregister / logout a device by id.
  Future<void> remove(String id) => DioServiceHelpers.guard(() async {
        await _dio.delete<void>('/devices/$id');
      });
}
