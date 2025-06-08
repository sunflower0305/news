#!/bin/bash

# 快速构建 JAR 包脚本

set -e

echo "📦 快速构建 JAR 包..."

# 检查 Maven 环境
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven 未安装或未配置到 PATH"
    exit 1
fi

# 显示构建信息
echo "🔧 构建配置："
echo "   - Profile: jar"
echo "   - 跳过测试: 是"
echo "   - Maven 仓库: 阿里云镜像"

# 开始构建
start_time=$(date +%s)

mvn clean package -s settings-local.xml -DskipTests -P jar -q

end_time=$(date +%s)
build_time=$((end_time - start_time))

if [ $? -eq 0 ]; then
    echo "✅ JAR 包构建成功！"
    
    # 显示构建结果
    if [ -f target/news-*.jar ]; then
        JAR_FILE=$(ls target/news-*.jar)
        JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
        echo "📄 构建文件: $JAR_FILE"
        echo "📏 文件大小: $JAR_SIZE"
        echo "⏱️  构建时间: ${build_time}秒"
    fi
else
    echo "❌ JAR 包构建失败！"
    exit 1
fi
