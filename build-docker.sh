#!/bin/bash

# 只构建 Docker 镜像脚本（假设 JAR 包已存在）

set -e

echo "🐳 构建 Docker 镜像..."

# 检查 JAR 文件是否存在
if [ ! -f target/news-*.jar ]; then
    echo "❌ 未找到 JAR 文件！"
    echo "💡 请先运行 ./build-jar.sh 构建 JAR 包"
    exit 1
fi

# 显示 JAR 文件信息
JAR_FILE=$(ls target/news-*.jar)
JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
echo "📄 使用 JAR 文件: $JAR_FILE"
echo "📏 文件大小: $JAR_SIZE"

# 启用 Docker BuildKit
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# 开始构建
start_time=$(date +%s)

docker-compose -f docker-compose.local.yml build news-app

end_time=$(date +%s)
build_time=$((end_time - start_time))

if [ $? -eq 0 ]; then
    echo "✅ Docker 镜像构建成功！"
    
    # 显示镜像信息
    IMAGE_ID=$(docker images news-news-app --format "{{.ID}}" | head -n 1)
    if [ ! -z "$IMAGE_ID" ]; then
        IMAGE_SIZE=$(docker images news-news-app --format "{{.Size}}" | head -n 1)
        echo "🏷️  镜像 ID: $IMAGE_ID"
        echo "📏 镜像大小: $IMAGE_SIZE"
        echo "⏱️  构建时间: ${build_time}秒"
    fi
else
    echo "❌ Docker 镜像构建失败！"
    exit 1
fi
