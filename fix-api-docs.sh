#!/bin/bash

# 修复 API 文档配置脚本

set -e

echo "🔧 修复 NewsPub API 文档配置..."

# 备份原始配置
echo "📋 备份原始配置..."
cp src/main/java/com/zly/cms/core/SwaggerConfig.java src/main/java/com/zly/cms/core/SwaggerConfig.java.bak

# 创建新的 SwaggerConfig
echo "📝 更新 SwaggerConfig..."
cat > src/main/java/com/zly/cms/core/SwaggerConfig.java << 'EOF'
package com.zly.cms.core;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import org.springdoc.core.GroupedOpenApi;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * SpringDoc Swagger 配置
 * <p>
 * <a href="https://github.com/springdoc/springdoc-openapi-demos/blob/master/springdoc-openapi-spring-boot-2-webmvc/src/main/java/org/springdoc/demo/app2/Application.java">springdoc-openapi Application.java</a>
 *
 * @author PONY
 */
@Configuration
public class SwaggerConfig {
    /**
     * 文档定义
     */
    @Bean
    public OpenAPI openApi(@Value("${ujcms.version:1.0.2}") String version) {
        return new OpenAPI()
                .info(new Info()
                        .title("NewsPub API")
                        .description("NewsPub 新闻内容管理系统 API 接口文档")
                        .version(version)
                        .contact(new Contact()
                                .name("NewsPub Team")
                                .url("http://47.111.110.86/")
                                .email("support@newspub.com"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0")));
    }

    /**
     * 前台 API 分组
     *
     * @param version 当前软件版本号
     */
    @Bean
    public GroupedOpenApi frontendGroup(@Value("${ujcms.version:1.0.2}") String version) {
        return GroupedOpenApi.builder()
                .group("frontend")
                .displayName("前台API")
                .addOpenApiCustomiser(openApi -> openApi.info(new Info()
                        .title("NewsPub 前台 API")
                        .description("NewsPub 前台接口，包括文章、标签、用户等功能")
                        .version(version)))
                .packagesToScan("com.zly.cms.core.web.api", "com.zly.cms.ext.web.api")
                .pathsToMatch("/api/**")
                .build();
    }

    /**
     * 后台 API 分组
     *
     * @param version 当前软件版本号
     */
    @Bean
    public GroupedOpenApi backendGroup(@Value("${ujcms.version:1.0.2}") String version) {
        return GroupedOpenApi.builder()
                .group("backend")
                .displayName("后台API")
                .addOpenApiCustomiser(openApi -> openApi.info(new Info()
                        .title("NewsPub 后台 API")
                        .description("NewsPub 后台管理接口")
                        .version(version)))
                .packagesToScan("com.zly.cms.core.web.backendapi")
                .pathsToMatch("/api/backend/**")
                .build();
    }

    /**
     * 所有 API 分组
     *
     * @param version 当前软件版本号
     */
    @Bean
    public GroupedOpenApi allGroup(@Value("${ujcms.version:1.0.2}") String version) {
        return GroupedOpenApi.builder()
                .group("all")
                .displayName("所有API")
                .addOpenApiCustomiser(openApi -> openApi.info(new Info()
                        .title("NewsPub 完整 API")
                        .description("NewsPub 所有接口文档")
                        .version(version)))
                .packagesToScan("com.zly.cms")
                .pathsToMatch("/api/**")
                .build();
    }
}
EOF

echo "✅ SwaggerConfig 更新完成！"

# 检查是否需要重新构建
if [ -f "target/news-*.jar" ]; then
    echo "🔨 重新构建应用..."
    ./build-jar.sh
    
    echo "🐳 重新构建 Docker 镜像..."
    DOCKERFILE=Dockerfile.stable docker-compose -f docker-compose.local.yml build news-app
    
    echo "🔄 重启服务..."
    docker-compose -f docker-compose.local.yml restart news-app
    
    echo "⏳ 等待服务重启..."
    sleep 15
    
    echo "🌐 API 文档地址："
    echo "   完整文档: http://localhost:8080/swagger-ui/index.html"
    echo "   前台API: http://localhost:8080/swagger-ui/index.html?urls.primaryName=frontend"
    echo "   后台API: http://localhost:8080/swagger-ui/index.html?urls.primaryName=backend"
    echo "   所有API: http://localhost:8080/swagger-ui/index.html?urls.primaryName=all"
else
    echo "⚠️  未找到已构建的 JAR 包，请先运行 ./build-local.sh"
fi

echo "✅ API 文档修复完成！"
