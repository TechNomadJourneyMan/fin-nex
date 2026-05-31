import 'package:dio/dio.dart';

import '../dto/category_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/categories`.
class CategoriesService {
  /// Default constructor.
  CategoriesService(this._dio);

  final Dio _dio;

  /// List categories.
  Future<List<CategoryDto>> list({
    String kind = 'all',
    bool includeSystem = true,
    bool includeUser = true,
  }) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/categories',
          queryParameters: <String, dynamic>{
            'kind': kind,
            'include_system': includeSystem,
            'include_user': includeUser,
          },
        );
        final data =
            (res.data?['data'] as List<dynamic>?) ?? const <dynamic>[];
        return data
            .map((dynamic e) =>
                CategoryDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      });

  /// Create a category.
  Future<CategoryDto> create(CreateCategoryRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/categories',
          data: request.toJson(),
        );
        return CategoryDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Patch a category.
  Future<CategoryDto> update(
    String id,
    UpdateCategoryRequest request, {
    String? ifMatch,
  }) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
          '/categories/$id',
          data: request.toJson(),
          options: DioServiceHelpers.ifMatch(ifMatch),
        );
        return CategoryDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Delete (optionally reassigning to [reassignTo]) a category.
  Future<void> delete(String id, {String? reassignTo, String? ifMatch}) =>
      DioServiceHelpers.guard(() async {
        await _dio.delete<void>(
          '/categories/$id',
          queryParameters: <String, dynamic>{
            if (reassignTo != null) 'reassign_to': reassignTo,
          },
          options: DioServiceHelpers.ifMatch(ifMatch),
        );
      });
}
