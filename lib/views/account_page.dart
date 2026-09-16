import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _loginIdController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  bool _loginPasswordVisible = false;
  bool _registerPasswordVisible = false;

  @override
  void dispose() {
    _loginIdController.dispose();
    _loginPasswordController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '请输入$label';
    return null;
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().signIn(
          _loginIdController.text,
          _loginPasswordController.text,
        );
    if (ok && mounted) Navigator.pop(context);
  }

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _usernameController.text,
      _emailController.text,
      _registerPasswordController.text,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoggedIn) {
          return Scaffold(
            appBar: AppBar(title: const Text('我的账户')),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: auth.isAdministrator
                      ? const Color(0xFFB72A2A)
                      : const Color(0xFF0F4C81),
                  child: Text(
                    auth.displayName.isEmpty ? '用' : auth.displayName.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(auth.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Chip(
                    avatar: Icon(auth.isAdministrator ? Icons.admin_panel_settings : Icons.person,
                        size: 18),
                    label: Text(auth.isAdministrator ? '管理员账户' : '普通会员账户'),
                  ),
                ),
                const SizedBox(height: 24),
                if (auth.isAdministrator)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.admin_panel_settings, color: Color(0xFFB72A2A)),
                      title: Text('管理员权限已识别'),
                      subtitle: Text('论坛内容、成员和标签管理请使用网页版管理后台。'),
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('退出登录'),
                  onTap: () async {
                    await auth.signOut();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('账户登录'),
              bottom: const TabBar(tabs: [Tab(text: '登录'), Tab(text: '注册')]),
            ),
            body: TabBarView(
              children: [_buildLogin(auth), _buildRegister(auth)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogin(AuthProvider auth) {
    return Form(
      key: _loginFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('登录后可参与发帖、回复及管理个人账户。',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          TextFormField(
            controller: _loginIdController,
            decoration: const InputDecoration(
              labelText: '用户名或邮箱',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) => _required(v, '用户名或邮箱'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: !_loginPasswordVisible,
            decoration: InputDecoration(
              labelText: '密码',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_loginPasswordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _loginPasswordVisible = !_loginPasswordVisible),
              ),
            ),
            validator: (v) => _required(v, '密码'),
          ),
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: auth.isSigningIn ? null : _login,
            icon: auth.isSigningIn
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.login),
            label: const Text('登录论坛账户'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister(AuthProvider auth) {
    return Form(
      key: _registerFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('当前论坛实行注册即激活。注册后可直接登录发帖。',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: '用户名', prefixIcon: Icon(Icons.person_add), border: OutlineInputBorder()),
            validator: (v) => _required(v, '用户名'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: '邮箱', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
            validator: (v) {
              final required = _required(v, '邮箱');
              if (required != null) return required;
              return v!.contains('@') ? null : '请输入有效邮箱地址';
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _registerPasswordController,
            obscureText: !_registerPasswordVisible,
            decoration: InputDecoration(
              labelText: '密码（至少 8 位）',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_registerPasswordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _registerPasswordVisible = !_registerPasswordVisible),
              ),
            ),
            validator: (v) {
              final required = _required(v, '密码');
              if (required != null) return required;
              return v!.length >= 8 ? null : '密码至少需要 8 位';
            },
          ),
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: auth.isSigningIn ? null : _register,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('注册并自动登录'),
          ),
        ],
      ),
    );
  }
}
