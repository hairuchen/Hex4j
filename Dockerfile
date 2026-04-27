# 多阶段构建：构建阶段
FROM maven:3.9.6-eclipse-temurin-21 AS builder

# 配置阿里云 Maven 加速镜像
COPY settings.xml /usr/share/maven/conf/settings.xml

# 工作目录
WORKDIR /app

# 复制项目文件
COPY pom.xml .
COPY src ./src

# 构建项目（跳过测试）
RUN mvn clean package -DskipTests

# 运行阶段
FROM eclipse-temurin:21-jre-alpine

# 设置时区
RUN apk --no-cache add tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 工作目录
WORKDIR /app

# 从构建阶段复制可执行的 JAR 文件
COPY --from=builder /app/target/Hex4j-0.0.1-SNAPSHOT.jar app.jar

# 复制启动脚本
COPY entrypoint.sh entrypoint.sh

# 创建日志目录
RUN mkdir -p /app/logs/all /app/logs/error && \
    chmod +x /app/entrypoint.sh

# 暴露应用端口（假设是 8080）
EXPOSE 8080

# 容器启动命令
ENTRYPOINT ["/app/entrypoint.sh"]
