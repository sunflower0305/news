#!/bin/bash

# 支持不同基础镜像的构建脚本

set -e

show_help() {
    echo "NewsPub 镜像选择构建脚本"
    echo ""
    echo "用法: ./build-with-image.sh [镜像类型]"
    echo ""
    echo "镜像类型:"
    echo "  alpine      使用 Eclipse Temurin Alpine (默认，最小)"
    echo "  distroless  使用 Google Distroless (最安全)"
    echo "  ubuntu      使用 Eclipse Temurin Ubuntu (兼容性最好)"
    echo ""
    echo "示例:"
    echo "  ./build-with-image.sh alpine      # 使用 Alpine 镜像"
    echo "  ./build-with-image.sh distroless  # 使用 Distroless 镜像"
    echo "  ./build-with-image.sh ubuntu      # 使用 Ubuntu 镜像"
}

build_with_alpine() {
    echo "🏔️  使用 Eclipse Temurin Alpine 镜像构建..."
    export DOCKERFILE=Dockerfile.local
    ./build-local.sh
}

build_with_distroless() {
    echo "🔒 使用 Google Distroless 镜像构建..."
    export DOCKERFILE=Dockerfile.distroless
    
    # Distroless 需要完整构建（不支持本地 JAR）
    echo "📦 Distroless 镜像需要完整构建流程..."
    docker-compose -f docker-compose.local.yml build news-app
    
    echo "✅ Distroless 镜像构建完成！"
}

build_with_ubuntu() {
    echo "🐧 使用 Eclipse Temurin Ubuntu 镜像构建..."
    
    # 创建临时的 Ubuntu Dockerfile
    cat > Dockerfile.ubuntu << 'EOF'
# Ubuntu 版本的 Dockerfile
FROM eclipse-temurin:17-jre-jammy AS runtime

WORKDIR /app

# 安装 wget（用于健康检查）
RUN apt-get update && \
    apt-get install -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 创建非 root 用户
RUN groupadd -r newsapp && useradd -r -g newsapp newsapp

# 从本地复制已构建好的 JAR 文件
COPY target/news-*.jar app.jar

# 复制静态资源
COPY src/main/webapp ./static

# 创建必要的目录并设置权限
RUN mkdir -p static/uploads static/WEB-INF/lucene && \
    chown -R newsapp:newsapp /app

# 切换到非 root 用户
USER newsapp

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# 设置环境变量
ENV JAVA_OPTS="-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
EOF
    
    export DOCKERFILE=Dockerfile.ubuntu
    ./build-local.sh
    
    # 清理临时文件
    rm -f Dockerfile.ubuntu
}

show_image_info() {
    echo ""
    echo "📊 镜像对比："
    echo "┌─────────────┬──────────┬──────────┬────────────┐"
    echo "│ 镜像类型    │ 大小     │ 安全性   │ 兼容性     │"
    echo "├─────────────┼──────────┼──────────┼────────────┤"
    echo "│ Alpine      │ 最小     │ 中等     │ 好         │"
    echo "│ Distroless  │ 小       │ 最高     │ 中等       │"
    echo "│ Ubuntu      │ 较大     │ 中等     │ 最好       │"
    echo "└─────────────┴──────────┴──────────┴────────────┘"
    echo ""
    echo "💡 推荐："
    echo "   - 生产环境: distroless (最安全)"
    echo "   - 开发环境: alpine (最小，快速)"
    echo "   - 兼容性要求高: ubuntu"
}

# 主逻辑
case "${1:-alpine}" in
    alpine)
        build_with_alpine
        ;;
    distroless)
        build_with_distroless
        ;;
    ubuntu)
        build_with_ubuntu
        ;;
    help|--help|-h)
        show_help
        show_image_info
        ;;
    *)
        echo "❌ 未知镜像类型: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

show_image_info
