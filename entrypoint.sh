#!/bin/sh

# entrypoint.sh - Hex4j 应用启动入口脚本
# 作用：拆分镜像打包（构建阶段）和容器启动（运行阶段）

set -e

# 应用根目录
APP_DIR="/app"
# 日志目录
LOG_DIR="${APP_DIR}/logs"
# JAR 文件路径
JAR_FILE="${APP_DIR}/app.jar"

# OpenTelemetry Agent 路径
OTEL_AGENT_PATH="/opt/otel/opentelemetry-javaagent.jar"

# 默认 JVM 参数（可通过环境变量覆盖）
JAVA_OPTS=${JAVA_OPTS:="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"}

# 检查并加载 OpenTelemetry Agent
if [ -f "$OTEL_AGENT_PATH" ]; then
  echo "OpenTelemetry Agent loaded: $OTEL_AGENT_PATH"
  JAVA_AGENT_OPTS="-javaagent:$OTEL_AGENT_PATH"
else
  echo "OpenTelemetry Agent not found: $OTEL_AGENT_PATH, running without monitoring"
  JAVA_AGENT_OPTS=""
fi

# OpenTelemetry 配置（当 Agent 存在时生效）
OTEL_SERVICE_NAME=${OTEL_SERVICE_NAME:-"hex4j"}
OTEL_EXPORTER_OTLP_ENDPOINT=${OTEL_EXPORTER_OTLP_ENDPOINT:-"http://jaeger:4317"}

# 确保日志目录存在
mkdir -p "${LOG_DIR}/all" "${LOG_DIR}/error"

# 获取当前时间戳
get_timestamp() {
    date "+%Y-%m-%d %H:%M:%S.%3N"
}

# 获取当前线程名（这里简化为 main）
THREAD_NAME="main"

# 打印启动信息到控制台（带颜色）和日志文件（不带颜色）
print_startup_info() {
    # 控制台输出（带颜色）
    echo ""
    echo -e "\033[1;36m========================================\033[0m"
    echo -e "\033[1;32m  Hex4j Application Starting...\033[0m"
    echo -e "\033[1;36m========================================\033[0m"
    echo -e "  \033[1;33mJAVA_OPTS:\033[0m      ${JAVA_OPTS}"
    echo -e "  \033[1;33mLog Directory:\033[0m  ${LOG_DIR}"
    if [ -n "$JAVA_AGENT_OPTS" ]; then
      echo -e "  \033[1;33mOTel Service:\033[0m   ${OTEL_SERVICE_NAME}"
      echo -e "  \033[1;33mOTel Endpoint:\033[0m  ${OTEL_EXPORTER_OTLP_ENDPOINT}"
    fi
    echo -e "\033[1;36m========================================\033[0m"
    echo ""

    # 写入日志文件（标准格式）
    LOG_FILE="${LOG_DIR}/all/all.log"
    TIMESTAMP=$(get_timestamp)
    echo "${TIMESTAMP} [${THREAD_NAME}] INFO  me.chr.hex4j.Hex4jApplication - ========================================" >> "${LOG_FILE}"
    echo "${TIMESTAMP} [${THREAD_NAME}] INFO  me.chr.hex4j.Hex4jApplication -   Hex4j Application Starting..." >> "${LOG_FILE}"
    echo "${TIMESTAMP} [${THREAD_NAME}] INFO  me.chr.hex4j.Hex4jApplication - ========================================" >> "${LOG_FILE}"
    echo "${TIMESTAMP} [${THREAD_NAME}] INFO  me.chr.hex4j.Hex4jApplication -   JAVA_OPTS: ${JAVA_OPTS}" >> "${LOG_FILE}"
    echo "${TIMESTAMP} [${THREAD_NAME}] INFO  me.chr.hex4j.Hex4jApplication -   Log Directory: ${LOG_DIR}" >> "${LOG_FILE}"
    if [ -n "$JAVA_AGENT_OPTS" ]; then
      echo "${TIMESTAMP} [${THREAD_NAME}] INFO  me.chr.hex4j.Hex4jApplication -   OTel Service: ${OTEL_SERVICE_NAME}" >> "${LOG_FILE}"
      echo "${TIMESTAMP} [${THREAD_NAME}] INFO  me.chr.hex4j.Hex4jApplication -   OTel Endpoint: ${OTEL_EXPORTER_OTLP_ENDPOINT}" >> "${LOG_FILE}"
    fi
    echo "${TIMESTAMP} [${THREAD_NAME}] INFO  me.chr.hex4j.Hex4jApplication - ========================================" >> "${LOG_FILE}"
}

# 打印启动信息
print_startup_info

# 启动应用
exec java ${JAVA_OPTS} \
  ${JAVA_AGENT_OPTS} \
  -Dotel.service.name=${OTEL_SERVICE_NAME} \
  -Dotel.exporter.otlp.endpoint=${OTEL_EXPORTER_OTLP_ENDPOINT} \
  -Dotel.exporter.otlp.protocol=grpc \
  -Dfile.encoding=UTF-8 \
  -jar "${JAR_FILE}" \
  "$@"
