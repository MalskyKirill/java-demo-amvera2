# ---------- СТАДИЯ СБОРКИ ----------
FROM maven:3.9.9-eclipse-temurin-17 AS builder

# Рабочая директория внутри контейнера
WORKDIR /app

# Сначала копируем pom.xml и скачиваем зависимости (кэш)
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

# Теперь копируем исходники и собираем jar
COPY src ./src
RUN mvn -B -q clean package spring-boot:repackage

# ---------- СТАДИЯ РАНТАЙМА ----------
FROM eclipse-temurin:17-jre

# Рабочая директория внутри финального контейнера
WORKDIR /app

# Копируем jar из builder-стадии
COPY --from=builder /app/target/*.jar app.jar

# Порт, на котором слушает приложение
EXPOSE 8080

# Переменная окружения (по желанию)
ENV JAVA_OPTS=""

# Точка входа
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
