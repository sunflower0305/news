#!/bin/bash

# NewsPub 问题诊断和自动修复脚本

set -e

echo "🔍 NewsPub 问题诊断工具"
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
        return 1
    else
        echo "✅ 端口 8080 可用"
    fi
    
    if lsof -i :3306 &> /dev/null; then
        echo "⚠️  端口 3306 被占用："
        lsof -i :3306
        return 1
    else
        echo "✅ 端口 3306 可用"
    fi
    
    return 0
}

# 检查服务状态
check_services() {
    echo "📊 检查服务状态..."
    
    if docker-compose -f docker-compose.local.yml ps 2>/dev/null | grep -q "Up"; then
        echo "✅ 有服务正在运行："
        docker-compose -f docker-compose.local.yml ps
        return 0
    else
        echo "⚠️  没有服务在运行"
        return 1
    fi
}

# 检查 MySQL 特定问题
check_mysql_issues() {
    echo "🗄️  检查 MySQL 问题..."
    
    # 检查 MySQL 日志中的常见错误
    if docker-compose -f docker-compose.local.yml logs mysql 2>/dev/null | grep -q "unknown variable"; then
        echo "❌ 发现 MySQL 配置错误（unknown variable）"
        echo "💡 建议运行: ./manage.sh fix-mysql"
        return 1
    fi
    
    if docker-compose -f docker-compose.local.yml logs mysql 2>/dev/null | grep -q "innodb_large_prefix"; then
        echo "❌ 发现过时的 MySQL 参数（innodb_large_prefix）"
        echo "💡 建议运行: ./manage.sh fix-mysql"
        return 1
    fi
    
    if docker-compose -f docker-compose.local.yml logs mysql 2>/dev/null | grep -q "innodb_file_format"; then
        echo "❌ 发现过时的 MySQL 参数（innodb_file_format）"
        echo "💡 建议运行: ./manage.sh fix-mysql"
        return 1
    fi
    
    echo "✅ 未发现 MySQL 配置问题"
    return 0
}

# 检查应用问题
check_app_issues() {
    echo "📱 检查应用问题..."
    
    if docker-compose -f docker-compose.local.yml logs news-app 2>/dev/null | grep -q "Unsupported character encoding"; then
        echo "❌ 发现字符编码问题"
        echo "💡 建议运行: ./fix-charset.sh"
        return 1
    fi
    
    if docker-compose -f docker-compose.local.yml logs news-app 2>/dev/null | grep -q "Connection refused"; then
        echo "❌ 发现数据库连接问题"
        echo "💡 建议运行: ./manage.sh test-db"
        return 1
    fi
    
    echo "✅ 未发现应用问题"
    return 0
}

# 自动修复建议
suggest_fixes() {
    echo ""
    echo "🔧 自动修复建议："
    echo "=================="
    
    local has_issues=false
    
    # 检查各种问题并给出修复建议
    if ! check_docker; then
        echo "1. 安装并启动 Docker"
        has_issues=true
    fi
    
    if ! check_ports; then
        echo "2. 释放被占用的端口或修改配置"
        has_issues=true
    fi
    
    if ! check_mysql_issues; then
        echo "3. 修复 MySQL 配置: ./manage.sh fix-mysql"
        has_issues=true
    fi
    
    if ! check_app_issues; then
        echo "4. 修复应用问题: ./fix-charset.sh"
        has_issues=true
    fi
    
    if [ "$has_issues" = false ]; then
        echo "✅ 未发现问题，系统状态良好"
        
        if ! check_services; then
            echo ""
            echo "💡 服务未运行，可以启动服务："
            echo "   ./manage.sh start"
        fi
    fi
}

# 一键修复功能
auto_fix() {
    echo "🔧 开始自动修复..."
    
    # 停止所有服务
    echo "🛑 停止现有服务..."
    docker-compose -f docker-compose.local.yml down 2>/dev/null || true
    
    # 修复 MySQL 问题
    echo "🗄️  修复 MySQL 问题..."
    ./fix-mysql.sh
    
    # 检查是否需要重新构建应用
    if [ ! -f target/news-*.jar ]; then
        echo "📦 构建应用..."
        ./build-local.sh
    else
        echo "✅ 发现已构建的 JAR 包"
    fi
    
    echo "✅ 自动修复完成！"
    echo ""
    echo "💡 接下来可以："
    echo "   1. 启动服务: ./manage.sh start"
    echo "   2. 查看状态: ./manage.sh status"
    echo "   3. 查看日志: ./manage.sh logs"
}

# 主菜单
show_menu() {
    echo ""
    echo "请选择操作："
    echo "1. 完整诊断"
    echo "2. 一键修复"
    echo "3. 退出"
    echo ""
    read -p "请输入选项 (1-3): " choice
    
    case $choice in
        1)
            echo ""
            echo "🔍 开始完整诊断..."
            check_docker
            echo ""
            check_ports
            echo ""
            check_services
            echo ""
            check_mysql_issues
            echo ""
            check_app_issues
            suggest_fixes
            ;;
        2)
            auto_fix
            ;;
        3)
            echo "👋 再见！"
            exit 0
            ;;
        *)
            echo "❌ 无效选项"
            show_menu
            ;;
    esac
}

# 如果有参数，直接执行对应功能
if [ $# -gt 0 ]; then
    case "$1" in
        "fix")
            auto_fix
            ;;
        "check")
            check_docker && check_ports && check_services && check_mysql_issues && check_app_issues
            suggest_fixes
            ;;
        *)
            echo "用法: $0 [fix|check]"
            echo "  fix   - 一键修复"
            echo "  check - 完整诊断"
            exit 1
            ;;
    esac
else
    show_menu
fi
