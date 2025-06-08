#!/bin/bash

# MySQL 8.0 问题修复脚本

set -e

echo "🔧 修复 MySQL 8.0 兼容性问题..."

# 停止所有服务
echo "🛑 停止现有服务..."
docker-compose -f docker-compose.local.yml down 2>/dev/null || true

# 清理 MySQL 相关资源
echo "🗑️  清理 MySQL 数据和容器..."
docker volume rm news_mysql_data 2>/dev/null || true
docker volume rm news_news_uploads 2>/dev/null || true
docker volume rm news_news_lucene 2>/dev/null || true

# 清理相关容器
docker container prune -f

# 测试 MySQL 配置
echo "🧪 测试 MySQL 配置..."
echo "启动 MySQL 服务进行测试..."

# 只启动 MySQL 服务
docker-compose -f docker-compose.local.yml up -d mysql

echo "⏳ 等待 MySQL 启动..."
sleep 20

# 检查 MySQL 状态
if docker-compose -f docker-compose.local.yml ps mysql | grep -q "Up"; then
    echo "✅ MySQL 启动成功！"
    
    # 测试连接
    echo "🔗 测试数据库连接..."
    if docker-compose -f docker-compose.local.yml exec mysql mysqladmin ping -h localhost -u newsuser -pnewspassword; then
        echo "✅ 数据库连接正常！"
        
        # 显示数据库信息
        echo "📊 数据库配置信息："
        docker-compose -f docker-compose.local.yml exec mysql mysql -u newsuser -pnewspassword -e "
        SELECT 
            @@version as mysql_version,
            @@character_set_server as server_charset,
            @@collation_server as server_collation;
        USE news;
        SHOW TABLES;
        "
    else
        echo "❌ 数据库连接失败！"
        echo "📋 MySQL 日志："
        docker-compose -f docker-compose.local.yml logs mysql
        exit 1
    fi
else
    echo "❌ MySQL 启动失败！"
    echo "📋 MySQL 日志："
    docker-compose -f docker-compose.local.yml logs mysql
    exit 1
fi

echo ""
echo "✅ MySQL 修复完成！"
echo ""
echo "💡 接下来可以："
echo "   1. 构建应用: ./build-local.sh"
echo "   2. 启动完整服务: ./manage.sh start"
echo "   3. 查看服务状态: ./manage.sh status"
