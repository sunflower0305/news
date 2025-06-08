#!/bin/bash

# NewsPub Docker 构建优化脚本 - 使用阿里云 Maven 仓库

set -e

echo "🚀 开始构建 NewsPub Docker 镜像..."
echo "📦 使用阿里云 Maven 仓库加速依赖下载..."

# 启用 Docker BuildKit 以获得更好的缓存和并行构建
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# 检查是否存在旧的构建缓存
echo "🧹 清理旧的构建缓存..."
docker builder prune -f --filter type=exec.cachemount

# 构建镜像（利用多阶段构建和层缓存）
echo "🔨 构建 Docker 镜像..."
echo "   - 第一阶段：下载 Maven 依赖（使用阿里云仓库）"
echo "   - 第二阶段：编译应用程序"
echo "   - 第三阶段：创建运行时镜像"

docker-compose build --parallel --build-arg BUILDKIT_INLINE_CACHE=1

echo "✅ 构建完成！"
echo ""
echo "📊 构建优化说明："
echo "   - 使用阿里云 Maven 仓库，下载速度更快"
echo "   - 多阶段构建，依赖缓存优化"
echo "   - 只有 pom.xml 变化时才重新下载依赖"
echo "   - 代码变化时只重新编译，不重新下载依赖"

# 可选：启动服务
read -p "是否立即启动服务？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 启动服务..."
    docker-compose up -d
    echo "✅ 服务已启动！"
    echo ""
    echo "🌐 访问地址："
    echo "   前台访问地址: http://localhost:8080"
    echo "   后台访问地址: http://localhost:8080/cp (用户名: admin, 密码: password)"
    echo "   API文档地址: http://localhost:8080/swagger-ui/index.html"
fi
