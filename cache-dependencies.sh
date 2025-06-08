#!/bin/bash

echo "=== Maven 依赖缓存脚本 ==="

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装，请先安装 Docker"
    exit 1
fi

# 启用Docker BuildKit
export DOCKER_BUILDKIT=1

echo "创建Maven依赖缓存镜像..."

# 创建临时Dockerfile用于缓存依赖
cat > Dockerfile.cache << 'EOF'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 创建Maven镜像配置
RUN mkdir -p /root/.m2 && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' > /root/.m2/settings.xml && \
    echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"' >> /root/.m2/settings.xml && \
    echo '          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' >> /root/.m2/settings.xml && \
    echo '          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">' >> /root/.m2/settings.xml && \
    echo '  <mirrors>' >> /root/.m2/settings.xml && \
    echo '    <mirror>' >> /root/.m2/settings.xml && \
    echo '      <id>aliyun-maven</id>' >> /root/.m2/settings.xml && \
    echo '      <mirrorOf>central</mirrorOf>' >> /root/.m2/settings.xml && \
    echo '      <name>Aliyun Maven</name>' >> /root/.m2/settings.xml && \
    echo '      <url>https://maven.aliyun.com/repository/central</url>' >> /root/.m2/settings.xml && \
    echo '    </mirror>' >> /root/.m2/settings.xml && \
    echo '  </mirrors>' >> /root/.m2/settings.xml && \
    echo '</settings>' >> /root/.m2/settings.xml

COPY pom.xml .

# 下载所有依赖
RUN mvn dependency:go-offline -B -q && \
    mvn dependency:resolve-sources -B -q && \
    mvn dependency:resolve-javadoc -B -q

# 保存Maven仓库
VOLUME ["/root/.m2/repository"]
EOF

echo "构建依赖缓存镜像..."
docker build -f Dockerfile.cache -t news-maven-cache .

if [ $? -eq 0 ]; then
    echo "✅ Maven依赖缓存镜像构建成功！"
    echo ""
    echo "现在可以使用以下命令快速构建："
    echo "  ./build-docker.sh --fast"
    echo ""
    echo "或者直接使用缓存镜像："
    echo "  docker run --rm -v maven-cache:/root/.m2/repository news-maven-cache"
else
    echo "❌ Maven依赖缓存镜像构建失败！"
    exit 1
fi

# 清理临时文件
rm -f Dockerfile.cache

echo ""
echo "💡 提示："
echo "  - 依赖缓存已创建，后续构建会更快"
echo "  - 如需清理缓存，运行: docker rmi news-maven-cache"
echo "  - 如需重建缓存，重新运行此脚本"
