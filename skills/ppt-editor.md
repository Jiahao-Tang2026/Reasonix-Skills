---
name: ppt-editor
description: PowerPoint 实时编辑工具集 — COM实时改文字/插图片/调排版 + 2秒OMML公式注入
---
# PPT 实时编辑 Skill

## 前置条件

- **Windows 系统**（需要 COM + pywin32）
- **PowerPoint 已打开**你的 pptx 文件（必须！所有操作依赖它）
- Python 包已就绪：`pywin32` + `python-pptx` + `lxml`
  ```bash
  py -3.11 -m pip install pywin32 python-pptx lxml
  ```

## 检查环境

```python
import win32com.client
app = win32com.client.GetActiveObject("PowerPoint.Application")
pres = app.ActivePresentation
print(f"已连接: {pres.Name} ({pres.Slides.Count}页)")
```

如果报错 → "请先在 PowerPoint 中打开你的 pptx 文件"

---

## 一、COM 实时操作（立即可见）

### 1.1 改文字
```python
slide = pres.Slides(3)
shape = slide.Shapes(2)  # 形状索引从1开始
shape.TextFrame.TextRange.Text = "新标题"
```

### 1.2 改字体/字号/对齐
```python
font = shape.TextFrame.TextRange.Font
font.Size = 30
font.Bold = True
font.Name = "微软雅黑"
shape.TextFrame.TextRange.ParagraphFormat.Alignment = 2  # 1左 2中 3右
```

### 1.3 加文本框
```python
s = slide.Shapes.AddTextbox(1, 50, 50, 400, 60)
s.TextFrame.TextRange.Text = "实时添加的文字"
s.TextFrame.TextRange.Font.Size = 18
```

### 1.4 插图片（实时！）
```python
slide = pres.Slides(3)
pic = slide.Shapes.AddPicture("C:\\path\\to\\image.png", False, True, 50, 50, -1, -1)
# 调大小
pic.Width = 500
pic.Height = int(pic.Height * 500 / pic.Width)  # 等比例
```

### 1.5 新增/复制页
```python
pres.Slides.Add(4, 12)            # 第4位新增空白页 (12=Blank)
pres.Slides(3).Duplicate()        # 复制第3页
```

### 1.6 删除形状
```python
slide.Shapes(3).Delete()
```

### 1.7 浏览所有页
```python
for i in range(1, pres.Slides.Count + 1):
    slide = pres.Slides(i)
    texts = []
    for s in slide.Shapes:
        if s.HasTextFrame:
            t = s.TextFrame.TextRange.Text[:40].replace('\n',' | ')
            if t.strip(): texts.append(t)
    print(f"第{i:2d}页: {' | '.join(texts[:2])[:80]}")
```

### 1.8 保存
```python
pres.Save()
# 或另存
pres.SaveAs("新文件路径.pptx")
```

---

## 二、OMML 公式注入（~2秒，需重载）

COM 无法直接创建公式，需要用 python-pptx 注入 OMML XML：

```python
import tempfile, os
from pptx import Presentation
from lxml import etree

# 命名空间
A = '{http://schemas.openxmlformats.org/drawingml/2006/main'
P = '{http://schemas.openxmlformats.org/presentationml/2006/main'
A14 = '{http://schemas.microsoft.com/office/drawing/2010/main'
M = '{http://schemas.openxmlformats.org/officeDocument/2006/math'

# 1. COM 保存当前状态
pres.Save()
path = pres.FullName

# 2. python-pptx 打开
prs = Presentation(path)
root = prs.slides[2]._element  # 第3页 (0-based)

# 3. 找到文本框并注入
#    找最后一个非Rectangle的sp
all_sps = [el for el in root.iter() if el.tag == P + '}sp']
for sp in reversed(all_sps):
    name = ''
    for c in sp.iter():
        if c.tag.split('}')[-1] == 'cNvPr':
            name = c.get('name',''); break
    if 'Rectangle' in name: continue
    txBody = None
    for c in sp.iter():
        if c.tag.split('}')[-1] == 'txBody':
            txBody = c; break
    if txBody is None: continue

    # 构造 OMML 公式
    oMath = etree.Element(M + '}oMath')
    # e^(iπ)+1=0 示例
    r = etree.SubElement(oMath, M + '}r')
    rPr = etree.SubElement(r, A + '}rPr'); rPr.set('i','1')
    etree.SubElement(r, M + '}t').text = 'e'

    sSup = etree.SubElement(oMath, M + '}sSup')
    etree.SubElement(sSup, M + '}e').text = ''
    sup = etree.SubElement(sSup, M + '}sup')
    rs = etree.SubElement(sup, M + '}r')
    rp = etree.SubElement(rs, A + '}rPr'); rp.set('i','1')
    etree.SubElement(rs, M + '}t').text = 'iπ'

    for ch in ['+','1','=','0']:
        r2 = etree.SubElement(oMath, M + '}r')
        etree.SubElement(r2, M + '}t').text = ch

    # 包装进段落
    new_p = etree.Element(A + '}p')
    pPr = etree.SubElement(new_p, A + '}pPr')
    a14m = etree.SubElement(new_p, A14 + '}m')
    oMP = etree.SubElement(a14m, M + '}oMathPara')
    oMPPr = etree.SubElement(oMP, M + '}oMathParaPr')
    jc = etree.SubElement(oMPPr, M + '}jc')
    jc.set(M + '}val', 'centerGroup')
    oMP.append(oMath)
    txBody.append(new_p)
    break

# 4. 保存到临时文件并重载
tmp = tempfile.NamedTemporaryFile(suffix='.pptx', delete=False)
tmp.close()
prs.save(tmp.name)
app.Presentations.Open(tmp.name)
pres.Close()
os.unlink(tmp.name)
print("✅ 公式已注入（窗口会闪一下）")
```

### 内置公式模板

| 公式 | 构造要点 |
|------|---------|
| `e^(iπ)+1=0` | `r:e` + `sSup(base:'' sup:'iπ')` + `r:+ 1 = 0` |
| `‖β‖²` | `r:‖β‖²` 直接文本 |
| `E[y_i y_j x_i^T x_j]` | `sub:y/i` + `sub:y/j` + `subsup:x/i/T` + `sub:x/j` |
| `L(N,D)=[(N_C/N)^{α_N}+D_C/D]^{α_D}` | `sup:α_N` + `sup:α_D` |
| `x²` | `sSup(base:'' sup:2')` |

---

## 三、完整工作流模板

```python
import win32com.client

app = win32com.client.GetActiveObject('PowerPoint.Application')
pres = app.ActivePresentation
app.Visible = True

# === 实时操作 ===
# 改文字
pres.Slides(1).Shapes(1).TextFrame.TextRange.Text = "新标题"
# 加图片
pres.Slides(3).Shapes.AddPicture(r"C:\img.png", False, True, 50, 50, 400, 300)
# 新增页
pres.Slides.Add(4, 12)
# 保存
pres.Save()

# === 注入公式（用上面的注入代码）===
# ...（复制第二部分代码）
```

---

## 四、常用命令速查

| 操作 | 是否实时 | 代码 |
|------|---------|------|
| 改文字 | ✅ | `shape.TextFrame.TextRange.Text = "新文字"` |
| 改字号 | ✅ | `font.Size = 30` |
| 居中 | ✅ | `ParaFormat.Alignment = 2` |
| 插图片 | ✅ | `slide.Shapes.AddPicture(path, False, True, l, t, w, h)` |
| 加文本框 | ✅ | `slide.Shapes.AddTextbox(1, l, t, w, h)` |
| 增删页 | ✅ | `pres.Slides.Add(idx, 12)` / `slide.Delete()` |
| 复制页 | ✅ | `pres.Slides(n).Duplicate()` |
| 注入公式 | ~2秒 | python-pptx OMML XML（见第二部分） |
