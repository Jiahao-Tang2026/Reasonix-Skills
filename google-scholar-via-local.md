# Google Scholar 检索方法（通过本地网络 + VPN）

通过 Reasonix 的 `run_command` 在用户本地机器执行 Python，走用户的网络连接访问 Google Scholar。

## 前置条件

- 用户需**开启 VPN**（让本地网络能访问 Google Scholar）
- `scholarly` 库已安装：`pip install scholarly`

## 使用方法

在会话中通过 `run_command` 执行 Python 脚本：

```python
from scholarly import scholarly
search = scholarly.search_pubs('查询关键词')
for i, pub in enumerate(search):
    if i >= 5: break
    print(f'标题: {pub["bib"]["title"]}')
    print(f'作者: {pub["bib"].get("author","?")}')
    print(f'年份: {pub["bib"].get("pub_year","?")}')
    print(f'链接: {pub.get("pub_url","?")}')
```

## 替代方案（无需 VPN）

arxiv API 走本地网络，不受限：

```python
import arxiv
client = arxiv.Client()
search = arxiv.Search(query='关键词', max_results=5)
for r in client.results(search):
    print(r.title)
    print(f'  https://arxiv.org/abs/{r.get_short_id()}')
```

## 原理

`run_command` 在用户本地机器执行，走用户的网络连接。VPN 开在用户机器上，所以请求经由 VPN 到达 Google Scholar。
