#!/bin/bash

# 遇到任何错误立即停止执行
set -e

echo "========= 1. 开始拉取最新代码并构建镜像 ========="
git pull

# 构建最新镜像
docker build -t sing-box-subscribe:latest .

echo "========= 2. 检查并清理旧容器 ========="
CONTAINER_NAME="sing-box-subscribe"

# 获取所有匹配的容器 ID
CONTAINER_IDS=$(docker ps -a -q --filter "name=${CONTAINER_NAME}")

if [ -n "$CONTAINER_IDS" ]; then
    echo "发现正在运行或残留的容器，正在批量清理..."
    # 使用 xargs 支持单个或多个容器，-f 强制删除
    echo "$CONTAINER_IDS" | xargs -r docker rm -f
    echo "旧容器清理完毕。"
else
    echo "未发现相关的旧容器，跳过清理步骤。"
fi

echo "========= 3. 启动新容器 ========="
# 💡 优化：强制重新创建容器，避免 docker-compose 缓存旧配置/旧镜像
docker-compose up -d --force-recreate

echo "========= 4. 校验新容器是否启动成功 ========="
echo "等待 5 秒以确保容器稳定运行..."
sleep 5

# 获取容器状态
NEW_CONTAINER_STATUS=$(docker ps -a --filter "name=^/${CONTAINER_NAME}$" --format "{{.State}}" | head -n 1)

if [ "$NEW_CONTAINER_STATUS" = "running" ]; then
    echo "✅ 校验成功：新容器当前状态为 [running]，已成功启动！"
else
    echo "❌ 校验失败：新容器当前状态为 [${NEW_CONTAINER_STATUS:-未知/未找到}]！"
    echo "========= 正在打印最后 20 行容器日志以供排查 ========="
    docker-compose logs --tail=20
    exit 1
fi

echo "========= 更新流程执行完毕！ ========="
