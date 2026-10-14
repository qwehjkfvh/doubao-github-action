# 豆包 AI 代码审查（GitHub Actions）

每次提交或更新 Pull Request 时，自动调用豆包（火山方舟）大模型审查代码，并在 PR 下评论。

## 一、获取豆包 API 凭证

1. 打开 [火山方舟控制台](https://console.volcengine.com/ark) 并注册/登录。
2. 「开通服务」后进入「在线推理」→「推理接入点」，创建一个推理接入点（模型选 doubao-seed-1.6 或 doubao-pro 系列均可）。
3. 复制接入点 ID（形如 `ep-2025xxxxxxxxxx`）。
4. 「API Key 管理」中创建一个 API Key 并复制。

## 二、配置 GitHub Secrets

在你的 GitHub 仓库 → **Settings → Secrets and variables → Actions → New repository secret**，添加两个：

| Secret 名 | 值 |
|---|---|
| `ARK_API_KEY` | 你的火山方舟 API Key |
| `ARK_MODEL_ID` | 推理接入点 ID（`ep-xxxx`） |

## 三、把文件放进仓库

保持以下结构：

```
.github/workflows/doubao-pr-review.yml
scripts/doubao_review.py
scripts/requirements.txt
```

如果本地还没有 GitHub 仓库：

```bash
git init
git add .
git commit -m "add doubao PR review action"
gh repo create <你的仓库名> --public --source=. --push
```

如果已经有远程仓库，直接：

```bash
git add .
git commit -m "add doubao PR review action"
git push
```

## 四、验证

新建一个 Pull Request，几十秒后 PR 页面会出现「🤖 豆包代码审查」评论。可在仓库 **Actions** 页查看运行日志。

## 常见问题

- **评论没出现**：检查 Action 是否报红，通常是两个 Secret 没配或填错；接入点 ID 是 `ep-` 开头，不是模型名字。
- **diff 太大**：脚本对单次 diff 截断到 60000 字符，避免超 token。
- **想改审查风格**：编辑 `scripts/doubao_review.py` 里的 prompt 即可。
