---
name: latex-helper
description: LaTeX real-time editing workflow — watch, edit, insert images, auto-compile with latexmk -pvc
---
# latex-helper

LaTeX 实时编辑协作工作流。用户给一个 `.tex` 文件路径，AI 负责编辑、插图片、监听编译，用户刷新 PDF 看效果。

> **适配说明**：本 skill 使用通用描述代替具体工具名和路径。
> 使用时请将以下占位符替换成你所用 AI 的真实工具名和实际路径：
>
> | 占位符 | 替换为 |
> |--------|--------|
> | `[FILE_READER]` | 你 AI 读取文件的工具（如 `read_file`、`view`、`cat`） |
> | `[FILE_EDITOR]` | 你 AI 修改文件的工具（如 `edit_file`、`replace`、`patch`） |
> | `[RUN_CMD]` | 你 AI 运行命令的工具（如 `run_command`、`execute`、`shell`） |
> | `[COPY_CMD]` | 你 AI 复制文件的命令（如 `cp`、`copy`） |
> | `[WATCH_SCRIPT_PATH]` | `watch-tex.bat` 在你机器上的实际路径 |

## 工作流程

### 第一步：获取文件路径

用户说「帮我改 LaTeX」时，先确认 `.tex` 文件完整路径。

### 第二步：安装 watch-tex.bat（第一次使用）

从 GitHub 下载 `watch-tex.bat`，放到一个固定的目录（如 `C:\Tools\` 或 `D:\Reasonix\`），把这个目录加到系统 PATH 中。

验证安装：

```bash
watch-tex.bat --help
```

如果显示 latexmk 的帮助信息，说明安装成功。

### 第三步：启动实时监听

```bash
[RUN_CMD] 后台运行 "[WATCH_SCRIPT_PATH]" "<.tex完整路径>"
```

例如替换后：
```
run_background("D:\\Tools\\watch-tex.bat", args: ["C:\\论文\\main.tex"])
```

这会启动 `latexmk -pvc`，检测到 `.tex` 变化就自动重编译。

### 第四步：编辑 .tex 文件

- 用户告诉你要改哪里、加什么
- 用 `[FILE_READER]` 定位要改的段落
- 用 `[FILE_EDITOR]` 修改
- `latexmk` 自动检测到变化并重编译
- 告诉用户「刷新 PDF 看效果」

### 第五步：插入图片

如果用户说「插入一张图」：

1. 找到图片文件路径
2. 用 `[COPY_CMD]` 把图片复制到 `.tex` 同目录（文件名改成简短英文，如 `fig01.png`）
3. 用 `[FILE_EDITOR]` 在合适位置插入：

```latex
\begin{figure}[htbp]
    \centering
    \includegraphics[width=0.8\textwidth]{fig01.png}
    \caption{图片说明}
    \label{fig:label}
\end{figure}
```

4. 告诉用户刷新 PDF

### 注意事项

- 图片必须复制到 `.tex` 同目录，否则 LaTeX 找不到
- 文件名不要用中文或空格
- 如果 `latexmk` 编译报错，检查 `.log` 文件排查

## 用法示例

```
用户：「帮我改 LaTeX」
  → AI 问清楚文件路径
  → AI 启动 watch-tex.bat 监听
  → 等用户指令

用户：「在第三章里插入一张图 C:\图片\结果图.png」
  → AI 复制图片到 .tex 同目录
  → AI 编辑 .tex 插入 figure 环境
  → 用户刷新 PDF 看效果
```

## 依赖

- TeX Live（含 pdflatex + latexmk）
- watch-tex.bat（已上传至 GitHub，与本 skill 同仓库）
- 一个支持运行命令的 AI 工具
