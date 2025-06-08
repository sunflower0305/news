# Docker 镜像升级说明

## 🔄 重要更新

OpenJDK 官方镜像已被弃用，我们已升级到现代化的 Eclipse Temurin 镜像。

### 变更内容

| 组件 | 旧版本 | 新版本 | 说明 |
|------|--------|--------|------|
| 基础镜像 | `openjdk:17-jre-slim` | `eclipse-temurin:17-jre-alpine` | 更小、更安全 |
| 包管理器 | `apt-get` (Debian) | `apk` (Alpine) | 更轻量 |
| 健康检查 | `curl` | `wget` | Alpine 默认包含 |

## 🐳 支持的镜像类型

### 1. Alpine (默认推荐)
```dockerfile
FROM eclipse-temurin:17-jre-alpine
```
- **优势**: 体积最小 (~150MB)，启动最快
- **适用**: 开发环境，快速部署
- **特点**: 基于 musl libc，安全性好

### 2. Distroless (生产推荐)
```dockerfile
FROM gcr.io/distroless/java17-debian11:nonroot
```
- **优势**: 安全性最高，只包含运行时
- **适用**: 生产环境，高安全要求
- **特点**: 无 shell，无包管理器，攻击面最小

### 3. Ubuntu (兼容性最好)
```dockerfile
FROM eclipse-temurin:17-jre-jammy
```
- **优势**: 兼容性最好，调试工具最全
- **适用**: 复杂应用，需要额外工具
- **特点**: 基于 glibc，生态最完整

## 🚀 使用方法

### 快速构建
```bash
# 使用默认 Alpine 镜像
./build-local.sh
make build

# 选择特定镜像类型
./build-with-image.sh alpine      # Alpine 镜像
./build-with-image.sh distroless  # Distroless 镜像
./build-with-image.sh ubuntu      # Ubuntu 镜像

# 使用 Makefile
make alpine      # Alpine 镜像
make distroless  # Distroless 镜像
make ubuntu      # Ubuntu 镜像
```

### 镜像对比测试
```bash
# 对比不同镜像的性能
./compare-images.sh
```

## 📊 性能对比

| 指标 | Alpine | Distroless | Ubuntu |
|------|--------|------------|--------|
| 镜像大小 | ~150MB | ~180MB | ~250MB |
| 构建时间 | 最快 | 中等 | 较慢 |
| 启动时间 | 最快 | 快 | 中等 |
| 安全性 | 好 | 最佳 | 中等 |
| 调试便利性 | 中等 | 困难 | 最好 |

## 🔧 配置说明

### 环境变量优化
```yaml
environment:
  JAVA_OPTS: >-
    -Xms512m
    -Xmx1024m
    -XX:+UseG1GC
    -XX:+UseContainerSupport
    -Dfile.encoding=UTF-8
    -Dsun.jnu.encoding=UTF-8
```

### 健康检查
```yaml
healthcheck:
  test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/actuator/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

## 🛡️ 安全最佳实践

### 1. 非 root 用户
```dockerfile
# Alpine
RUN addgroup -g 1001 -S newsapp && \
    adduser -u 1001 -S newsapp -G newsapp

# Ubuntu
RUN groupadd -r newsapp && useradd -r -g newsapp newsapp

USER newsapp
```

### 2. 最小权限
- 只暴露必要端口
- 使用只读文件系统（可选）
- 限制容器资源

### 3. 镜像扫描
```bash
# 使用 Docker Scout 扫描安全漏洞
docker scout cves news-news-app
```

## 🔄 迁移指南

### 从旧版本迁移
1. **停止现有服务**:
   ```bash
   ./manage.sh stop
   ```

2. **清理旧镜像**:
   ```bash
   docker image prune -f
   ```

3. **重新构建**:
   ```bash
   ./build-local.sh
   ```

4. **启动服务**:
   ```bash
   ./manage.sh start
   ```

### 验证迁移
```bash
# 检查镜像信息
docker images | grep news

# 检查容器状态
./manage.sh status

# 检查应用健康
curl http://localhost:8080/actuator/health
```

## 📝 注意事项

1. **Alpine 特殊性**:
   - 使用 musl libc 而非 glibc
   - 某些 Java 库可能有兼容性问题
   - 时区设置可能需要额外配置

2. **Distroless 限制**:
   - 无 shell，调试困难
   - 无包管理器，无法安装额外工具
   - 适合生产环境，不适合开发调试

3. **Ubuntu 优势**:
   - 完整的 GNU/Linux 环境
   - 丰富的调试工具
   - 最好的兼容性

## 🎯 推荐策略

- **开发阶段**: 使用 Alpine，快速迭代
- **测试阶段**: 使用 Distroless，模拟生产环境
- **生产部署**: 使用 Distroless，最高安全性
- **问题调试**: 临时使用 Ubuntu，完整工具链

## 🔗 相关链接

- [Eclipse Temurin 官网](https://adoptium.net/)
- [Google Distroless 项目](https://github.com/GoogleContainerTools/distroless)
- [Alpine Linux 官网](https://alpinelinux.org/)
- [Docker 最佳实践](https://docs.docker.com/develop/dev-best-practices/)
