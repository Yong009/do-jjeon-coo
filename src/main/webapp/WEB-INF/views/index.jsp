<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${currentCity} ${currentDistrict} 두쫀쿠 지도</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <meta name="description" content="Store List and Map">
</head>
<body>

    <header class="container">
        <div class="logo">두쫀쿠 파인더 🍪</div>
    </header>

    <main class="container hero">
        <h1>가게 목록 & 지도</h1>
        <p>크롤링된 가게 정보를 지도와 표로 확인하세요.</p>

        <div style="width: 100%; display: flex; flex-direction: column; align-items: center; gap: 2rem;">
            
            <!-- 카카오 맵 섹션 -->
            <div class="card" style="width: 100%; max-width: 800px; padding: 1rem;">
                <!-- 검색 폼 -->
                <div style="margin-bottom: 1rem; display: flex; justify-content: space-between; align-items: center;">
                    <h3 style="text-align: left;">📍 지도 위치</h3>
                    <form action="./" method="get" style="display: flex; gap: 10px;">
                        <!-- 시/도 선택 -->
                        <select id="citySelect" name="city" class="region-select" onchange="updateDistricts()">
                            <option value="서울" ${currentCity == '서울' ? 'selected' : ''}>서울</option>
                            <option value="대구" ${currentCity == '대구' ? 'selected' : ''}>대구</option>
                        </select>
                        
                        <!-- 구/군 선택 -->
                        <select id="districtSelect" name="district" class="region-select">
                            <!-- JS로 채워짐 -->
                        </select>
                        
                        <button type="submit" class="btn">검색</button>
                    </form>
                </div>
                <div id="map" style="width:100%; height:400px; border-radius: 8px;"></div>
            </div>

            <!-- 가게 목록 테이블 섹션 -->
            <div class="card" style="width: 100%; max-width: 800px; padding: 2rem;">
                <h3 style="margin-bottom: 1rem; text-align: left;">📋 가게 목록 (지역: ${currentCity} ${currentDistrict}, 페이지 ${currentPage}/${totalPages})</h3>
                
                <table class="store-table">
                    <thead>
                        <tr>
                            <th style="width: 40%;">상호명</th>
                            <th style="width: 60%;">주소</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty stores}">
                                <c:forEach var="store" items="${stores}" varStatus="status">
                                    <tr>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty store.link}">
                                                    <a href="${store.link}" target="_blank" style="color: var(--primary-color); text-decoration: none;">${store.name}</a>
                                                </c:when>
                                                <c:otherwise>
                                                    ${store.name}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${store.address}</td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="2" style="text-align: center; padding: 2rem;">
                                        ${currentCity} ${currentDistrict} 지역에 데이터가 없습니다.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- 페이지네이션 -->
                <div class="pagination" style="margin-top: 20px; text-align: center;">
                    <c:if test="${currentPage > 1}">
                        <a href="?page=${currentPage - 1}&city=${currentCity}&district=${currentDistrict}" class="page-link">&laquo; 이전</a>
                    </c:if>
                    
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <a href="?page=${i}&city=${currentCity}&district=${currentDistrict}" class="page-link ${currentPage == i ? 'active' : ''}">${i}</a>
                    </c:forEach>
                    
                    <c:if test="${currentPage < totalPages}">
                        <a href="?page=${currentPage + 1}&city=${currentCity}&district=${currentDistrict}" class="page-link">다음 &raquo;</a>
                    </c:if>
                </div>
            </div>
            
        </div>
    </main>

    <footer>
        &copy; 2024 Store Finder Project.
    </footer>

</body>

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=ff09b5f692fad0cbbb8e690ace21f9c7&libraries=services"></script>
<script>
    // 지역 데이터 설정
    var regionData = {
        '서울': ['관악구', '강남구', '서초구', '마포구', '송파구', '홍대'],
        '대구': ['수성구', '중구', '동구', '달서구', '북구', '서구', '남구', '달성군', '군위군']
    };

    var currentCity = "${currentCity}";
    var currentDistrict = "${currentDistrict}";

    function updateDistricts() {
        var citySelect = document.getElementById("citySelect");
        var districtSelect = document.getElementById("districtSelect");
        var selectedCity = citySelect.value;
        
        // 기존 옵션 지우기
        districtSelect.innerHTML = "";
        
        // 구/군 채우기
        if (regionData[selectedCity]) {
            regionData[selectedCity].forEach(function(district) {
                var option = document.createElement("option");
                option.value = district;
                option.text = district;
                
                // 일치하는 경우 선택 유지
                if (selectedCity === currentCity && district === currentDistrict) {
                    option.selected = true;
                }
                
                districtSelect.appendChild(option);
            });
        }
    }

    // 로드시 초기화
    window.addEventListener('load', function() {
        updateDistricts();
    });

    window.onload = function() { // 기존 맵 로직 ...
        updateDistricts(); // 선택 박스가 올바르게 설정되었는지 확인
        
        if (typeof kakao === 'undefined') {
            alert("카카오맵 로드 실패. 도메인 설정을 확인해주세요.");
            return;
        }

        var mapContainer = document.getElementById('map'), 
            mapOption = {
                center: new kakao.maps.LatLng(37.4782, 126.9515), 
                level: 5 
            };  

        var map = new kakao.maps.Map(mapContainer, mapOption); 
        var geocoder = new kakao.maps.services.Geocoder();
        var bounds = new kakao.maps.LatLngBounds(); 

        // 지도 마커에 'mapStores' 사용 (모든 데이터)
        var stores = [
            <c:forEach var="store" items="${mapStores}" varStatus="status">
            {
                name: "${store.name}",
                address: "${store.address}",
                lat: ${store.latitude != null ? store.latitude : 'null'},
                lng: ${store.longitude != null ? store.longitude : 'null'}
            }<c:if test="${!status.last}">,</c:if>
            </c:forEach>
        ];
        
        if (stores.length === 0) {
            console.log("표시할 가게 데이터가 없습니다.");
        }

        var processedCount = 0;

        stores.forEach(function(store) {
            // 1. DB에 좌표가 있으면 사용
            if (store.lat && store.lng) {
                var coords = new kakao.maps.LatLng(store.lat, store.lng);
                addMarker(map, coords, store.name);
                bounds.extend(coords);
                checkBounds();
            } 
            // 2. 없으면 주소 검색
            else {
                geocoder.addressSearch(store.address, function(result, status) {
                     if (status === kakao.maps.services.Status.OK) {
                        var coords = new kakao.maps.LatLng(result[0].y, result[0].x);
                        addMarker(map, coords, store.name);
                        bounds.extend(coords);
                    }
                    checkBounds();
                });
            }
        });


        function checkBounds() {
            processedCount++;
            if (processedCount === stores.length) {
                if (!bounds.isEmpty()) {
                    map.setBounds(bounds);
                }
            }
        }

        function addMarker(map, coords, title) {
            var marker = new kakao.maps.Marker({
                map: map,
                position: coords,
                title: title
            });

            var infowindow = new kakao.maps.InfoWindow({
                content: '<div style="width:150px;text-align:center;padding:6px 0;color:black;font-weight:bold;">' + title + '</div>'
            });
            infowindow.open(map, marker);
        }
    };
</script>
</html>
