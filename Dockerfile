# 多阶段构建优化 Dockerfile - 使用阿里云 Maven 仓库和 Eclipse Temurin
FROM maven:3.8.6-eclipse-temurin-17-alpine AS dependencies

# 设置工作目录
WORKDIR /app

# 复制 Maven 配置文件
COPY .mvn .mvn
COPY mvnw .
COPY mvnw.cmd .

# 只复制 pom.xml
COPY pom.xml .

# 使用阿里云仓库下载依赖（利用 Docker 层缓存）
RUN mvn dependency:go-offline -B --settings .mvn/settings.xml

# 构建阶段
FROM maven:3.8.6-eclipse-temurin-17-alpine AS build

WORKDIR /app

# 从依赖阶段复制已下载的依赖和配置
COPY --from=dependencies /root/.m2 /root/.m2
COPY --from=dependencies /app/.mvn .mvn
COPY --from=dependencies /app/pom.xml .

# 复制源代码
COPY src ./src

# 构建应用（跳过测试，使用 jar 配置，离线模式）
RUN mvn clean package -DskipTests -P jar -o --settings .mvn/settings.xml

# 运行时阶段
FROM eclipse-temurin:17-jre-alpine AS runtime

WORKDIR /app

# 安装 curl（用于健康检查）
RUN apk add --no-cache curl

# 创建非 root 用户
RUN addgroup -g 1001 -S newsapp && \
    adduser -u 1001 -S newsapp -G newsapp

# 从构建阶段复制 jar 文件
COPY --from=build /app/target/news-*.jar app.jar

# 复制静态资源
COPY --from=build /app/src/main/webapp ./static

# 创建必要的目录
RUN mkdir -p static/uploads static/WEB-INF/lucene && \
    chown -R newsapp:newsapp /app

# 切换到非 root 用户
USER newsapp

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# 设置环境变量
ENV JAVA_OPTS="-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
