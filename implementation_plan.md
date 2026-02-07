# 구현 계획: Java JSP 웹 애플리케이션

이 문서는 Java와 JSP를 기반으로 한 웹 애플리케이션의 구현 계획을 설명합니다.

## 1. 프로젝트 기본 구조 및 설정
- **목표**: Maven 기반의 표준 웹 프로젝트 디렉토리 구조 생성 및 빌드 설정.
- **파일**:
    - `pom.xml`: 빌드 설정, 의존성(Servlet 4.0, JSP 2.3, JSTL), Jetty 플러그인.
    - `src/main/webapp/WEB-INF/web.xml`: 웹 애플리케이션 설정.

## 2. UI/UX 디자인 (Premium Design)
- **목표**: 사용자에게 시각적인 즐거움을 주는 모던한 인터페이스 구현.
- **스타일**:
    - `src/main/webapp/css/style.css`: CSS Variables 활용, Inter 폰트, 반응형 레이아웃, 부드러운 애니메이션.
- [x] Integrate Kakao AdFit and Coupang Partners
- [x] Fix HIRA Locator Error
- [x] Connect Stagehand MCP
- [x] Extract fax numbers and retry
- [x] Test Chrome DevTools Connection
- [x] GitHub MCP Connection
- [x] Retry Fax Crawler Test
- [x] AdSense Integration
    - [x] Add verification script to index.html
    - [x] Create privacy.html
    - [x] **Fix ads.txt not found error** (Current Task)
        - [x] Locate ads.txt
        - [x] Copy ads.txt to deployment folder (main_site)
        - [x] Update upload_main_site.bat to automate copying
    - 배경: 은은한 메쉬 그라디언트(Mesh Gradient) 또는 다크 모드 기반의 세련된 색상.

## 3. 기능 구현
- **JSP 페이지**:
    - `src/main/webapp/index.jsp`: 메인 랜딩 페이지. JSTL을 활용한 데이터 표시 예시 포함.
- **Java 서블릿**:
    - `src/main/java/com/example/controller/HelloServlet.java`: `/hello` 경로로 요청 시 데이터를 가공하여 JSP로 전달하는 예제 컨트롤러.

## 4. 실행 및 테스트 방법
- `mvn jetty:run` 명령어를 통해 로컬에서 즉시 실행 가능하도록 가이드 제공.
