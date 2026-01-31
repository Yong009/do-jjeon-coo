# Spring Boot JSP Project

**Spring Boot Extension Pack**에 최적화된 프로젝트입니다.

## 실행 방법 (VS Code)

1. **Spring Boot Dashboard 이용**:
   - 왼쪽 사이드바의 Spring Boot 아이콘 클릭
   - `Apps` 목록에서 `basic-jsp-project` 찾기 (안 보이면 새로고침)
   - `Run` (▶) 또는 `Debug` (🐞) 버튼 클릭

2. **단축키 이용**:
   - `F5` 키를 눌러서 디버깅 모드로 바로 시작할 수 있습니다.

## 실행 방법 (터미널)

프로젝트에 포함된 Maven Wrapper를 사용합니다:

```bash
# Windows
.\mvnw spring-boot:run

# Mac/Linux
./mvnw spring-boot:run
```

## 접속 주소

서버가 실행되면 아래 주소로 접속하세요:
👉 [http://localhost:8088](http://localhost:8088)

## 프로젝트 구조

- `src/main/java`: Spring Boot Java 소스
- `src/main/webapp/WEB-INF/views`: JSP 파일 (보안을 위해 WEB-INF 내부에 위치)
- `.vscode/launch.json`: VS Code 실행 설정
