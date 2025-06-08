# NewsPub Docker 部署完整指南

## 项目概述

NewsPub 是一个基于 Java 的开源新闻网站内容管理系统，采用 SpringBoot、MyBatis、Vue3 等技术开发。本项目已配置为可以打包成包含应用和 MySQL 数据库的 Ubuntu Docker 镜像。

## 文件说明

### Docker 相关文件

- `Dockerfile` - 标准 Docker 构建文件
- `Dockerfile.optimized` - 优化版 Docker 构建文件（多阶段构建）
- `docker-compose.yml` - Docker Compose 配置文件
- `docker-application.yaml` - Docker 环境下的应用配置
- `supervisord.conf` - Supervisor 进程管理配置
- `start.sh` - 容器启动脚本
- `.dockerignore` - Docker 构建忽略文件

### 脚本文件

- `build-docker.sh` - 自动构建脚本
- `test-docker.sh` - 部署测试脚本

### 文档文件

- `DOCKER-README.md` - Docker 使用说明
- `DEPLOYMENT.md` - 本文件，完整部署指南

## 快速部署

### 1. 环境准备

确保系统已安装：
- Docker 20.10+
- Docker Compose 1.29+

### 2. 一键构建和启动

```bash
# 构建镜像
./build-docker.sh

# 启动服务
docker-compose up -d

# 测试部署
./test-docker.sh
```

### 3. 访问应用

- 前台：http://localhost
- 后台：http://localhost/cp (admin/password)
- API文档：http://localhost/swagger-ui/index.html

## 详细部署步骤

### 步骤1：准备项目文件

确保项目根目录包含以下文件：
```
news/
├── src/                    # 源代码目录
├── pom.xml                # Maven 配置
├── Dockerfile             # Docker 构建文件
├── docker-compose.yml     # Docker Compose 配置
├── docker-application.yaml # Docker 环境配置
├── supervisord.conf       # 进程管理配置
├── start.sh              # 启动脚本
└── build-docker.sh       # 构建脚本
```

### 步骤2：构建 Docker 镜像

#### 方法1：使用构建脚本（推荐）
```bash
chmod +x build-docker.sh
./build-docker.sh
```

#### 方法2：手动构建
```bash
# 标准构建
docker-compose build

# 或使用优化版 Dockerfile
docker build -f Dockerfile.optimized -t news-ubuntu .
```

### 步骤3：启动服务

```bash
# 后台启动
docker-compose up -d

# 查看启动状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 步骤4：验证部署

```bash
# 使用测试脚本
./test-docker.sh

# 或手动检查
curl http://localhost
curl http://localhost/cp
```

## 配置说明

### 数据库配置

默认数据库配置：
- 数据库名：`news`
- 用户名：`newsuser`
- 密码：`news123`
- Root密码：`root123`

### 端口配置

- 应用端口：80
- MySQL端口：3306

### 环境变量

可在 `docker-compose.yml` 中修改：
```yaml
environment:
  - MYSQL_ROOT_PASSWORD=root123
  - MYSQL_DATABASE=news
  - MYSQL_USER=newsuser
  - MYSQL_PASSWORD=news123
```

## 生产环境优化

### 1. 安全配置

```yaml
# docker-compose.yml
services:
  news-app:
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
    # 限制端口暴露
    ports:
      - "127.0.0.1:80:80"  # 只允许本地访问
```

### 2. 性能优化

```yaml
# 添加资源限制
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '1.0'
    reservations:
      memory: 1G
      cpus: '0.5'
```

### 3. 数据持久化

```yaml
# 使用命名卷或绑定挂载
volumes:
  - /data/mysql:/var/lib/mysql
  - /data/uploads:/app/uploads
  - /data/logs:/var/log
```

## 监控和维护

### 查看服务状态
```bash
docker-compose ps
docker-compose top
```

### 查看资源使用
```bash
docker stats $(docker-compose ps -q)
```

### 备份数据
```bash
# 数据库备份
docker-compose exec news-app mysqldump -unewsuser -pnews123 news > backup.sql

# 文件备份
docker cp $(docker-compose ps -q news-app):/app/uploads ./uploads-backup
```

### 日志管理
```bash
# 查看日志
docker-compose logs -f news-app

# 清理日志
docker-compose logs --no-log-prefix news-app > /dev/null
```

## 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 修改端口映射
   ports:
     - "8080:80"
     - "3307:3306"
   ```

2. **内存不足**
   ```bash
   # 检查系统资源
   free -h
   df -h
   
   # 限制容器内存
   deploy:
     resources:
       limits:
         memory: 1G
   ```

3. **数据库连接失败**
   ```bash
   # 检查数据库状态
   docker-compose exec news-app mysql -unewsuser -pnews123 -e "SELECT 1"
   
   # 重启数据库服务
   docker-compose restart news-app
   ```

### 调试命令

```bash
# 进入容器
docker-compose exec news-app bash

# 查看进程
docker-compose exec news-app ps aux

# 查看网络
docker-compose exec news-app netstat -tlnp

# 查看磁盘使用
docker-compose exec news-app df -h
```

## 更新升级

### 1. 备份数据
```bash
# 创建备份目录
mkdir -p backup/$(date +%Y%m%d)

# 备份数据库
docker-compose exec news-app mysqldump -unewsuser -pnews123 news > backup/$(date +%Y%m%d)/database.sql

# 备份文件
docker cp $(docker-compose ps -q news-app):/app/uploads backup/$(date +%Y%m%d)/uploads
```

### 2. 更新代码
```bash
# 拉取最新代码
git pull origin main

# 重新构建
docker-compose build --no-cache

# 重启服务
docker-compose up -d
```

### 3. 验证更新
```bash
./test-docker.sh
```

## 扩展配置

### 使用外部数据库

```yaml
# docker-compose.yml
services:
  news-app:
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://external-db:3306/news
      - SPRING_DATASOURCE_USERNAME=newsuser
      - SPRING_DATASOURCE_PASSWORD=news123
```

### 集群部署

```yaml
# docker-compose.cluster.yml
services:
  news-app:
    deploy:
      replicas: 3
    environment:
      - SPRING_CACHE_TYPE=redis
      - SPRING_REDIS_HOST=redis
```

### 负载均衡

```yaml
# 添加 nginx 负载均衡
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - news-app
```

## 技术支持

如遇到问题，请：

1. 查看日志：`docker-compose logs -f`
2. 检查配置：确认环境变量和端口设置
3. 验证资源：确保有足够的内存和磁盘空间
4. 参考文档：查看 `DOCKER-README.md`
5. 提交Issue：在项目仓库中报告问题

## 许可证

本项目遵循原 NewsPub 项目的许可证条款。
