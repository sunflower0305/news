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
                .pathsToMatch("/api/**", "/frontend/**")
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
                .pathsToMatch("/api/**", "/frontend/**")
                .build();
    }
}
