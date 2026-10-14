import os
import subprocess
import sys

from openai import OpenAI

MAX_DIFF_CHARS = 60000

def get_diff():
    base = os.environ["BASE_SHA"]
    head = os.environ["HEAD_SHA"]
    out = subprocess.run(
        ["git", "diff", f"{base}...{head}", "--unified=3"],
        capture_output=True,
        text=True,
        check=True,
    )
    return out.stdout

def review(diff):
    client = OpenAI(
        api_key=os.environ["ARK_API_KEY"],
        base_url="https://ark.cn-beijing.volces.com/api/v3",
    )
    model = os.environ["ARK_MODEL_ID"]
    prompt = (
        "你是资深代码审查员。请审查下面的 Pull Request diff，用简体中文输出 markdown 格式审查意见，"
        "包含：1) 总体评价；2) 潜在问题（按严重程度排序，标注文件名和行号）；3) 修改建议。"
        "只报告真正有价值的问题，不要泛泛而谈。\n\n```diff\n"
        + diff[:MAX_DIFF_CHARS]
        + "\n```"
    )
    resp = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3,
    )
    return resp.choices[0].message.content

def main():
    if not os.environ.get("ARK_API_KEY") or not os.environ.get("ARK_MODEL_ID"):
        print("未配置 ARK_API_KEY / ARK_MODEL_ID，请先在仓库 Settings → Secrets and variables → Actions 中添加。")
        sys.exit(1)
    diff = get_diff()
    if not diff.strip():
        print("本次 PR 没有代码改动。")
        return
    print(review(diff))

if __name__ == "__main__":
    main()
