---
name: word-editor
description: Word 实时编辑工具集 — COM实时改文字/插表格/设三线表 + OMML公式注入
---
# Word 实时编辑 Skill

## 前置条件

- **Windows 系统**（需要 COM + pywin32）
- **Word 已打开**你的 doc/docx 文件（必须！COM 操作依赖它）
- Python 包已就绪：`pywin32` + `python-docx` + `lxml`
  ```bash
  py -3.11 -m pip install pywin32 python-docx lxml
  ```

## 检查环境

```python
import win32com.client
app = win32com.client.GetActiveObject("Word.Application")
doc = app.ActiveDocument
print(f"已连接: {doc.Name} ({doc.Paragraphs.Count}段)")
```

如果报错 → "请先在 Word 中打开你的 doc/docx 文件"

---

## 一、COM 实时操作（立即可见）

### 1.1 改文字 / 字体 / 字号
```python
sel = app.Selection
sel.Text = "新内容"
sel.Font.Size = 14
sel.Font.Bold = True
sel.Font.Italic = False
sel.Font.Name = "宋体"
sel.Font.ColorIndex = 0  # 0=wdAuto, 1=wdBlack, 6=wdRed, ...
```

### 1.2 改对齐 / 行距
```python
sel.ParagraphFormat.Alignment = 1   # 1=居中 2=右 3=两端
sel.ParagraphFormat.LineSpacing = 1.5
sel.ParagraphFormat.SpaceBefore = 6
sel.ParagraphFormat.SpaceAfter = 6
```

### 1.3 查找替换
```python
# 全文档查找替换
sel.HomeKey(Unit=6)  # 6=wdStory, 跳到文档开头
sel.Find.Execute("旧文本", ReplaceWith="新文本", Replace=2)  # 2=wdReplaceAll

# 带格式查找
sel.Find.ClearFormatting()
sel.Find.Font.Bold = True
sel.Find.Execute("目标文字", ReplaceWith="替换文字", Replace=2)
```

### 1.4 插入段落
```python
# 在指定段落后插入
p = doc.Paragraphs(34)
p.Range.Select()
sel = app.Selection
sel.EndOf(Unit=5)  # 5=wdParagraph
sel.InsertParagraph()
sel.TypeText("新段落内容")

# 直接在段落后加文字
doc.Paragraphs(10).Range.InsertAfter("\n新增文字")
```

### 1.5 插入分页符
```python
sel.InsertBreak(7)  # 7=wdPageBreak
```

### 1.6 读取段落
```python
for i in range(1, doc.Paragraphs.Count + 1):
    p = doc.Paragraphs(i)
    txt = p.Range.Text[:80].replace("\r","").replace("\n","")
    style = p.Style.NameLocal
    print(f"P{i:3d} [{style:10s}] {txt}")
```

### 1.7 跳转
```python
sel.HomeKey(Unit=6)                   # 跳到文档开头
sel.EndKey(Unit=6)                    # 跳到文档末尾
sel.GoTo(What=1, Which=1, Count=5)   # 跳到第5页 (1=wdGoToPage)
```

### 1.8 保存
```python
doc.Save()
# 或另存
doc.SaveAs("新文件路径.docx", 16)     # 16=wdFormatDocumentDefault (.docx)
doc.SaveAs("新文件路径.pdf", 17)      # 17=wdFormatPDF (.pdf)
```

### 1.9 转换格式
```python
# .doc → .docx
doc.SaveAs("新文件.docx", 16)

# .docx → .doc (兼容模式)
doc.SaveAs("新文件.doc", 0)
```

### 1.10 关闭 / 重开
```python
doc.Close(0)  # 0=不保存
doc.Close(-1) # -1=保存
app.Documents.Open("C:\\path\\to\\file.docx")
```

### 1.11 转 PDF
```python
doc.ExportAsFixedFormat("输出路径.pdf", 17)  # 17=wdExportFormatPDF
```

---

## 二、表格操作（COM）

### 2.1 创建表格
```python
sel.TypeParagraph()
table = doc.Tables.Add(sel.Range, 5, 4)  # 5行4列

# 填入数据
for i in range(1, 6):
    for j in range(1, 5):
        table.Cell(i, j).Range.Text = f"({i},{j})"
```

### 2.2 三线表边框（学术表格标准）
```python
# ===== 清空所有边框 =====
for bi in range(1, 13):
    try: table.Borders(bi).LineStyle = 0
    except: pass

# ===== 去掉竖线 =====
table.Borders(2).LineStyle = 0   # 左
table.Borders(4).LineStyle = 0   # 右
table.Borders(6).LineStyle = 0   # 内竖线

# ===== 表头底线（细）=====
table.Rows(1).Borders(3).LineStyle = 1    # wdLineStyleSingle
table.Rows(1).Borders(3).LineWidth = 4     # 0.5pt

# ===== 组间分隔线（如有）=====
for group_row in [6, 10, 14]:             # 每组第一行号
    table.Rows(group_row).Borders(1).LineStyle = 1
    table.Rows(group_row).Borders(1).LineWidth = 4

# ===== 顶线（粗） + 底线（细）=====
table.Borders(1).LineStyle = 1            # 顶
table.Borders(1).LineWidth = 12           # 1.5pt
table.Borders(3).LineStyle = 1            # 底
table.Borders(3).LineWidth = 4            # 0.5pt
```

### 2.3 表头灰底
```python
for j in range(1, table.Columns.Count + 1):
    table.Cell(1, j).Shading.BackgroundPatternColor = 14277081  # 浅灰
```

### 2.4 合并单元格
```python
table.Cell(1, 1).Merge(table.Cell(1, 3))  # 合并第1行1-3列
```

### 2.5 调整列宽
```python
table.Columns(1).Width = 60   # 单位: 磅 (point)
table.Columns(2).Width = 120
table.AutoFitBehavior(1)      # 1=wdAutoFitFixed 2=wdAutoFitContent 3=wdAutoFitWindow
```

### 2.6 读写单元格
```python
cell = table.Cell(2, 3)
cell.Range.Text = "值"
cell.Range.Font.Size = 9
cell.Range.Font.Bold = True
cell.Range.ParagraphFormat.Alignment = 1  # 居中
```

### 2.7 删除表格
```python
while doc.Tables.Count > 0:
    doc.Tables(1).Delete()
```

---

## 三、OMML 公式注入（需重载）

COM 无法直接创建公式，需要用 python-docx + lxml 注入 OMML XML。

### 3.1 通用公式注入流程

```python
import win32com.client, tempfile, os
from docx import Document
from lxml import etree

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
M = '{http://schemas.openxmlformats.org/officeDocument/2006/math}'

# 命名空间前缀
nsW = W
nsM = M

def mr(text, italic=True):
    """创建数学运行 (math run)"""
    r = etree.Element(nsM + 'r')
    if italic:
        rPr = etree.SubElement(r, nsM + 'rPr')
        rPr.set(nsM + 'sty', 'p')
    t = etree.SubElement(r, nsM + 't')
    t.text = text
    return r

def msub(base_text, sub_text):
    """下标: base_sub"""
    s = etree.Element(nsM + 'sSub')
    e = etree.SubElement(s, nsM + 'e')
    e.append(mr(base_text, italic=True))
    sub = etree.SubElement(s, nsM + 'sub')
    sub.append(mr(sub_text, italic=False))
    return s

def msup(base_text, sup_text):
    """上标: base^sup"""
    s = etree.Element(nsM + 'sSup')
    e = etree.SubElement(s, nsM + 'e')
    e.append(mr(base_text, italic=True))
    sup = etree.SubElement(s, nsM + 'sup')
    sup.append(mr(sup_text, italic=False))
    return s

def msubsup(base_text, sub_text, sup_text):
    """上下标: base^sup_sub"""
    s = etree.Element(nsM + 'sSubSup')
    e = etree.SubElement(s, nsM + 'e')
    e.append(mr(base_text, italic=True))
    sub = etree.SubElement(s, nsM + 'sub')
    sub.append(mr(sub_text, italic=False))
    sup = etree.SubElement(s, nsM + 'sup')
    sup.append(mr(sup_text, italic=False))
    return s

def mfrac(num_els, den_els):
    """分数: num/den"""
    f = etree.Element(nsM + 'f')
    num = etree.SubElement(f, nsM + 'num')
    for el in num_els: num.append(el)
    den = etree.SubElement(f, nsM + 'den')
    for el in den_els: den.append(el)
    return f

def mdelim(inner_els, beg='(', end=')'):
    """定界符: (inner)"""
    d = etree.Element(nsM + 'd')
    dPr = etree.SubElement(d, nsM + 'dPr')
    etree.SubElement(dPr, nsM + 'begChr').set(nsM + 'val', beg)
    etree.SubElement(dPr, nsM + 'endChr').set(nsM + 'val', end)
    e = etree.SubElement(d, nsM + 'e')
    for el in inner_els: e.append(el)
    return d

def macc(base_text, accent_char='\u02c6'):
    """重音: â (ˆ=circumflex, ¯=macron)"""
    a = etree.Element(nsM + 'acc')
    aPr = etree.SubElement(a, nsM + 'accPr')
    chr_el = etree.SubElement(aPr, nsM + 'chr')
    chr_el.set(nsM + 'val', accent_char)
    e = etree.SubElement(a, nsM + 'e')
    e.append(mr(base_text, italic=True))
    return a

def inject_omath_into_para(para_element, oMath_elements, align='center'):
    """
    把 OMML 公式注入到一个段落元素里
    
    Args:
        para_element: w:p 元素 (python-docx paragraph._element)
        oMath_elements: [m:oMath element, ...] 列表
        align: 'center' 或 'left'
    """
    new_p = etree.SubElement(para_element.getparent(), nsW + 'p')
    para_element.addprevious(new_p)
    
    pPr = etree.SubElement(new_p, nsW + 'pPr')
    if align == 'center':
        jc = etree.SubElement(pPr, nsW + 'jc')
        jc.set(nsW + 'val', 'center')
    
    r = etree.SubElement(new_p, nsW + 'r')
    rPr = etree.SubElement(r, nsW + 'rPr')
    rFonts = etree.SubElement(rPr, nsW + 'rFonts')
    rFonts.set(nsW + 'ascii', 'Cambria Math')
    rFonts.set(nsW + 'hAnsi', 'Cambria Math')
    
    obj = etree.SubElement(r, nsW + 'object')
    obj.set(nsW + 'dxaOrig', '1200')
    obj.set(nsW + 'dyaOrig', '240')
    math_w = etree.SubElement(obj, nsW + 'Math')
    
    for om in oMath_elements:
        omp = etree.SubElement(math_w, nsM + 'oMathPara')
        omppr = etree.SubElement(omp, nsM + 'oMathParaPr')
        omp.append(om)
```

### 3.2 完整示例：注入欧拉公式

```python
import win32com.client, tempfile, os
from docx import Document
from lxml import etree

DOCX_PATH = r"临时文件路径.docx"
ORIG_DOC = r"原始文件路径.doc"

# 命名空间
W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
M = '{http://schemas.openxmlformats.org/officeDocument/2006/math}'

def mr(t, italic=True):
    r = etree.Element(M + 'r')
    if italic:
        rPr = etree.SubElement(r, M + 'rPr')
        rPr.set(M + 'sty', 'p')
    etree.SubElement(r, M + 't').text = t
    return r

def msup(base_el, sup_text):
    s = etree.Element(M + 'sSup')
    e = etree.SubElement(s, M + 'e'); e.append(base_el)
    sup = etree.SubElement(s, M + 'sup'); sup.append(mr(sup_text))
    return s

def msub(base_text, sub_text):
    s = etree.Element(M + 'sSub')
    e = etree.SubElement(s, M + 'e'); e.append(mr(base_text, True))
    sub = etree.SubElement(s, M + 'sub'); sub.append(mr(sub_text, False))
    return s

# Step 1: COM → 转 docx
app = win32com.client.GetActiveObject('Word.Application')
doc = app.ActiveDocument
doc.SaveAs(DOCX_PATH, 16)  # 16 = .docx
doc.Close()

# Step 2: python-docx → 注入 OMML
prs = Document(DOCX_PATH)
target_para = prs.paragraphs[34]  # 0-based

# 构造 e^(iπ)+1=0
oMath = etree.Element(M + 'oMath')
oMath.append(msup(mr('e'), 'iπ'))
for ch in ['+', '1', '=', '0']:
    oMath.append(mr(ch, False))

# 包装进段落
new_p = etree.Element(W + 'p')
pPr = etree.SubElement(new_p, W + 'pPr')
jc = etree.SubElement(pPr, W + 'jc'); jc.set(W + 'val', 'center')
r = etree.SubElement(new_p, W + 'r')
rPr = etree.SubElement(r, W + 'rPr')
rFonts = etree.SubElement(rPr, W + 'rFonts')
rFonts.set(W + 'ascii', 'Cambria Math')
rFonts.set(W + 'hAnsi', 'Cambria Math')
obj = etree.SubElement(r, W + 'object')
obj.set(W + 'dxaOrig', '2400'); obj.set(W + 'dyaOrig', '240')
math_w = etree.SubElement(obj, W + 'Math')
omp = etree.SubElement(math_w, M + 'oMathPara')
omppr = etree.SubElement(omp, M + 'oMathParaPr')
omp.append(oMath)

# 插入到目标段落之前
target_para._element.addprevious(new_p)

# Step 3: 保存并重载
prs.save(DOCX_PATH)
app.Documents.Open(DOCX_PATH)
print("✅ 公式已注入")
```

### 3.3 表格头公式注入

```python
from docx import Document
prs = Document(DOCX_PATH)
tbl = prs.tables[0]

for col_idx, om in enumerate([h1, h2, h3, ...]):  # oMath 元素列表
    cell = tbl.cell(0, col_idx)
    tc = cell._tc
    # 清空原文本
    for p in list(tc.findall(W + 'p')):
        tc.remove(p)
    # 新建段落 + OMML
    new_p = etree.SubElement(tc, W + 'p')
    pPr = etree.SubElement(new_p, W + 'pPr')
    jc = etree.SubElement(pPr, W + 'jc'); jc.set(W + 'val', 'center')
    r = etree.SubElement(new_p, W + 'r')
    rPr = etree.SubElement(r, W + 'rPr')
    rFonts = etree.SubElement(rPr, W + 'rFonts')
    rFonts.set(W + 'ascii', 'Cambria Math')
    rFonts.set(W + 'hAnsi', 'Cambria Math')
    obj = etree.SubElement(r, W + 'object')
    obj.set(W + 'dxaOrig', '800'); obj.set(W + 'dyaOrig', '200')
    math_w = etree.SubElement(obj, W + 'Math')
    omp = etree.SubElement(math_w, M + 'oMathPara')
    omppr = etree.SubElement(omp, M + 'oMathParaPr')
    omp.append(om)

prs.save(DOCX_PATH)
```

---

## 四、OMML 公式模板

| 公式 | OMML 构造 |
|------|-----------|
| `e^(iπ)+1=0` | `msup(mr('e'), 'iπ')` + `mr('+1=0')` |
| `γₙ` | `msub('γ', 'n')` |
| `C₁` | `msub('C', '1')` |
| `η̂` | `macc('η', '\u02c6')` (hat) |
| `n̄*` | `sSup(acc:'n', sup:'*')` |
| `n*_true` | `msubsup('n', 'true', '*')` |
| `Pr₁` | `msub('Pr', '1')` |
| `σ²` | `msup('σ', '2')` |
| `ẑ₀` | `msub(macc('z'), '0')` |
| `ℝ` | `mr('ℝ', italic=False)` (blackboard R U+211D) |
| `𝔼[y]` | `mr('𝔼')` + `mdelim([mr('y')])` |
| `\frac{a}{b}` | `mfrac([mr('a')], [mr('b')])` |
| `\binom{n}{k}` | 用 `mfrac(n, k)` 不加分数线 (OMML 无直接二项式) |

---

## 五、完整工作流模板

```python
import win32com.client

app = win32com.client.GetActiveObject('Word.Application')
doc = app.ActiveDocument

# === 实时操作 ===
# 改文字
doc.Paragraphs(1).Range.Text = "新标题"
doc.Paragraphs(1).Range.Font.Size = 18
doc.Paragraphs(1).Range.Font.Bold = True

# 插入段落
doc.Paragraphs(5).Range.InsertAfter("\n新插入的文字")

# 创建表格
table = doc.Tables.Add(doc.Paragraphs(10).Range, 5, 3)

# 设三线表
# ...（复制 2.2 节代码）

# 保存
doc.Save()

# === 注入公式（用第三/四节代码）===
# ...（复制 3.2 或 3.3 节代码）
```

---

## 六、常用命令速查

| 操作 | 是否实时 | 代码 |
|------|---------|------|
| 改文字 | ✅ | `sel.Text = "新文字"` |
| 改字号 | ✅ | `sel.Font.Size = 14` |
| 改字体 | ✅ | `sel.Font.Name = "宋体"` |
| 加粗/斜体 | ✅ | `sel.Font.Bold = True` |
| 颜色 | ✅ | `sel.Font.ColorIndex = 6` |
| 查找替换 | ✅ | `sel.Find.Execute("旧","新", Replace=2)` |
| 居中 | ✅ | `sel.ParagraphFormat.Alignment = 1` |
| 插入段落 | ✅ | `sel.InsertParagraph()` / `Range.InsertAfter("...")` |
| 插入分页 | ✅ | `sel.InsertBreak(7)` |
| 创建表格 | ✅ | `doc.Tables.Add(range, rows, cols)` |
| 三线表边框 | ✅ | COM 行边框 + 表边框（见 2.2） |
| 写单元格 | ✅ | `table.Cell(r,c).Range.Text = "值"` |
| 表头灰底 | ✅ | `cell.Shading.BackgroundPatternColor = 14277081` |
| 合并单元格 | ✅ | `cell1.Merge(cell2)` |
| 转 PDF | ✅ | `doc.ExportAsFixedFormat(path, 17)` |
| 保存 | ✅ | `doc.Save()` |
| 注入公式 | ~2秒 | python-docx + lxml OMML（见第三/四节） |
