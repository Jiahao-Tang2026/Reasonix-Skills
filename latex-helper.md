---
name: latex-helper
description: LaTeX real-time editing workflow — watch, edit, insert images, auto-compile
---

# latex-helper

LaTeX 实时编辑协作工作流。支持实时监听编译 + 离线编译（保证 SyncTeX 反向跳转）。

## 编译命令（保证 TeXstudio Ctrl+左键可用）

### 方式一：完整编译（改完后用）
```bash
del /f *.synctex.gz 2>nul && chcp 65001 && pdflatex -interaction=nonstopmode -synctex=1 <file>.tex && bibtex <file> && pdflatex -interaction=nonstopmode -synctex=1 <file>.tex && pdflatex -interaction=nonstopmode -synctex=1 <file>.tex
```

### 方式二：实时监听（编辑时用）
```bash
latexmk -pvc -pdf -interaction=nonstopmode <file>.tex
```

## 为什么用方式一编译？
- **中文路径问题**：Windows 中文目录（如 `唐家浩/泛化误差tex`）在默认编码下写入 `.synctex.gz` 会乱码，导致 TeXstudio 无法反向跳转
- `del *.synctex.gz`：删除旧的 SyncTeX，强制重新生成
- `chcp 65001`：切到 UTF-8 编码，确保中文路径正确写入 `.synctex.gz`
- `-synctex=1`：显式启用 SyncTeX
- 完整链 pdflatex → bibtex → pdflatex × 2：确保交叉引用和文献正确

## 如果用户反馈 Ctrl+左键不工作
告知用户在 TeXstudio 中按一次 F5（自己编译一次），此后外部编译的 PDF 也能正常跳转。

## 编辑流程
1. 用 `read_file` 定位要改的段落
2. 用 `edit_file` / `multi_edit` 修改
3. 用上述**方式一**完整编译
4. 告知用户刷新 PDF

## 插入图片
1. 找到图片文件路径
2. 复制到 `.tex` 同目录（文件名简短英文）
3. 插入 figure 环境：
```latex
egin{figure}[htbp]
    \centering
    \includegraphics[width=0.8	extwidth]{filename.png}
    \caption{说明}
    \label{fig:label}
\end{figure}
```

## 依赖
- TeX Live 2025（pdflatex + latexmk + bibtex）
- Windows 系统
