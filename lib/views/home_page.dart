import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forum_provider.dart';
import '../providers/auth_provider.dart';
import '../models/discussion.dart';
import '../models/tag.dart';
import 'discussion_detail_page.dart';
import 'account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.engineering, size: 26),
            const SizedBox(width: 8),
            const Text(
              '化工机械研究论坛',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('ASME BPVC & 压力容器实战', style: TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) => IconButton(
              icon: Icon(auth.isLoggedIn ? Icons.account_circle : Icons.login),
              tooltip: auth.isLoggedIn ? '我的账户' : '登录或注册',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountPage()),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新讨论',
            onPressed: () {
              context.read<ForumProvider>().fetchDiscussions(refresh: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索论坛',
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isDesktop ? null : _buildMobileDrawer(context),
      body: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, auth, _) => FloatingActionButton.extended(
          onPressed: () {
            if (!auth.isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请先登录论坛账户后再发起讨论。')),
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountPage()),
              );
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('发帖编辑器将在下一版接入。')),
            );
          },
          backgroundColor: const Color(0xFF0F4C81),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.edit_note),
          label: Text(auth.isLoggedIn ? '发起新讨论' : '登录后发帖'),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 260,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: _buildTagList(context),
        ),
        Expanded(
          child: _buildDiscussionStream(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildDiscussionStream(context);
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0F4C81)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.precision_manufacturing, color: Colors.white, size: 36),
                  SizedBox(height: 10),
                  Text(
                    '化工机械研究社区',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'bbs.huagongcn.top',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildTagList(context)),
        ],
      ),
    );
  }

  Widget _buildTagList(BuildContext context) {
    return Consumer<ForumProvider>(
      builder: (context, provider, child) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.forum, color: Color(0xFF0F4C81)),
              title: const Text('全部讨论主题', style: TextStyle(fontWeight: FontWeight.bold)),
              selected: provider.selectedTagSlug == null,
              selectedTileColor: const Color(0xFFEBF8FF),
              onTap: () {
                provider.selectTag(null);
                if (Scaffold.of(context).isDrawerOpen) {
                  Navigator.pop(context);
                }
              },
            ),
            const Divider(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                '工程专业版块',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ...provider.tags.map((tag) {
              final isSelected = provider.selectedTagSlug == tag.slug;
              final Color tagColor = tag.color != null
                  ? Color(int.parse(tag.color!.replaceFirst('#', '0xFF')))
                  : const Color(0xFF4A5568);

              return ListTile(
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: tagColor,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  tag.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF0F4C81) : Colors.black87,
                  ),
                ),
                selected: isSelected,
                selectedTileColor: const Color(0xFFEBF8FF),
                onTap: () {
                  provider.selectTag(tag.slug);
                  if (Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildDiscussionStream(BuildContext context) {
    return Consumer<ForumProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.discussions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.discussions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(provider.errorMessage!),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.fetchDiscussions(refresh: true),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (provider.discussions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.inbox, size: 54, color: Colors.grey),
                SizedBox(height: 12),
                Text('该版块暂无讨论帖，快来发表首帖吧！', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchDiscussions(refresh: true),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: provider.discussions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = provider.discussions[index];
              return _buildDiscussionCard(context, item);
            },
          ),
        );
      },
    );
  }

  Widget _buildDiscussionCard(BuildContext context, Discussion item) {
    final displayName = item.userName ?? '匿名工程师';
    final initialChar = displayName.isNotEmpty ? displayName[0] : '工';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscussionDetailPage(discussion: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF0F4C81),
                    child: Text(
                      initialChar,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (item.tagNames.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.tagNames.first,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${item.commentCount} 条回复',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${item.participantCount} 人参与',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
