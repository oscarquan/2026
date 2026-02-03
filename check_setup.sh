#!/bin/bash

echo "🔍 AI协作工作流检查报告"
echo "================================"

# 1. 分支检查
echo ""
echo "1. 分支状态:"
git branch -a
echo ""

# 2. 提交历史
echo "2. 最近提交:"
git log --oneline --graph --all -5
echo ""

# 3. 文件状态
echo "3. 工作流文件:"
if [ -d ".github/workflows" ]; then
    ls -la .github/workflows/
    echo "文件数量: $(ls .github/workflows/*.yml 2>/dev/null | wc -l)"
else
    echo "❌ .github/workflows/ 目录不存在"
fi
echo ""

# 4. 保护规则检查
echo "4. 分支保护状态:"
if command -v gh &> /dev/null; then
    gh api repos/oscarquan/2026/branches/main/protection 2>/dev/null | grep -E '(protected|required_pull_request_reviews)' || echo "⚠️ 无法获取保护状态"
else
    echo "⚠️ GitHub CLI未安装，使用curl检查:"
    curl -s https://api.github.com/repos/oscarquan/2026/branches/main/protection 2>/dev/null | grep -E '"protected"|"required"' || echo "需要令牌访问"
fi
echo ""

# 5. 目录结构
echo "5. 项目结构:"
find . -maxdepth 2 -type f -name "*.md" -o -name "*.yml" -o -name "*.py" | sort
echo ""

echo "📊 检查完成!"
echo "请访问: https://github.com/oscarquan/2026/actions 查看工作流"
echo "请访问: https://github.com/oscarquan/2026/settings/branches 查看分支保护"
