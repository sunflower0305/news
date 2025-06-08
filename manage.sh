#!/bin/bash

# NewsPub 服务管理脚本

set -e

COMPOSE_FILE="docker-compose.local.yml"

show_help() {
    echo "NewsPub 服务管理脚本"
    echo ""
    echo "用法: ./manage.sh [命令]"
    echo ""
    echo "命令:"
    echo "  start       启动所有服务"
    echo "  stop        停止所有服务"
    echo "  restart     重启所有服务"
    echo "  status      查看服务状态"
    echo "  logs        查看应用日志"
    echo "  logs-db     查看数据库日志"
    echo "  test-db     测试数据库连接"
    echo "  fix-mysql   修复 MySQL 问题"
    echo "  clean       清理停止的容器和未使用的镜像"
    echo "  rebuild     重新构建并启动服务"
    echo "  shell       进入应用容器"
    echo "  db-shell    进入数据库容器"
    echo "  help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./manage.sh start       # 启动服务"
    echo "  ./manage.sh logs        # 查看日志"
    echo "  ./manage.sh test-db     # 测试数据库连接"
    echo "  ./manage.sh fix-mysql   # 修复 MySQL 问题"
    echo "  ./manage.sh restart     # 重启服务"
}

start_services() {
    echo "🚀 启动服务..."
    docker-compose -f $COMPOSE_FILE up -d
    
    echo "⏳ 等待服务启动..."
    sleep 15
    
    echo "🔍 检查服务状态..."
    docker-compose -f $COMPOSE_FILE ps
    
    echo "✅ 服务已启动！"
    show_access_info
}

stop_services() {
    echo "🛑 停止服务..."
    docker-compose -f $COMPOSE_FILE down
    echo "✅ 服务已停止！"
}

restart_services() {
    echo "🔄 重启服务..."
    docker-compose -f $COMPOSE_FILE restart
    
    echo "⏳ 等待服务重启..."
    sleep 10
    
    echo "✅ 服务已重启！"
    show_access_info
}

show_status() {
    echo "📊 服务状态："
    docker-compose -f $COMPOSE_FILE ps
    
    echo ""
    echo "🔍 健康检查："
    docker-compose -f $COMPOSE_FILE exec news-app curl -f http://localhost:8080/actuator/health 2>/dev/null || echo "❌ 应用健康检查失败"
}

show_logs() {
    echo "📋 应用日志："
    docker-compose -f $COMPOSE_FILE logs -f news-app
}

show_db_logs() {
    echo "📋 数据库日志："
    docker-compose -f $COMPOSE_FILE logs -f mysql
}

test_database() {
    echo "🔍 测试数据库连接..."
    
    # 确保数据库服务运行
    docker-compose -f $COMPOSE_FILE up -d mysql
    
    echo "⏳ 等待数据库启动..."
    sleep 10
    
    echo "🔗 测试连接和字符集..."
    docker-compose -f $COMPOSE_FILE exec mysql mysql -u newsuser -pnewspassword -e "
    SELECT 
        @@character_set_server as server_charset,
        @@collation_server as server_collation,
        @@character_set_database as db_charset,
        @@collation_database as db_collation;
    USE news;
    SHOW VARIABLES LIKE 'character_set%';
    " || echo "❌ 数据库连接失败"
    
    echo "✅ 数据库测试完成！"
}

clean_docker() {
    echo "🧹 清理 Docker 资源..."
    docker container prune -f
    docker image prune -f
    echo "✅ 清理完成！"
}

rebuild_services() {
    echo "🔨 重新构建并启动服务..."
    ./build-local.sh
}

enter_app_shell() {
    echo "🐚 进入应用容器..."
    docker-compose -f $COMPOSE_FILE exec news-app /bin/bash
}

enter_db_shell() {
    echo "🐚 进入数据库容器..."
    docker-compose -f $COMPOSE_FILE exec mysql mysql -u newsuser -pnewspassword news
}

show_access_info() {
    echo ""
    echo "🌐 访问地址："
    echo "   前台访问地址: http://localhost:8080"
    echo "   后台访问地址: http://localhost:8080/cp (用户名: admin, 密码: password)"
    echo "   API文档地址: http://localhost:8080/swagger-ui/index.html"
}

fix_mysql() {
    echo "🔧 修复 MySQL 问题..."
    ./fix-mysql.sh
}

# 主逻辑
case "${1:-help}" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    logs-db)
        show_db_logs
        ;;
    test-db)
        test_database
        ;;
    fix-mysql)
        fix_mysql
        ;;
    clean)
        clean_docker
        ;;
    rebuild)
        rebuild_services
        ;;
    shell)
        enter_app_shell
        ;;
    db-shell)
        enter_db_shell
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ 未知命令: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
