---
name: latex-helper
description: LaTeX real-time editing workflow — watch, edit, insert images, auto-compile with latexmk -pvc
---
# latex-helper

LaTeX 实时编辑协作工作流。用户给一个 `.tex` 文件路径，你负责编辑、插图片、监听编译，用户刷新 PDF 看效果。

## 工作流程

### 1. 获取文件路径

用户说「帮我改 LaTeX」时，先确认 `.tex` 文件完整路径。

### 2. 启动实时监听

```bash
run_background("D:\\Reasonix\\watch-tex.bat", args: ["<.tex完整路径>"])
```

这会启动 `latexmk -pvc`，检测到 `.tex` 变化就自动重编译。

### 3. 编辑 .tex 文件

- 用户告诉你要改哪里、加什么
- 用 `read_file` 定位要改的段落
- 用 `edit_file` 修改
- `latexmk` 自动检测到变化并重编译
- 告诉用户「刷新 PDF 看效果」

### 4. 插入图片

如果用户说「插入一张图」：

1. 找到图片文件路径
2. 用 `shutil.copy2()` 把图片复制到 `.tex` 同目录（文件名简短，不要中文）
3. 用 `edit_file` 在合适位置插入 `\begin{figure}` 代码块
4. 告诉用户刷新 PDF

### 注意事项

- 图片必须复制到 `.tex` 同目录，否则 LaTeX 找不到
- 文件名改成简短英文（如 `fig01.png`）
- 如果 `latexmk` 编译报错，检查 `.log` 文件排查

## 用法示例

用户说：「帮我改 LaTeX」
  → 问清楚文件路径
  → run_background watch-tex.bat
  → 然后等用户指令

用户说：「在第三个回答里插入这张图 C:\xxx\图.png」
  → 复制到同目录
  → 编辑 .tex 插入 figure 环境
  → 告诉用户刷新 PDF
