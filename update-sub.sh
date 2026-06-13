#!/bin/bash

# 遇到任何错误立即停止执行
set -e

echo "========= 1. 开始拉取最新代码并构建镜像 ========="
# 拉取最新代码
git pull

# 构建最新镜像
docker build -t sing-box-subscribe:latest .

echo "========= 2. 检查并清理旧容器 ========="
# 定义要检查的容器关键字
CONTAINER_NAME="sing-box-subscribe"

# 1. 获取所有匹配的容器 ID（通过 反引号 或 $() 执行命令）
#    使用 docker ps --filter 可以更优雅地过滤，避免 grep 误伤
CONTAINER_IDS=$(docker ps -a -q --filter "name=${CONTAINER_NAME}")

if [ -n "$CONTAINER_IDS" ]; then
    echo "发现正在运行或残留的容器，正在批量清理..."
    # 2. 使用 xargs 完美支持单个或多个容器，-f 可以直接强制删除（省去 stop 步骤）
    echo "$CONTAINER_IDS" | xargs -r docker rm -f
    echo "旧容器清理完毕。"
else
    echo "未发现相关的旧容器，跳过清理步骤。"
fi

echo "========= 3. 启动新容器 ========="
# 使用 docker-compose 后台启动
docker-compose up -d

echo "========= 更新流程执行完毕！ ========="
