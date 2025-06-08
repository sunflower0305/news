#!/bin/bash

# 数据库连接测试脚本

set -e

echo "🔍 测试数据库连接..."

# 等待 MySQL 服务启动
echo "⏳ 等待 MySQL 服务启动..."
docker-compose -f docker-compose.local.yml up -d mysql

# 等待 MySQL 完全启动
sleep 10

# 测试数据库连接
echo "🔗 测试数据库连接..."
docker-compose -f docker-compose.local.yml exec mysql mysql -u newsuser -pnewspassword -e "
SELECT 
    @@character_set_server as server_charset,
    @@collation_server as server_collation,
    @@character_set_database as db_charset,
    @@collation_database as db_collation;
"

echo "📊 显示数据库信息..."
docker-compose -f docker-compose.local.yml exec mysql mysql -u newsuser -pnewspassword -e "
SHOW DATABASES;
USE news;
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';
"

echo "✅ 数据库连接测试完成！"
