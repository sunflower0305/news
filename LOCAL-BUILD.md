# NewsPub 本地构建指南

本指南介绍如何在本地构建 JAR 包，然后打包到 Docker 镜像中运行。现在支持多种基础镜像选择，包括 Eclipse Temurin、Google Distroless 等现代化镜像。

## 🎯 优势

- **构建速度更快**: 利用本地 Maven 缓存，避免重复下载依赖
- **开发体验更好**: 可以在 IDE 中直接调试和测试
- **镜像更小**: 最终镜像只包含运行时环境和 JAR 包
- **灵活性更高**: 支持多种基础镜像选择
- **现代化**: 使用 Eclipse Temurin 替代已弃用的 OpenJDK 镜像

## 📋 环境要求

- **JDK 17+**: 用于编译 Java 代码
- **Maven 3.6.3+**: 用于依赖管理和构建
- **Docker**: 用于容器化部署
- **Docker Compose**: 用于多容器编排

## 🐳 镜像选择

### 支持的基础镜像

| 镜像类型 | 基础镜像 | 大小 | 安全性 | 兼容性 | 推荐场景 |
|----------|----------|------|--------|--------|----------|
| **Alpine** | eclipse-temurin:17-jre-alpine | 最小 | 中等 | 好 | 开发环境，快速部署 |
| **Distroless** | gcr.io/distroless/java17 | 小 | 最高 | 中等 | 生产环境，高安全要求 |
| **Ubuntu** | eclipse-temurin:17-jre-jammy | 较大 | 中等 | 最好 | 兼容性要求高的场景 |

### 镜像特点

- **Alpine**: 基于 Alpine Linux，体积最小，启动最快
- **Distroless**: Google 出品，只包含运行时，安全性最高
- **Ubuntu**: 基于 Ubuntu，兼容性最好，调试工具最全

## 🚀 快速开始

### 1. 默认构建（Alpine）
```bash
# 完整流程：构建 JAR + 构建镜像 + 启动服务
./build-local.sh

# 或者使用 Makefile
make build
```

### 2. 选择镜像类型构建
```bash
# 使用 Alpine 镜像（默认，最小）
./build-with-image.sh alpine
make alpine

# 使用 Distroless 镜像（最安全）
./build-with-image.sh distroless
make distroless

# 使用 Ubuntu 镜像（兼容性最好）
./build-with-image.sh ubuntu
make ubuntu
```

### 3. 分步构建
```bash
# 步骤1：构建 JAR 包
./build-jar.sh
# 或者: make jar

# 步骤2：构建 Docker 镜像
./build-docker.sh
# 或者: make docker

# 步骤3：启动服务
./manage.sh start
# 或者: make start
```

## 🛠️ 详细命令

### 构建相关
```bash
# 完整构建流程
./build-local.sh
make build

# 只构建 JAR 包
./build-jar.sh
make jar

# 只构建 Docker 镜像（需要先有 JAR 包）
./build-docker.sh
make docker

# 测试 Maven 配置
./test-maven.sh
```

### 服务管理
```bash
# 启动服务
./manage.sh start
make start

# 停止服务
./manage.sh stop
make stop

# 重启服务
./manage.sh restart
make restart

# 查看服务状态
./manage.sh status
make status

# 查看应用日志
./manage.sh logs
make logs

# 查看数据库日志
./manage.sh logs-db
```

### 维护相关
```bash
# 清理 Docker 资源
./manage.sh clean
make clean

# 重新构建并启动
./manage.sh rebuild
make rebuild

# 进入应用容器
./manage.sh shell

# 进入数据库容器
./manage.sh db-shell
```

## 📁 文件结构

```
news/
├── src/                          # 源代码
├── target/                       # Maven 构建输出
│   └── news-*.jar               # 构建的 JAR 包
├── .mvn/
│   ├── settings.xml             # Docker 构建用 Maven 配置
│   └── maven.config             # Maven 构建参数
├── settings-local.xml           # 本地构建用 Maven 配置
├── Dockerfile.local             # 本地构建专用 Dockerfile
├── docker-compose.local.yml     # 本地构建专用 Docker Compose
├── build-local.sh              # 完整构建脚本
├── build-jar.sh                # JAR 构建脚本
├── build-docker.sh             # Docker 构建脚本
├── manage.sh                   # 服务管理脚本
├── Makefile                    # Make 命令简化
└── LOCAL-BUILD.md              # 本文档
```

## 🔧 配置说明

### Maven 配置
- **settings-local.xml**: 本地开发用，配置阿里云仓库镜像
- **.mvn/settings.xml**: Docker 构建用，配置阿里云仓库镜像
- **pom.xml**: 项目配置，已添加阿里云仓库

### Docker 配置
- **Dockerfile.local**: 轻量级 Dockerfile，只复制 JAR 包和静态资源
- **docker-compose.local.yml**: 本地构建专用的 Docker Compose 配置

### JVM 优化
Docker Compose 中已配置 JVM 优化参数：
```yaml
JAVA_OPTS: >-
  -Xms512m
  -Xmx1024m
  -XX:+UseG1GC
  -XX:G1HeapRegionSize=16m
  -XX:+UseStringDeduplication
  -XX:+OptimizeStringConcat
  -Djava.security.egd=file:/dev/./urandom
```

## 📊 性能对比

| 构建方式 | 首次构建 | 代码变更构建 | 镜像大小 | 优势 |
|----------|----------|--------------|----------|------|
| 完全 Docker 构建 | 5-10分钟 | 5-10分钟 | 较大 | 环境一致性 |
| 本地构建 + Docker | 2-3分钟 | 30-60秒 | 较小 | 速度快，开发友好 |

## 🌐 访问地址

服务启动后可通过以下地址访问：

- **前台**: http://localhost:8080
- **后台**: http://localhost:8080/cp
  - 用户名: `admin`
  - 密码: `password`
- **API文档**: http://localhost:8080/swagger-ui/index.html

## 🔍 故障排除

### JAR 构建失败
```bash
# 检查 Java 和 Maven 版本
java -version
mvn -version

# 清理并重新构建
mvn clean
./build-jar.sh
```

### Docker 构建失败
```bash
# 检查 JAR 文件是否存在
ls -la target/news-*.jar

# 重新构建 JAR
./build-jar.sh

# 重新构建 Docker 镜像
./build-docker.sh
```

### 服务启动失败
```bash
# 查看服务状态
./manage.sh status

# 查看应用日志
./manage.sh logs

# 查看数据库日志
./manage.sh logs-db

# 重启服务
./manage.sh restart
```

### 端口冲突
如果 8080 端口被占用，可以修改 `docker-compose.local.yml` 中的端口映射：
```yaml
ports:
  - "8081:8080"  # 改为 8081 端口
```

## 💡 开发建议

1. **IDE 配置**: 在 IDE 中配置使用 `settings-local.xml` 作为 Maven 配置文件
2. **热重载**: 开发时可以直接在 IDE 中运行，支持热重载
3. **调试模式**: 需要调试时，可以在本地直接运行 JAR 包
4. **生产部署**: 生产环境建议使用完全 Docker 构建以确保环境一致性

## 🔄 工作流程建议

### 开发阶段
1. 在 IDE 中开发和测试
2. 使用 `./build-jar.sh` 快速构建验证
3. 使用 `./build-local.sh` 完整测试

### 部署阶段
1. 使用 `./build-local.sh` 构建镜像
2. 使用 `./manage.sh start` 启动服务
3. 使用 `./manage.sh logs` 监控日志

### 维护阶段
1. 使用 `./manage.sh status` 检查服务状态
2. 使用 `./manage.sh clean` 定期清理资源
3. 使用 `./manage.sh rebuild` 重新部署
