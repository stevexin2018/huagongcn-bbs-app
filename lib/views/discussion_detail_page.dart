import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../models/discussion.dart';
import '../api/api_service.dart';

class DiscussionDetailPage extends StatefulWidget {
  final Discussion discussion;

  const DiscussionDetailPage({super.key, required this.discussion});

  @override
  State<DiscussionDetailPage> createState() => _DiscussionDetailPageState();
}

class _DiscussionDetailPageState extends State<DiscussionDetailPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = await _apiService.getDiscussionDetail(widget.discussion.id);
    if (data != null && data['included'] != null) {
      final List<dynamic> included = data['included'];
      final List<Map<String, dynamic>> postList = [];

      for (final item in included) {
        if (item['type'] == 'posts') {
          final attr = item['attributes'] as Map<String, dynamic>? ?? {};
          // 只保留正常主楼/评论回复
          if (attr['contentType'] == 'comment' || attr['contentHtml'] != null) {
            postList.add({
              'id': item['id'],
              'number': attr['number'],
              'createdAt': attr['createdAt'],
              'contentHtml': attr['contentHtml'] ?? '',
              'content': attr['content'] ?? '',
            });
          }
        }
      }

      // 按楼层升序排序
      postList.sort((a, b) => (a['number'] as int? ?? 0).compareTo(b['number'] as int? ?? 0));

      setState(() {
        _posts = postList;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载讨论详情失败';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.discussion.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDetails,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _posts.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    final floor = post['number'] ?? (index + 1);
                    final isFirst = index == 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 楼层头部信息
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isFirst ? const Color(0xFF0F4C81) : Colors.blueGrey,
                              child: Text(
                                isFirst ? '楼主' : '#$floor',
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFirst ? widget.discussion.userName : '工程师 #${floor}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (post['createdAt'] != null)
                                  Text(
                                    post['createdAt'].toString().substring(0, 10),
                                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isFirst ? '首楼' : '${floor}楼',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 楼层正文（工科 Markdown 渲染）
                        MarkdownBody(
                          data: _cleanHtmlToMarkdown(post['contentHtml'] ?? post['content'] ?? ''),
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF2D3748)),
                            h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                            h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                            code: const TextStyle(backgroundColor: Color(0xFFEDF2F7), fontFamily: 'monospace'),
                            blockquote: const TextStyle(color: Color(0xFF4A5568)),
                            blockquoteDecoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
                              border: const Border(left: BorderSide(color: Color(0xFF0F4C81), width: 4)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text('写下您的工程观点与计算见解...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF0F4C81)),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _cleanHtmlToMarkdown(String html) {
    // 简易将 Flarum HTML 转换为 Markdown 语法供 MarkdownBody 渲染
    String text = html;
    text = text.replaceAll(RegExp(r'<p>'), '\n');
    text = text.replaceAll(RegExp(r'</p>'), '\n');
    text = text.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    text = text.replaceAll(RegExp(r'<strong>(.*?)</strong>'), '**\$1**');
    text = text.replaceAll(RegExp(r'<b>(.*?)</b>'), '**\$1**');
    text = text.replaceAll(RegExp(r'<em>(.*?)</em>'), '*\$1*');
    text = text.replaceAll(RegExp(r'<i>(.*?)</i>'), '*\$1*');
    text = text.replaceAll(RegExp(r'<li>(.*?)</li>'), '- \$1\n');
    text = text.replaceAll(RegExp(r'<a\s+href="([^"]+)">(.*?)</a>'), '[\$2](\$1)');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    return text.trim();
  }
}
