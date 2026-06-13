#!/bin/bash

# 遇到任何错误立即停止执行
set -e

echo "========= 1. 开始拉取最新代码并构建镜像 ========="
# [cite: 1] 拉取最新代码
git pull [cite: 1]

# [cite: 1] 构建最新镜像
docker build -t sing-box-subscribe:latest . [cite: 1]

echo "========= 2. 检查并清理旧容器 ========="
# 定义要检查的容器关键字
CONTAINER_NAME="sing-box-subscribe"

# [cite: 1] 查找包含关键字的容器 ID
# 这里做了解析优化，确保只有在容器存在时才执行删除，避免报错
CONTAINER_IDS=$(docker ps -a | grep "$CONTAINER_NAME" | awk '{print $1}') [cite: 1]

if [ -n "$CONTAINER_IDS" ]; then
    echo "发现正在运行或残留的容器，正在停止并删除..."
    # 停止旧容器
    docker stop $CONTAINER_IDS
    # 删除旧容器
    docker rm $CONTAINER_IDS
    echo "旧容器清理完毕。"
else
    echo "未发现相关的旧容器，跳过清理步骤。"
fi

echo "========= 3. 启动新容器 ========="
# [cite: 1] 使用 docker-compose 后台启动
docker-compose up -d [cite: 1]

echo "========= 更新流程执行完毕！ ========="
