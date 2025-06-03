#!/bin/sh

# 脚本：下载 Redis 7.4 的 redis.conf 文件，并移除注释和空行。

# 确保在命令失败时脚本会退出
set -e

# Redis 配置文件的 URL
REDIS_CONF_URL="https://raw.githubusercontent.com/redis/redis/7.4/redis.conf"

echo "# 下载配置文件并处理中，来源: ${REDIS_CONF_URL}" >&2
echo "# (以下为无注释和无空行的配置内容)" >&2
echo "" >&2

# 使用 wget 下载文件内容到标准输出，然后通过 sed 处理：
# 1. 删除以可选空格开头的 '#' 注释行
# 2. 删除只包含可选空格的空行
wget -O - "${REDIS_CONF_URL}" 2>/dev/null | sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' > redis.default.conf

echo "" >&2
echo "# 处理完成。" >&2