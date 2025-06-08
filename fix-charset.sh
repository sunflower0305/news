#!/bin/bash

# 修复字符集问题的快速脚本

set -e

echo "🔧 修复 MySQL 字符集问题..."

# 停止所有服务
echo "🛑 停止现有服务..."
docker-compose -f docker-compose.local.yml down

# 清理 MySQL 数据卷
echo "🗑️  清理 MySQL 数据卷..."
docker volume rm news_mysql_data 2>/dev/null || true
docker volume rm news_news_uploads 2>/dev/null || true
docker volume rm news_news_lucene 2>/dev/null || true

# 清理相关容器和镜像
echo "🧹 清理相关资源..."
docker container prune -f
docker image prune -f

# 重新构建应用
echo "🔨 重新构建应用..."
if [ -f "target/news-*.jar" ]; then
    echo "✅ 发现已构建的 JAR 包，直接构建 Docker 镜像"
    ./build-docker.sh
else
    echo "📦 未发现 JAR 包，执行完整构建"
    ./build-local.sh
fi

echo "✅ 修复完成！"
echo ""
echo "💡 接下来可以："
echo "   1. 启动服务: ./manage.sh start"
echo "   2. 测试数据库: ./manage.sh test-db"
echo "   3. 查看日志: ./manage.sh logs"
