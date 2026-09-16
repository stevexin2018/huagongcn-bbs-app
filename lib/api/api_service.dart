import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/discussion.dart';
import '../models/tag.dart';

class ApiService {
  static const String baseUrl = 'https://bbs.huagongcn.top/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  /// 获取讨论主题列表（支持分页和标签过滤）
  Future<List<Discussion>> getDiscussions({int offset = 0, int limit = 20, String? tagSlug}) async {
    try {
      final Map<String, dynamic> query = {
        'page[offset]': offset,
        'page[limit]': limit,
        'include': 'user,lastPostedUser,tags,firstPost',
      };
      if (tagSlug != null && tagSlug.isNotEmpty) {
        query['filter[tag]'] = tagSlug;
      }

      final response = await _dio.get('/discussions', queryParameters: query);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> included = data['included'] ?? [];
        final List<dynamic> rawList = data['data'] ?? [];

        return rawList.map((item) => Discussion.fromJsonApi(item, included)).toList();
      }
      return [];
    } catch (e) {
      // 抛出真实网络异常供界面展示与诊断
      rethrow;
    }
  }

  /// 获取讨论详情及楼层回复
  Future<Map<String, dynamic>?> getDiscussionDetail(String id) async {
    try {
      final response = await _dio.get(
        '/discussions/$id',
        queryParameters: {
          'include': 'user,posts,posts.user,tags',
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取分类标签（版块）列表
  Future<List<Tag>> getTags() async {
    try {
      final response = await _dio.get('/tags');
      if (response.statusCode == 200) {
        final List<dynamic> rawList = response.data['data'] ?? [];
        return rawList.map((item) => Tag.fromJsonApi(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 用户登录获取 Access Token
  Future<String?> login(String identification, String password) async {
    try {
      final response = await _dio.post(
        '/token',
        data: {
          'identification': identification,
          'password': password,
        },
      );
      if (response.statusCode == 200 && response.data['token'] != null) {
        return response.data['token'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
