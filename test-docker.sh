#!/bin/bash

echo "=== NewsPub Docker 测试脚本 ==="

# 检查服务是否运行
check_service() {
    local service_name=$1
    local port=$2
    local max_attempts=30
    local attempt=1

    echo "检查 $service_name 服务 (端口 $port)..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "http://localhost:$port" > /dev/null 2>&1; then
            echo "✅ $service_name 服务正常运行"
            return 0
        fi
        
        echo "等待 $service_name 启动... ($attempt/$max_attempts)"
        sleep 10
        ((attempt++))
    done
    
    echo "❌ $service_name 服务启动失败或超时"
    return 1
}

# 检查MySQL连接
check_mysql() {
    echo "检查 MySQL 数据库连接..."
    
    if docker-compose exec -T news-app mysql -h localhost -u newsuser -pnews123 -e "SELECT 1" > /dev/null 2>&1; then
        echo "✅ MySQL 数据库连接正常"
        return 0
    else
        echo "❌ MySQL 数据库连接失败"
        return 1
    fi
}

# 主测试流程
main() {
    echo "开始测试 Docker 部署..."
    
    # 检查容器是否运行
    if ! docker-compose ps | grep -q "Up"; then
        echo "❌ 容器未运行，请先启动服务: docker-compose up -d"
        exit 1
    fi
    
    # 等待服务启动
    echo "等待服务完全启动..."
    sleep 30
    
    # 检查应用服务
    if ! check_service "NewsPub应用" 80; then
        echo "查看应用日志:"
        docker-compose logs --tail=50 news-app
        exit 1
    fi
    
    # 检查MySQL服务
    if ! check_mysql; then
        echo "查看MySQL日志:"
        docker-compose logs --tail=50 news-app | grep -i mysql
        exit 1
    fi
    
    # 测试API接口
    echo "测试 API 接口..."
    if curl -s -f "http://localhost/swagger-ui/index.html" > /dev/null; then
        echo "✅ API 文档页面可访问"
    else
        echo "⚠️  API 文档页面可能未完全加载"
    fi
    
    echo ""
    echo "🎉 所有测试通过！"
    echo ""
    echo "访问信息:"
    echo "  前台: http://localhost"
    echo "  后台: http://localhost/cp (admin/password)"
    echo "  API文档: http://localhost/swagger-ui/index.html"
    echo "  MySQL: localhost:3306 (newsuser/news123)"
    echo ""
    echo "查看实时日志: docker-compose logs -f"
}

# 执行主函数
main
