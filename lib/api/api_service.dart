import 'package:dio/dio.dart';
import '../models/discussion.dart';
import '../models/tag.dart';

class ApiService {
  static const String baseUrl = 'https://bbs.huagongcn.top/api/';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    ),
  );

  Future<List<Discussion>> getDiscussions({
    int offset = 0,
    int limit = 20,
    String? tagSlug,
  }) async {
    final query = <String, dynamic>{
      'page[offset]': offset,
      'page[limit]': limit,
      'include': 'user,lastPostedUser,tags,firstPost',
    };
    if (tagSlug != null && tagSlug.isNotEmpty) {
      query['filter[tag]'] = tagSlug;
    }

    final response = await _dio.get('discussions', queryParameters: query);
    if (response.statusCode != 200) return [];
    final data = response.data as Map<String, dynamic>;
    final included = data['included'] as List<dynamic>? ?? [];
    final rawList = data['data'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => Discussion.fromJsonApi(item, included))
        .toList();
  }

  Future<Map<String, dynamic>?> getDiscussionDetail(String id) async {
    try {
      final response = await _dio.get(
        'discussions/$id',
        queryParameters: {'include': 'user,posts,posts.user,tags'},
      );
      return response.statusCode == 200
          ? response.data as Map<String, dynamic>
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Tag>> getTags() async {
    try {
      final response = await _dio.get('tags');
      if (response.statusCode != 200) return [];
      final data = response.data as Map<String, dynamic>;
      final rawList = data['data'] as List<dynamic>? ?? [];
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(Tag.fromJsonApi)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> login(
    String identification,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        'token',
        data: {'identification': identification, 'password': password},
      );
      if (response.statusCode != 200 || response.data is! Map) return null;
      final data = Map<String, dynamic>.from(response.data as Map);
      return data['token'] == null || data['userId'] == null ? null : data;
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String id, String token) async {
    final response = await _dio.get(
      'users/$id',
      queryParameters: {'include': 'groups'},
      options: Options(headers: {'Authorization': 'Token $token; userId=$id'}),
    );
    final payload = response.data as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'users',
        data: {
          'data': {
            'type': 'users',
            'attributes': {
              'username': username,
              'email': email,
              'password': password,
            },
          },
        },
      );
      if ((response.statusCode != 200 && response.statusCode != 201) || response.data is! Map) return null;
      final data = Map<String, dynamic>.from(response.data as Map);
      return data['data'] as Map<String, dynamic>?;
    } on DioException {
      return null;
    }
  }
}
