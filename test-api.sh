#!/bin/bash

# 测试 NewsPub API 端点脚本

set -e

echo "🔍 测试 NewsPub API 端点..."

# 测试基本连接
echo "📡 测试基本连接..."
if curl -s -f "http://localhost:8080/" > /dev/null; then
    echo "✅ 应用连接正常"
else
    echo "❌ 应用连接失败"
    exit 1
fi

# 测试 API 端点
echo ""
echo "🔗 测试 API 端点..."

# 测试前台 API 文章列表
echo "📰 测试文章 API..."
echo "   /api/article:"
curl -s "http://localhost:8080/api/article" | head -100 || echo "   ❌ 失败"

echo ""
echo "   /frontend/article:"
curl -s "http://localhost:8080/frontend/article" | head -100 || echo "   ❌ 失败"

# 测试 Swagger 文档端点
echo ""
echo "📚 测试 Swagger 文档端点..."

echo "   /v3/api-docs:"
api_docs=$(curl -s "http://localhost:8080/v3/api-docs" 2>/dev/null || echo "failed")
if [[ "$api_docs" == *"openapi"* ]]; then
    echo "   ✅ 主文档可访问"
else
    echo "   ❌ 主文档访问失败"
fi

echo "   /v3/api-docs/frontend:"
frontend_docs=$(curl -s "http://localhost:8080/v3/api-docs/frontend" 2>/dev/null || echo "failed")
if [[ "$frontend_docs" == *"openapi"* ]]; then
    echo "   ✅ 前台文档可访问"
    # 检查是否有路径定义
    if [[ "$frontend_docs" == *'"paths":{'* ]] && [[ "$frontend_docs" != *'"paths":{},'* ]]; then
        echo "   ✅ 前台文档包含 API 路径"
    else
        echo "   ⚠️  前台文档路径为空"
    fi
else
    echo "   ❌ 前台文档访问失败"
fi

echo "   /v3/api-docs/all:"
all_docs=$(curl -s "http://localhost:8080/v3/api-docs/all" 2>/dev/null || echo "failed")
if [[ "$all_docs" == *"openapi"* ]]; then
    echo "   ✅ 完整文档可访问"
    # 检查是否有路径定义
    if [[ "$all_docs" == *'"paths":{'* ]] && [[ "$all_docs" != *'"paths":{},'* ]]; then
        echo "   ✅ 完整文档包含 API 路径"
    else
        echo "   ⚠️  完整文档路径为空"
    fi
else
    echo "   ❌ 完整文档访问失败"
fi

# 测试 Swagger UI
echo ""
echo "🌐 测试 Swagger UI..."
swagger_ui=$(curl -s "http://localhost:8080/swagger-ui/index.html" 2>/dev/null || echo "failed")
if [[ "$swagger_ui" == *"swagger-ui"* ]]; then
    echo "   ✅ Swagger UI 可访问"
else
    echo "   ❌ Swagger UI 访问失败"
fi

# 显示可用的 API 端点
echo ""
echo "🔍 查找可用的 API 端点..."
echo "   检查应用日志中的映射信息..."
docker-compose -f docker-compose.local.yml logs news-app 2>/dev/null | grep -i "mapped\|mapping" | head -10 || echo "   未找到映射信息"

echo ""
echo "📋 API 测试完成！"
echo ""
echo "🌐 访问地址："
echo "   Swagger UI: http://localhost:8080/swagger-ui/index.html"
echo "   API 文档: http://localhost:8080/v3/api-docs"
echo "   前台 API 文档: http://localhost:8080/v3/api-docs/frontend"
echo "   完整 API 文档: http://localhost:8080/v3/api-docs/all"
