#!/bin/bash

# 测试 Maven 阿里云仓库配置

echo "🧪 测试 Maven 阿里云仓库配置..."

# 测试本地配置
echo "📦 测试本地 Maven 配置..."
mvn dependency:resolve -s settings-local.xml -q

if [ $? -eq 0 ]; then
    echo "✅ 本地 Maven 配置正常，阿里云仓库可用"
else
    echo "❌ 本地 Maven 配置有问题"
fi

# 测试 Docker 内配置
echo "🐳 测试 Docker 内 Maven 配置..."
docker run --rm -v $(pwd):/app -w /app maven:3.8.6-openjdk-17-slim \
    mvn dependency:resolve --settings .mvn/settings.xml -q

if [ $? -eq 0 ]; then
    echo "✅ Docker 内 Maven 配置正常，阿里云仓库可用"
else
    echo "❌ Docker 内 Maven 配置有问题"
fi

echo "🎉 测试完成！"
