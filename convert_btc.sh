#!/bin/bash

# ================= 配置区域 =================
# A1 原始地址 (GitHub Blob 页面)
SOURCE_URL="https://github.com/oscarquan/2026/blob/main/btc_download.txt"
# A2 输出文件名
OUTPUT_FILE="btc_latest.csv"

# ================= 1. 获取 Raw URL =================
# GitHub 的 blob 页面包含 HTML，我们需要 raw 数据
# 将 'github.com' 替换为 'raw.githubusercontent.com' 并去掉 '/blob'
RAW_URL=$(echo "$SOURCE_URL" | sed 's/github.com/raw.githubusercontent.com/g; s/\/blob//g')

echo "正在从以下地址抓取数据:"
echo "$RAW_URL"
echo "----------------------------------------"

# ================= 2. 准备输出文件 =================
# 写入 A2 要求的标准 CSV 表头
echo "Date,Open,High,Low,Close,Volume" > "$OUTPUT_FILE"

# ================= 3. 下载并处理数据 =================
# 使用 curl 下载数据
# tail -n +2: 跳过第一行 (A1 的原始表头)
# while read: 逐行读取处理
curl -s "$RAW_URL" | tail -n +2 | while read -r line; do
    
    # 如果行尾有回车符或其他空白，先忽略空行
    if [[ -z "$line" ]]; then continue; fi

    # --- 步骤 A: 全局清洗 ---
    # 去掉所有逗号 ","。
    # 原因：A1 的数字里有逗号 (70,109)，日期里也有逗号 (Feb 10,)。
    # A2 要求 CSV 数字无逗号，且日期格式也不需要逗号。
    # 清洗后: "Feb 10 2026 70109.42 70425.13 ..."
    clean_line=$(echo "$line" | sed 's/,//g')

    # --- 步骤 B: 解析变量 ---
    # 利用 read 命令自动按空格分割列
    # 原始列: Date(3部分) Open High Low Close Adj_Close Volume
    # 对应: Month Day Year Open High Low Close Adj Volume
    read -r month day year open high low close adj_close volume <<< "$clean_line"

    # --- 步骤 C: 日期转换 ---
    # 将 "Feb 10 2026" 转换为 "2026-02-10"
    # 使用 date 命令进行格式化
    # 兼容性注意: 这里使用 GNU date (Linux 标准)
    formatted_date=$(date -d "$month $day $year" +"%Y-%m-%d" 2>/dev/null)

    # 检查日期转换是否成功（防止处理到空行或非法行）
    if [[ -z "$formatted_date" ]]; then
        continue
    fi

    # --- 步骤 D: 写入 CSV ---
    # 注意：我们故意忽略了 $adj_close 变量，因为它不在 A2 结构要求中
    echo "$formatted_date,$open,$high,$low,$close,$volume" >> "$OUTPUT_FILE"

done

echo "✅ 转换完成！数据已保存至: $OUTPUT_FILE"
echo "----------------------------------------"
echo "前 5 行预览:"
head -n 5 "$OUTPUT_FILE"
