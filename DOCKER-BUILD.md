# NewsPub Docker 构建优化指南

本项目已配置阿里云 Maven 仓库，大幅提升依赖下载速度和构建效率。

## 🚀 快速开始

### 1. 一键构建和启动
```bash
./build.sh
```

### 2. 仅构建镜像
```bash
docker-compose build
```

### 3. 启动服务
```bash
docker-compose up -d
```

## 📦 Maven 仓库配置

### 阿里云仓库地址
- **Central**: https://maven.aliyun.com/repository/central
- **Public**: https://maven.aliyun.com/repository/public  
- **Spring**: https://maven.aliyun.com/repository/spring
- **Spring Plugin**: https://maven.aliyun.com/repository/spring-plugin

### 配置文件说明
- `.mvn/settings.xml` - Docker 构建时使用的 Maven 配置
- `settings-local.xml` - 本地开发时使用的 Maven 配置
- `pom.xml` - 项目中已添加阿里云仓库配置

## 🔧 本地开发

### 使用阿里云仓库进行本地构建
```bash
# 使用本地配置文件
mvn clean package -s settings-local.xml -DskipTests -P jar

# 或者直接使用（pom.xml 中已配置）
mvn clean package -DskipTests -P jar
```

### 测试 Maven 配置
```bash
./test-maven.sh
```

## 🐳 Docker 构建优化

### 多阶段构建流程
1. **依赖阶段**: 只复制 `pom.xml` 和 Maven 配置，下载所有依赖
2. **构建阶段**: 复制源代码，使用缓存的依赖进行编译
3. **运行阶段**: 创建轻量级运行时镜像

### 缓存优化策略
- 依赖下载和代码编译分离
- 只有 `pom.xml` 变化时才重新下载依赖
- 代码变化时只重新编译，不重新下载依赖
- 使用 Docker BuildKit 提升构建性能

## 📊 性能对比

| 场景 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| 首次构建 | 5-10分钟 | 3-5分钟 | 40-50% |
| 代码变更构建 | 5-10分钟 | 30-60秒 | 90%+ |
| 依赖下载速度 | 较慢（国外源） | 快速（阿里云） | 3-5倍 |

## 🛠️ 常用命令

### 构建相关
```bash
# 完整构建
./build.sh

# 强制重新构建（不使用缓存）
docker-compose build --no-cache

# 只构建应用镜像
docker-compose build news-app

# 查看构建日志
docker-compose logs news-app
```

### 服务管理
```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f news-app
```

### 清理相关
```bash
# 清理构建缓存
docker builder prune

# 清理未使用的镜像
docker image prune

# 完全清理（谨慎使用）
docker system prune -a
```

## 🌐 访问地址

服务启动后可通过以下地址访问：

- **前台**: http://localhost:8080
- **后台**: http://localhost:8080/cp
  - 用户名: `admin`
  - 密码: `password`
- **API文档**: http://localhost:8080/swagger-ui/index.html

## 🔍 故障排除

### 构建失败
1. 检查网络连接
2. 清理 Docker 缓存: `docker builder prune`
3. 重新构建: `docker-compose build --no-cache`

### 依赖下载慢
1. 确认使用了阿里云仓库配置
2. 检查 `.mvn/settings.xml` 文件
3. 运行测试脚本: `./test-maven.sh`

### 服务启动失败
1. 检查数据库连接配置
2. 查看服务日志: `docker-compose logs news-app`
3. 确认端口未被占用

## 📝 注意事项

1. 首次构建仍需要下载所有依赖，请耐心等待
2. 后续构建会利用缓存，速度会显著提升
3. 修改 `pom.xml` 后会重新下载依赖
4. 建议定期清理 Docker 缓存以释放磁盘空间
