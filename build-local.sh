#!/bin/bash

# NewsPub 本地构建脚本 - 先本地构建 JAR，再打包 Docker 镜像

set -e

echo "🚀 NewsPub 本地构建流程开始..."

# 检查 Java 和 Maven 环境
check_environment() {
    echo "🔍 检查构建环境..."
    
    if ! command -v java &> /dev/null; then
        echo "❌ Java 未安装或未配置到 PATH"
        exit 1
    fi
    
    if ! command -v mvn &> /dev/null; then
        echo "❌ Maven 未安装或未配置到 PATH"
        exit 1
    fi
    
    echo "✅ Java 版本: $(java -version 2>&1 | head -n 1)"
    echo "✅ Maven 版本: $(mvn -version | head -n 1)"
}

# 清理旧的构建文件
clean_build() {
    echo "🧹 清理旧的构建文件..."
    if [ -d "target" ]; then
        rm -rf target
        echo "✅ 已清理 target 目录"
    fi
}

# 本地构建 JAR 包
build_jar() {
    echo "📦 开始本地构建 JAR 包..."
    echo "   使用阿里云 Maven 仓库加速依赖下载..."
    
    # 使用本地配置文件构建
    mvn clean package -s settings-local.xml -DskipTests -P jar
    
    if [ $? -eq 0 ]; then
        echo "✅ JAR 包构建成功！"
        
        # 显示构建结果
        if [ -f target/news-*.jar ]; then
            JAR_FILE=$(ls target/news-*.jar)
            JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
            echo "📄 构建文件: $JAR_FILE"
            echo "📏 文件大小: $JAR_SIZE"
        fi
    else
        echo "❌ JAR 包构建失败！"
        exit 1
    fi
}

# 构建 Docker 镜像
build_docker() {
    echo "🐳 开始构建 Docker 镜像..."
    
    # 检查 JAR 文件是否存在
    if [ ! -f target/news-*.jar ]; then
        echo "❌ 未找到 JAR 文件，请先构建 JAR 包"
        exit 1
    fi
    
    # 启用 Docker BuildKit
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
    
    # 构建镜像
    docker-compose -f docker-compose.local.yml build news-app
    
    if [ $? -eq 0 ]; then
        echo "✅ Docker 镜像构建成功！"
        
        # 显示镜像信息
        IMAGE_ID=$(docker images news-news-app --format "{{.ID}}" | head -n 1)
        if [ ! -z "$IMAGE_ID" ]; then
            IMAGE_SIZE=$(docker images news-news-app --format "{{.Size}}" | head -n 1)
            echo "🏷️  镜像 ID: $IMAGE_ID"
            echo "📏 镜像大小: $IMAGE_SIZE"
        fi
    else
        echo "❌ Docker 镜像构建失败！"
        exit 1
    fi
}

# 显示构建统计
show_stats() {
    echo ""
    echo "📊 构建统计："
    echo "   - 构建方式: 本地构建 JAR + Docker 打包"
    echo "   - Maven 仓库: 阿里云镜像"
    echo "   - 构建时间: 相比完全 Docker 构建更快"
    echo "   - 镜像大小: 更小（只包含运行时）"
}

# 主流程
main() {
    check_environment
    clean_build
    build_jar
    build_docker
    show_stats
    
    echo ""
    echo "🎉 构建完成！"
    
    # 询问是否启动服务
    read -p "是否立即启动服务？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 启动服务..."
        docker-compose -f docker-compose.local.yml up -d
        
        echo "✅ 服务已启动！"
        echo ""
        echo "🌐 访问地址："
        echo "   前台访问地址: http://localhost:8080"
        echo "   后台访问地址: http://localhost:8080/cp (用户名: admin, 密码: password)"
        echo "   API文档地址: http://localhost:8080/swagger-ui/index.html"
        echo ""
        echo "📋 管理命令："
        echo "   查看日志: docker-compose -f docker-compose.local.yml logs -f news-app"
        echo "   停止服务: docker-compose -f docker-compose.local.yml down"
        echo "   重启服务: docker-compose -f docker-compose.local.yml restart news-app"
    fi
}

# 执行主流程
main
