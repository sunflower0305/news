#!/bin/bash

# 镜像对比测试脚本

set -e

echo "🔍 Docker 镜像对比测试"
echo "======================"

# 确保有 JAR 包
if [ ! -f target/news-*.jar ]; then
    echo "📦 构建 JAR 包..."
    ./build-jar.sh
fi

# 测试不同镜像
test_image() {
    local image_type=$1
    local dockerfile=$2
    
    echo ""
    echo "🧪 测试 $image_type 镜像..."
    echo "使用 Dockerfile: $dockerfile"
    
    # 构建镜像
    start_time=$(date +%s)
    
    if [ "$image_type" = "distroless" ]; then
        # Distroless 需要特殊处理
        docker build -f $dockerfile -t news-test-$image_type .
    else
        DOCKERFILE=$dockerfile docker-compose -f docker-compose.local.yml build news-app
        docker tag news-news-app news-test-$image_type
    fi
    
    end_time=$(date +%s)
    build_time=$((end_time - start_time))
    
    # 获取镜像信息
    image_size=$(docker images news-test-$image_type --format "{{.Size}}")
    image_id=$(docker images news-test-$image_type --format "{{.ID}}")
    
    echo "✅ $image_type 镜像构建完成"
    echo "   构建时间: ${build_time}秒"
    echo "   镜像大小: $image_size"
    echo "   镜像 ID: $image_id"
    
    # 测试启动时间
    echo "🚀 测试启动时间..."
    start_time=$(date +%s)
    
    container_id=$(docker run -d -p 808${image_type:0:1}:8080 news-test-$image_type)
    
    # 等待应用启动
    for i in {1..30}; do
        if docker logs $container_id 2>&1 | grep -q "Started Application"; then
            end_time=$(date +%s)
            startup_time=$((end_time - start_time))
            echo "✅ 应用启动成功，耗时: ${startup_time}秒"
            break
        fi
        sleep 2
    done
    
    # 清理容器
    docker stop $container_id > /dev/null
    docker rm $container_id > /dev/null
    
    # 返回测试结果
    echo "$image_type,$image_size,$build_time,$startup_time"
}

# 创建临时的 Ubuntu Dockerfile
create_ubuntu_dockerfile() {
    cat > Dockerfile.ubuntu.tmp << 'EOF'
FROM eclipse-temurin:17-jre-jammy AS runtime

WORKDIR /app

RUN apt-get update && \
    apt-get install -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r newsapp && useradd -r -g newsapp newsapp

COPY target/news-*.jar app.jar
COPY src/main/webapp ./static

RUN mkdir -p static/uploads static/WEB-INF/lucene && \
    chown -R newsapp:newsapp /app

USER newsapp
EXPOSE 8080

ENV JAVA_OPTS="-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
EOF
}

# 主测试流程
main() {
    echo "开始镜像对比测试..."
    echo ""
    
    # 创建结果文件
    echo "镜像类型,大小,构建时间(秒),启动时间(秒)" > image_comparison.csv
    
    # 测试 Alpine
    result_alpine=$(test_image "alpine" "Dockerfile.local")
    echo "$result_alpine" >> image_comparison.csv
    
    # 测试 Distroless
    result_distroless=$(test_image "distroless" "Dockerfile.distroless")
    echo "$result_distroless" >> image_comparison.csv
    
    # 测试 Ubuntu
    create_ubuntu_dockerfile
    result_ubuntu=$(test_image "ubuntu" "Dockerfile.ubuntu.tmp")
    echo "$result_ubuntu" >> image_comparison.csv
    rm -f Dockerfile.ubuntu.tmp
    
    # 显示对比结果
    echo ""
    echo "📊 镜像对比结果："
    echo "=================="
    column -t -s ',' image_comparison.csv
    
    echo ""
    echo "💡 推荐选择："
    echo "   - 生产环境: distroless (最安全，体积小)"
    echo "   - 开发环境: alpine (最快，体积最小)"
    echo "   - 调试需求: ubuntu (工具最全，兼容性最好)"
    
    # 清理测试镜像
    echo ""
    echo "🧹 清理测试镜像..."
    docker rmi news-test-alpine news-test-distroless news-test-ubuntu 2>/dev/null || true
    
    echo "✅ 对比测试完成！结果已保存到 image_comparison.csv"
}

# 执行测试
main
