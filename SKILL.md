---
name: hermes-hudui-installer
description: "一键安装 Hermes HUD 看板（含5套自定义皮肤）— 让你的Hermes拥有浏览器监控面板"
---

# Hermes HUD 看板 — 一键安装技能

## 这是什么

给你的 Hermes Agent 装一个浏览器监控面板，可以看到会话、Token 费用、记忆、技能、网关状态等18个标签页。额外附赠5套自定义皮肤。

## 前提条件

- Python 3.11+
- Node.js 18+
- Hermes Agent 已运行过（有数据目录）
- Windows 系统

## 使用方法

### ① 安装本技能

把下面这行命令复制给你的 Hermes Agent：

```
hermes skills install https://raw.githubusercontent.com/Ledsung/hermes-hudui-pack/main/SKILL.md
```

### ② 执行安装

对你的 Hermes 说：

> "加载 hermes-hudui-installer 技能，帮我装看板"

Hermes 会自动执行以下操作：
- 从 GitHub 下载一键安装包
- 运行 install-windows.bat
- 安装完成后，你桌面上会出现「启动Hermes看板.bat」
- 双击它，浏览器打开 http://localhost:3001
- 按键盘 t 键切换皮肤

## 手工安装（如果自动失败）

如果自动安装卡住了，可以手工操作：

1. 打开 https://github.com/Ledsung/hermes-hudui-pack
2. 点绿色「Code」按钮 → Download ZIP
3. 解压到任意目录
4. 双击 install-windows.bat
5. 等它跑完，双击桌面「启动Hermes看板.bat」

## 注意事项

- 安装过程约3-5分钟，取决于网络速度
- 看板不消耗 Hermes 的 Token 配额
- 看板不影响 Hermes 运行速度
- 如需卸载，删除 D:\Hermes\hermes-hudui 目录即可
