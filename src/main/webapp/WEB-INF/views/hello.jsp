<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Spring Boot Hello</title>
    <!-- Adjust CSS path since we are in WEB-INF/views now, need absolute path from context root -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <div class="container hero">
        <h1>Spring Boot Controller</h1>
        <p>Spring MVC Controller에서 전달받은 메시지:</p>
        
        <div class="card">
            <h2>${message}</h2>
            <p>JSP Expression Language (EL)를 사용하여 출력되었습니다.</p>
        </div>
        
        <br>
        <a href="${pageContext.request.contextPath}/" class="btn">메인으로 돌아가기</a>
    </div>

</body>
</html>
