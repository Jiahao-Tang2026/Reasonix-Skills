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

## 在新会话中使用 Skill

启动 Reasonix Code 后，Skill 会自动加载。直接说：

- 「帮我改 LaTeX」 → 触发 `latex-helper` 工作流
- 「运行 Deli_AutoResearch」 → 触发长时间自治任务协议

---

## MCP 配置（需在新设备上重新设置）

MCP 配置不能随仓库同步（因为包含 token），需在新设备上重新执行：

```python
add_mcp_server(name: "gh", from_catalog: "github",
    args: ["--token", "你的新GitHub Token"])

add_mcp_server(name: "ppt", transport: "stdio",
    command: "py",
    args: ["D:\Reasonix\MCP\ppt_mcp_server\ppt_mcp_server.py"])
```
