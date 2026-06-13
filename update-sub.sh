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

if [ -n "$CONTAINER_IDS" ]; then
    echo "发现正在运行或残留的容器，正在删除..."
docker ps -a | grep "$CONTAINER_NAME" | awk '{print $1}' | xargs  docker rm -f
    echo "旧容器清理完毕。"
else
    echo "未发现相关的旧容器，跳过清理步骤。"
fi

echo "========= 3. 启动新容器 ========="
# 使用 docker-compose 后台启动
docker-compose up -d

echo "========= 更新流程执行完毕！ ========="
