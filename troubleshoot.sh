#!/bin/bash

# NewsPub 故障排除脚本

set -e

echo "🔍 NewsPub 故障排除工具"
echo "========================"

# 检查 Docker 环境
check_docker() {
    echo "🐳 检查 Docker 环境..."
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker 未安装"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        echo "❌ Docker 服务未运行"
        return 1
    fi
    
    echo "✅ Docker 环境正常"
    echo "   Docker 版本: $(docker --version)"
}

# 检查端口占用
check_ports() {
    echo "🔌 检查端口占用..."
    
    if lsof -i :8080 &> /dev/null; then
        echo "⚠️  端口 8080 被占用："
        lsof -i :8080
    else
        echo "✅ 端口 8080 可用"
    fi
    
    if lsof -i :3306 &> /dev/null; then
        echo "⚠️  端口 3306 被占用："
        lsof -i :3306
    else
        echo "✅ 端口 3306 可用"
    fi
}

# 检查服务状态
check_services() {
    echo "📊 检查服务状态..."
    
    if docker-compose -f docker-compose.local.yml ps | grep -q "Up"; then
        echo "✅ 有服务正在运行："
        docker-compose -f docker-compose.local.yml ps
    else
        echo "⚠️  没有服务在运行"
    fi
}

# 检查数据库连接
check_database() {
    echo "🗄️  检查数据库连接..."
    
    # 启动数据库服务
    docker-compose -f docker-compose.local.yml up -d mysql
    sleep 10
    
    # 测试连接
    if docker-compose -f docker-compose.local.yml exec mysql mysql -u newsuser -pnewspassword -e "SELECT 1;" &> /dev/null; then
        echo "✅ 数据库连接正常"
        
        # 检查字符集
        echo "📝 数据库字符集配置："
        docker-compose -f docker-compose.local.yml exec mysql mysql -u newsuser -pnewspassword -e "
        SELECT 
            @@character_set_server as server_charset,
            @@collation_server as server_collation;
        "
    else
        echo "❌ 数据库连接失败"
    fi
}

# 检查应用日志
check_app_logs() {
    echo "📋 检查应用日志（最近 50 行）..."
    
    if docker-compose -f docker-compose.local.yml ps news-app | grep -q "Up"; then
        docker-compose -f docker-compose.local.yml logs --tail=50 news-app
    else
        echo "⚠️  应用服务未运行"
    fi
}

# 检查磁盘空间
check_disk_space() {
    echo "💾 检查磁盘空间..."
    
    df -h | head -n 1
    df -h | grep -E "/$|/var"
    
    echo ""
    echo "🐳 Docker 磁盘使用："
    docker system df
}

# 清理建议
suggest_cleanup() {
    echo "🧹 清理建议..."
    
    # 检查未使用的容器
    STOPPED_CONTAINERS=$(docker ps -a -q -f status=exited | wc -l)
    if [ "$STOPPED_CONTAINERS" -gt 0 ]; then
        echo "⚠️  发现 $STOPPED_CONTAINERS 个停止的容器，建议清理："
        echo "   docker container prune -f"
    fi
    
    # 检查未使用的镜像
    DANGLING_IMAGES=$(docker images -f "dangling=true" -q | wc -l)
    if [ "$DANGLING_IMAGES" -gt 0 ]; then
        echo "⚠️  发现 $DANGLING_IMAGES 个悬空镜像，建议清理："
        echo "   docker image prune -f"
    fi
}

# 常见问题解决方案
show_solutions() {
    echo "💡 常见问题解决方案："
    echo ""
    echo "1. 字符编码错误 (utf8mb4)："
    echo "   - 停止服务: ./manage.sh stop"
    echo "   - 清理数据: docker volume rm news_mysql_data"
    echo "   - 重新启动: ./manage.sh start"
    echo ""
    echo "2. 端口被占用："
    echo "   - 查看占用进程: lsof -i :8080"
    echo "   - 修改端口映射: 编辑 docker-compose.local.yml"
    echo ""
    echo "3. 数据库连接失败："
    echo "   - 测试数据库: ./manage.sh test-db"
    echo "   - 查看数据库日志: ./manage.sh logs-db"
    echo ""
    echo "4. 应用启动失败："
    echo "   - 查看应用日志: ./manage.sh logs"
    echo "   - 重新构建: ./manage.sh rebuild"
    echo ""
    echo "5. 磁盘空间不足："
    echo "   - 清理 Docker: ./manage.sh clean"
    echo "   - 系统清理: docker system prune -a"
}

# 主流程
main() {
    check_docker
    echo ""
    
    check_ports
    echo ""
    
    check_services
    echo ""
    
    check_database
    echo ""
    
    check_disk_space
    echo ""
    
    suggest_cleanup
    echo ""
    
    show_solutions
    
    echo ""
    echo "🎯 如果问题仍然存在，请："
    echo "   1. 查看完整日志: ./manage.sh logs"
    echo "   2. 重新构建: ./manage.sh rebuild"
    echo "   3. 联系技术支持并提供上述信息"
}

# 执行主流程
main
