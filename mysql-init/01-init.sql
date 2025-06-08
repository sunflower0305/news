-- MySQL 8.0 初始化脚本
-- 设置字符集和排序规则

-- 设置默认字符集
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `news` 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `news`;

-- 设置会话字符集
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_database = utf8mb4;
SET character_set_results = utf8mb4;
SET character_set_server = utf8mb4;

-- 设置排序规则
SET collation_connection = utf8mb4_unicode_ci;
SET collation_database = utf8mb4_unicode_ci;
SET collation_server = utf8mb4_unicode_ci;

-- MySQL 8.0 优化设置
SET GLOBAL innodb_file_per_table = ON;
SET GLOBAL max_connections = 200;

-- 显示字符集设置（用于调试）
SELECT 
    @@character_set_server as server_charset,
    @@collation_server as server_collation,
    @@character_set_database as db_charset,
    @@collation_database as db_collation,
    @@version as mysql_version;
