# 化工机械研究社区跨平台客户端 (Huagongcn BBS App)

[![Build and Release Multi-Platform Apps](https://github.com/stevexin2018/huagongcn-bbs-app/actions/workflows/build_release.yml/badge.svg)](https://github.com/stevexin2018/huagongcn-bbs-app/actions/workflows/build_release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter)](https://flutter.dev)

面向化工装备、压力容器工程实战与 ASME BPVC 规范研读社区（[https://bbs.huagongcn.top](https://bbs.huagongcn.top)）的现代全平台原生客户端。

---

## 📱 支持平台与编译产物

基于 **Google Flutter 3.x** 构建，支持“一套代码、全端自适应（Responsive Layout）”：

| 平台类别 | 操作系统支持 | 编译安装包形态 | 布局适配模式 |
| :--- | :--- | :--- | :--- |
| **移动端 (Mobile)** | **Android** (5.0+) | `.apk` (支持 arm64-v8a / armeabi-v7a / x86_64) | 经典单栏沉浸式信息流 |
| **移动端 (Mobile)** | **Apple iOS** (12.0+) | `.ipa` (支持 iPhone / iPad) | iOS 人机交互自适应 |
| **桌面端 (Desktop)** | **Microsoft Windows** (10/11 x64) | `.zip` 免安装绿色版 / `.exe` | 三栏专业工作台布局 |
| **桌面端 (Desktop)** | **Apple macOS** (11.0+ Intel/Apple Silicon) | `.dmg` / `.app.zip` | 经典 Mac 工具栏与三栏流 |
| **桌面端 (Desktop)** | **Linux** (Ubuntu/Debian/Arch) | `.tar.gz` / `.AppImage` | GTK+ 桌面原生集成 |

---

## 🌟 核心特性

1. **真实 Flarum RESTful / JSON:API 驱动**：
   - 直连官方论坛后端（`https://bbs.huagongcn.top/api`）；
   - 支持主题列表分页拉取、版块分类过滤、主题详情、楼层列表及用户认证。
2. **工科专业级排版支持**：
   - 深度集成 **Markdown 渲染引擎**；
   - 针对工程公式、代码块、规范引用引用框（Blockquote）进行高对比度样式定制。
3. **自适应响应式架构（Responsive UI）**：
   - 屏幕宽度 `< 900px`（手机端）：自动切换为单栏底部导航/侧滑抽屉体验；
   - 屏幕宽度 `≥ 900px`（电脑端）：自动展开为“左侧版块树 + 中间主题流 + 顶部专业工具栏”的三栏桌面级交互。
4. **全自动云端编译发布（CI/CD）**：
   - 配置 GitHub Actions 自动化工作流；
   - 每次打 Tag（如 `v0.1.0`）或推送到主分支，云端虚拟机会自动并行编译出 **Android APK、Windows 免安装包与 macOS App 压缩包** 并上传为 Release 产物。

---

## 🛠️ 本地开发与构建

### 1. 环境准备
* 安装 [Flutter SDK (>= 3.19.0)](https://flutter.dev/docs/get-started/install)
* 配置 Android SDK 或 Xcode / Visual Studio 编译工具链

### 2. 获取代码与依赖安装
```bash
git clone https://github.com/stevexin2018/huagongcn-bbs-app.git
cd huagongcn-bbs-app
flutter pub get
```

### 3. 运行与调试
```bash
# 运行于当前连接的设备（Chrome / 桌面 / 手机）
flutter run

# 运行特定桌面端（需先在系统启用桌面支持）
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

### 4. 手动编译打包
```bash
# 编译 Android Release APK
flutter build apk --release --split-per-abi

# 编译 Windows 桌面应用
flutter build windows --release

# 编译 macOS 桌面应用
flutter build macos --release
```

---

## 📂 工程目录结构

```text
huagongcn-bbs-app/
├── .github/
│   └── workflows/
│       └── build_release.yml   # 全平台 GitHub Actions 自动编译工作流
├── assets/
│   └── images/                 # 图标与静态图片资源
├── lib/
│   ├── api/
│   │   └── api_service.dart    # Flarum JSON:API 客户端网络层 (Dio)
│   ├── models/
│   │   ├── discussion.dart     # 主题讨论实体模型
│   │   └── tag.dart            # 版块标签实体模型
│   ├── providers/
│   │   └── forum_provider.dart # 论坛全局状态管理 (Provider)
│   ├── views/
│   │   ├── home_page.dart      # 响应式主页（自适应手机与桌面双布局）
│   │   └── discussion_detail_page.dart # 主题楼层详情与 Markdown 渲染页
│   └── main.dart               # 应用程序入口与 Material3 主题配置
├── pubspec.yaml                # 项目依赖清单
├── LICENSE                     # MIT 开源协议
└── README.md                   # 项目工程说明文档
```

---

## 📄 开源协议

本项目基于 **MIT License** 开源。
欢迎广大会工机械、化工装备设计与压力容器工程技术同仁参与共建与交流！
