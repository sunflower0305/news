#!/bin/bash

# NewsPub 服务验证脚本

set -e

echo "🔍 NewsPub 服务验证"
echo "==================="

# 等待服务启动
wait_for_service() {
    local service=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ 等待 $service 服务启动..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo "✅ $service 服务已启动！"
            return 0
        fi
        
        echo "   尝试 $attempt/$max_attempts..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    echo "❌ $service 服务启动超时"
    return 1
}

# 检查服务状态
check_services() {
    echo "📊 检查服务状态..."
    docker-compose -f docker-compose.local.yml ps
    echo ""
}

# 检查数据库连接
check_database() {
    echo "🗄️  检查数据库连接..."
    if docker-compose -f docker-compose.local.yml exec mysql mysqladmin ping -h localhost -u newsuser -pnewspassword > /dev/null 2>&1; then
        echo "✅ 数据库连接正常"
        
        # 显示数据库信息
        echo "📊 数据库信息："
        docker-compose -f docker-compose.local.yml exec mysql mysql -u newsuser -pnewspassword -e "
        SELECT 
            @@version as mysql_version,
            @@character_set_server as server_charset,
            @@collation_server as server_collation;
        " 2>/dev/null
    else
        echo "❌ 数据库连接失败"
        return 1
    fi
}

# 检查应用健康
check_application() {
    echo "📱 检查应用健康..."
    
    # 等待应用启动
    if wait_for_service "应用" "http://localhost:8080/"; then
        echo "✅ 应用主页可访问"
        
        # 检查后台页面
        if curl -s -f "http://localhost:8080/cp/" > /dev/null 2>&1; then
            echo "✅ 后台页面可访问"
        else
            echo "⚠️  后台页面无法访问"
        fi
        
    else
        echo "❌ 应用启动失败"
        return 1
    fi
}

# 显示访问信息
show_access_info() {
    echo ""
    echo "🌐 访问地址："
    echo "============="
    echo "前台地址: http://localhost:8080"
    echo "后台地址: http://localhost:8080/cp"
    echo "  - 用户名: admin"
    echo "  - 密码: password"
    echo "API文档: http://localhost:8080/swagger-ui/index.html"
    echo ""
}

# 显示管理命令
show_management_commands() {
    echo "🛠️  管理命令："
    echo "============="
    echo "./manage.sh status    # 查看服务状态"
    echo "./manage.sh logs      # 查看应用日志"
    echo "./manage.sh logs-db   # 查看数据库日志"
    echo "./manage.sh restart   # 重启服务"
    echo "./manage.sh stop      # 停止服务"
    echo ""
}

# 主验证流程
main() {
    check_services
    
    if check_database; then
        echo ""
        if check_application; then
            echo ""
            echo "🎉 所有服务验证通过！"
            show_access_info
            show_management_commands
        else
            echo ""
            echo "❌ 应用验证失败"
            echo "💡 查看日志: ./manage.sh logs"
            return 1
        fi
    else
        echo ""
        echo "❌ 数据库验证失败"
        echo "💡 查看数据库日志: ./manage.sh logs-db"
        return 1
    fi
}

# 执行验证
main
