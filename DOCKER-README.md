# NewsPub Docker 部署指南

本指南介绍如何将 NewsPub 项目和 MySQL 数据库打包成一个 Ubuntu Docker 镜像。

## 环境要求

- Docker 20.10+
- Docker Compose 1.29+
- 至少 2GB 可用内存
- 至少 5GB 可用磁盘空间

## 快速开始

### 1. 构建镜像

```bash
# 使用构建脚本（推荐）
./build-docker.sh

# 或者手动构建
docker-compose build
```

### 2. 启动服务

```bash
# 后台启动
docker-compose up -d

# 前台启动（可以看到实时日志）
docker-compose up
```

### 3. 访问应用

- **前台地址**: http://localhost
- **后台地址**: http://localhost/cp
  - 用户名: `admin`
  - 密码: `password`
- **API文档**: http://localhost/swagger-ui/index.html
- **MySQL数据库**: localhost:3306
  - 数据库名: `news`
  - 用户名: `newsuser`
  - 密码: `news123`
  - Root密码: `root123`

## 常用命令

### 查看服务状态
```bash
docker-compose ps
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看应用日志
docker-compose logs -f news-app
```

### 停止服务
```bash
docker-compose down
```

### 完全清理（包括数据卷）
```bash
docker-compose down -v
```

### 重启服务
```bash
docker-compose restart
```

## 数据持久化

以下数据会被持久化保存：

- **MySQL数据**: 存储在 `mysql_data` 数据卷中
- **上传文件**: 存储在 `uploads_data` 数据卷中  
- **日志文件**: 存储在 `logs_data` 数据卷中

## 配置说明

### 环境变量

可以通过修改 `docker-compose.yml` 中的环境变量来调整配置：

```yaml
environment:
  - MYSQL_ROOT_PASSWORD=root123      # MySQL root密码
  - MYSQL_DATABASE=news              # 数据库名
  - MYSQL_USER=newsuser              # 应用数据库用户
  - MYSQL_PASSWORD=news123           # 应用数据库密码
```

### 端口映射

默认端口映射：
- `80:80` - 应用端口
- `3306:3306` - MySQL端口

如需修改，请编辑 `docker-compose.yml` 文件。

## 故障排除

### 1. 应用启动失败

```bash
# 查看详细日志
docker-compose logs news-app

# 检查MySQL是否正常启动
docker-compose exec news-app mysql -unewsuser -pnews123 -e "SELECT 1"
```

### 2. 端口冲突

如果80或3306端口被占用，修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "8080:80"    # 将应用端口改为8080
  - "3307:3306"  # 将MySQL端口改为3307
```

### 3. 内存不足

如果系统内存不足，可以限制容器内存使用：

```yaml
services:
  news-app:
    # ... 其他配置
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
```

### 4. 数据库连接失败

检查数据库配置和网络连接：

```bash
# 进入容器检查
docker-compose exec news-app bash

# 测试数据库连接
mysql -h localhost -u newsuser -pnews123 news
```

## 生产环境部署建议

### 1. 安全配置

- 修改默认密码
- 使用强密码
- 限制网络访问
- 定期备份数据

### 2. 性能优化

- 根据服务器配置调整JVM参数
- 配置MySQL参数优化
- 使用外部数据库（生产环境推荐）

### 3. 监控和日志

- 配置日志轮转
- 设置监控告警
- 定期检查系统资源使用情况

## 备份和恢复

### 备份数据

```bash
# 备份MySQL数据
docker-compose exec news-app mysqldump -unewsuser -pnews123 news > backup.sql

# 备份上传文件
docker cp $(docker-compose ps -q news-app):/app/uploads ./uploads-backup
```

### 恢复数据

```bash
# 恢复MySQL数据
docker-compose exec -T news-app mysql -unewsuser -pnews123 news < backup.sql

# 恢复上传文件
docker cp ./uploads-backup $(docker-compose ps -q news-app):/app/uploads
```

## 更新升级

### 1. 备份数据（重要！）

```bash
# 备份数据库
docker-compose exec news-app mysqldump -unewsuser -pnews123 news > backup-$(date +%Y%m%d).sql

# 备份上传文件
docker cp $(docker-compose ps -q news-app):/app/uploads ./uploads-backup-$(date +%Y%m%d)
```

### 2. 更新代码

```bash
# 拉取最新代码
git pull

# 重新构建镜像
docker-compose build --no-cache

# 重启服务
docker-compose up -d
```

## 技术支持

如遇到问题，请检查：

1. Docker和Docker Compose版本是否符合要求
2. 系统资源是否充足
3. 端口是否被占用
4. 防火墙设置是否正确

更多技术支持，请参考项目文档或提交Issue。
