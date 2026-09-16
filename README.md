# 化工机械研究社区跨平台客户端 (Huagongcn BBS App)

[![Build and Release Multi-Platform Apps](https://github.com/stevexin2018/huagongcn-bbs-app/actions/workflows/build.yml/badge.svg)](https://github.com/stevexin2018/huagongcn-bbs-app/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.19.6-02569B?logo=flutter)](https://flutter.dev)

面向化工装备、压力容器工程实战与 ASME BPVC 规范研读社区（[https://bbs.huagongcn.top](https://bbs.huagongcn.top)）的现代全平台原生客户端。

---

## 📱 支持平台与最新构建下载 (v0.1.0-alpha)

所有客户端均由 GitHub Actions 在云端环境自动原生编译构建，支持全平台原生运行与三栏响应式自适应布局：

| 平台类别 | 操作系统与架构 | 安装包下载 | 运行说明 |
| :--- | :--- | :--- | :--- |
| **Android** | Android 5.0+ (Universal ARM/x86) | [📥 app-release.apk (21.0 MB)](https://github.com/stevexin2018/huagongcn-bbs-app/releases/download/v0.1.0-alpha/app-release.apk) | 支持各类安卓手机与工控平板 |
| **Windows** | Windows 10 / 11 (x64) | [📥 huagongcn-bbs-windows-x64-release.zip (11.5 MB)](https://github.com/stevexin2018/huagongcn-bbs-app/releases/download/v0.1.0-alpha/huagongcn-bbs-windows-x64-release.zip) | 解压即用绿色版，双击 exe 直接运行 |
| **macOS** | macOS 11.0+ (Apple Silicon M系列 / Intel) | [📥 huagongcn-bbs-macos-release.zip (19.9 MB)](https://github.com/stevexin2018/huagongcn-bbs-app/releases/download/v0.1.0-alpha/huagongcn-bbs-macos-release.zip) | 解压拖入 Applications 目录即可 |
| **Linux** | Ubuntu / Debian / CentOS / Arch (x64) | [📥 huagongcn-bbs-linux-x64-release.tar.gz (9.4 MB)](https://github.com/stevexin2018/huagongcn-bbs-app/releases/download/v0.1.0-alpha/huagongcn-bbs-linux-x64-release.tar.gz) | 解压后直接运行可执行二进制文件 |

---

## 🌟 核心特性与技术栈

1. **社区官方 API 实时驱动**：
   - 直连官方论坛后端（`https://bbs.huagongcn.top/api`）；
   - 支持主题列表分页拉取、版块分类过滤、主题楼层互动及用户认证。
2. **工科专业级排版支持**：
   - 深度集成 **Markdown 渲染引擎**；
   - 完美适配压力容器工程公式、参数对比表格、规范引用卡片。
3. **自适应响应式架构（Responsive UI）**：
   - 屏幕宽度 `< 900px`（移动端）：自适应单栏沉浸式信息流与抽屉导航；
   - 屏幕宽度 `≥ 900px`（桌面端）：自适应三栏专业工作台（左侧分类树 + 中间讨论流 + 顶部快捷检索）。

---

## 🛠️ 本地开发与构建

```bash
git clone https://github.com/stevexin2018/huagongcn-bbs-app.git
cd huagongcn-bbs-app
flutter pub get

# 运行调试
flutter run

# 全平台编译
flutter build apk --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

---

## 📄 开源协议
本项目基于 **MIT License** 开源。
欢迎广大会工机械、化工装备设计与压力容器工程技术同仁参与共建！
