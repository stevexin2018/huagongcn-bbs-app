import 'package:flutter/material.dart';
import '../models/discussion.dart';
import '../models/tag.dart';
import '../api/api_service.dart';

class ForumProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Discussion> _discussions = [];
  List<Tag> _tags = [];
  bool _isLoading = false;
  String? _selectedTagSlug;
  String? _errorMessage;

  List<Discussion> get discussions => _discussions;
  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get selectedTagSlug => _selectedTagSlug;
  String? get errorMessage => _errorMessage;

  ForumProvider() {
    init();
  }

  Future<void> init() async {
    await fetchTags();
    await fetchDiscussions();
  }

  Future<void> fetchTags() async {
    try {
      _tags = await _apiService.getTags();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> fetchDiscussions({bool refresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _discussions = await _apiService.getDiscussions(
        offset: refresh ? 0 : _discussions.length,
        limit: 20,
        tagSlug: _selectedTagSlug,
      );
    } catch (e) {
      _errorMessage = '获取帖子列表失败，请检查网络连接';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTag(String? tagSlug) {
    if (_selectedTagSlug == tagSlug) return;
    _selectedTagSlug = tagSlug;
    fetchDiscussions(refresh: true);
  }
}
