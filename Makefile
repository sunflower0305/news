# NewsPub 本地构建 Makefile

.PHONY: help build jar docker start stop restart status logs clean rebuild alpine distroless ubuntu

# 默认目标
help:
	@echo "NewsPub 本地构建命令"
	@echo ""
	@echo "构建相关:"
	@echo "  make build       完整构建流程 (JAR + Docker)"
	@echo "  make jar         只构建 JAR 包"
	@echo "  make docker      只构建 Docker 镜像"
	@echo ""
	@echo "镜像选择:"
	@echo "  make alpine      使用 Alpine 镜像构建 (默认)"
	@echo "  make distroless  使用 Distroless 镜像构建"
	@echo "  make ubuntu      使用 Ubuntu 镜像构建"
	@echo ""
	@echo "服务管理:"
	@echo "  make start       启动服务"
	@echo "  make stop        停止服务"
	@echo "  make restart     重启服务"
	@echo "  make status      查看服务状态"
	@echo "  make logs        查看应用日志"
	@echo ""
	@echo "维护相关:"
	@echo "  make clean       清理 Docker 资源"
	@echo "  make rebuild     重新构建并启动"

# 完整构建流程
build:
	@echo "🚀 开始完整构建流程..."
	./build-local.sh

# 只构建 JAR 包
jar:
	@echo "📦 构建 JAR 包..."
	./build-jar.sh

# 只构建 Docker 镜像
docker:
	@echo "🐳 构建 Docker 镜像..."
	./build-docker.sh

# 使用 Alpine 镜像构建
alpine:
	@echo "🏔️  使用 Alpine 镜像构建..."
	./build-with-image.sh alpine

# 使用 Distroless 镜像构建
distroless:
	@echo "🔒 使用 Distroless 镜像构建..."
	./build-with-image.sh distroless

# 使用 Ubuntu 镜像构建
ubuntu:
	@echo "🐧 使用 Ubuntu 镜像构建..."
	./build-with-image.sh ubuntu

# 启动服务
start:
	@echo "🚀 启动服务..."
	./manage.sh start

# 停止服务
stop:
	@echo "🛑 停止服务..."
	./manage.sh stop

# 重启服务
restart:
	@echo "🔄 重启服务..."
	./manage.sh restart

# 查看服务状态
status:
	@echo "📊 查看服务状态..."
	./manage.sh status

# 查看日志
logs:
	@echo "📋 查看应用日志..."
	./manage.sh logs

# 清理资源
clean:
	@echo "🧹 清理 Docker 资源..."
	./manage.sh clean

# 重新构建
rebuild:
	@echo "🔨 重新构建..."
	./manage.sh rebuild
