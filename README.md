# Reasonix-Skills

Reasonix Code 的自定义 skill 和工具脚本集合。

---

## 新设备快速配置

### 1. 装 Reasonix Code

按照 Reasonix 官方指南安装。

### 2. 装 TeX Live（如果需要 LaTeX 实时编译）

从 https://tug.org/texlive/ 下载安装，确保 `pdflatex` 和 `latexmk` 在系统 PATH 中。

### 3. 克隆这个仓库

```bash
git clone https://github.com/Jiahao-Tang2026/Reasonix-Skills.git
cd Reasonix-Skills
```

### 4. 安装 Skill 文件

把 `.md` 文件复制到 Reasonix 的全局 skills 目录：

```bash
# Windows
copy *.md %USERPROFILE%\.reasonix\skills
# macOS / Linux
cp *.md ~/.reasonix/skills/
```

### 5. 可选：设置 watch-tex.bat（Windows 专用）

```bash
mkdir D:\Reasonix
copy watch-tex.bat D:\Reasonix```

然后把 `D:\Reasonix` 添加到系统 PATH 中，即可在任意目录运行：

```bash
watch-tex.bat 论文.tex
```

---

## 仓库内容

| 文件 | 类型 | 作用 |
|------|------|------|
| `Deli_AutoResearch.md` | Skill | 长时间自治任务协议框架（状态管理、停滞检测、心跳看门狗） |
| `latex-helper.md` | Skill | LaTeX 实时编辑协作工作流（编辑、插图片、自动编译） |
| `watch-tex.bat` | 脚本 | LaTeX 实时编译监听工具（`latexmk -pvc` 封装） |

---

## 在其他智能体中使用

### 如果你的智能体也用 \`.md\` 文件做 skill

`.md` 文件里有两个部分需要处理：

**① 头部 frontmatter（\`---\` 之间的内容）**

Reasonix 专有字段如 \`runAs\`、\`scope\` 其他智能体不识别，建议**直接去掉整个 frontmatter**，只保留 \`# 标题\` 往后的正文。

**② 正文中的工具调用**

Reasonix 特有的工具名（\`read_file\`、\`edit_file\`、\`run_background\`、\`shutil.copy2()\` 等）需要映射成你所用智能体的等效工具。例如：

| Reasonix | 通用含义 | 其他智能体可能叫法 |
|----------|---------|-------------------|
| \`read_file\` | 读取文件内容 | \`read\`、\`view\`、\`cat\` |
| \`edit_file\` | 替换文件中的一段文本 | \`edit\`、\`replace\`、\`patch\` |
| \`run_background\` | 后台启动进程 | \`run\`、\`execute\`、\`shell\` |
| \`shutil.copy2()\` | 复制文件 | 通常直接用 \`cp\` 或 \`copy\` 命令 |

**手动适配示例：**

直接把 \`latex-helper.md\` 的正文（去掉 frontmatter）作为提示词喂给你的智能体，然后把里面的工具名替换成你用的。例如：

> 原句：\`用 read_file 定位要改的段落\`
>
> 替换为：\`用 <你的工具名> 定位要改的段落\`

### 如果智能体不需要 .md，只认纯文本提示词

直接把 \`# 标题\` 往后的 markdown 正文复制出来作为系统提示词即可，frontmatter 不需要。

### watch-tex.bat 是通用的

这个脚本不依赖任何智能体，任何终端都能直接跑：

```bash
watch-tex.bat my_paper.tex
```

---

## 在新会话中使用 Skill（仅限 Reasonix Code）

启动 Reasonix Code 后，Skill 会自动加载。直接说：

- 「帮我改 LaTeX」 → 触发 \`latex-helper\` 工作流
- 「运行 Deli_AutoResearch」 → 触发长时间自治任务协议

---

## MCP 配置（需在新设备上重新设置）

MCP 配置不能随仓库同步（因为包含 token），需在新设备上重新执行：

```python
add_mcp_server(name: "gh", from_catalog: "github",
    args: ["--token", "你的新GitHub Token"])

add_mcp_server(name: "ppt", transport: "stdio",
    command: "py",
    args: ["D:\\Reasonix\\MCP\\ppt_mcp_server\\ppt_mcp_server.py"])
```
