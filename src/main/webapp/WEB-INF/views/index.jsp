<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${currentCity} ${currentDistrict} | 두쫀쿠</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Kakao Map SDK -->
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=ff09b5f692fad0cbbb8e690ace21f9c7&libraries=services"></script>
    
    <!-- Google AdSense -->
    <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-2863619342768324" crossorigin="anonymous"></script>

    <style>
        body { font-family: 'Noto Sans KR', sans-serif; }
        .gradient-text {
            background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        #map {
            width: 100%;
            height: 500px;
            border-radius: 12px;
            z-index: 10;
        }
    </style>
</head>
<body class="bg-slate-50 min-h-screen text-slate-800 flex flex-col">

    <!-- Header -->
    <header class="bg-white shadow-sm sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
            <a href="/" class="flex items-center gap-2 cursor-pointer no-underline">
                <i class="fa-solid fa-utensils text-blue-600 text-2xl"></i>
                <h1 class="text-2xl font-bold tracking-tight text-slate-900">두쫀쿠 <span class="text-xs text-blue-500 font-normal border border-blue-200 rounded px-1">Beta</span></h1>
            </a>
            <div class="flex gap-4">
                 <a href="https://github.com/Yong009/do-jjeon-coo" target="_blank" class="text-slate-500 hover:text-blue-600 transition">
                    <i class="fa-brands fa-github text-2xl"></i>
                </a>
            </div>
        </div>
    </header>

    <main class="flex-grow">
        <!-- Search Section -->
        <section class="bg-white border-b border-slate-200 pb-8 pt-8">
            <div class="max-w-4xl mx-auto px-4 text-center">
                <h2 class="text-3xl md:text-4xl font-bold mb-4">
                    실시간 <span class="gradient-text">맛집 검색</span>
                </h2>
                
                <form action="./" method="get" class="bg-white p-2 rounded-full shadow-lg border border-slate-200 flex max-w-xl mx-auto items-center">
                    <!-- City Select -->
                    <select id="citySelect" name="city" onchange="updateDistricts()" class="bg-transparent px-4 py-3 outline-none text-slate-700 cursor-pointer font-medium border-r border-slate-200">
                        <option value="서울" ${currentCity == '서울' ? 'selected' : ''}>서울</option>
                        <option value="대구" ${currentCity == '대구' ? 'selected' : ''}>대구</option>
                    </select>

                    <!-- District Select -->
                    <select id="districtSelect" name="district" class="flex-grow bg-transparent px-4 py-3 outline-none text-slate-700 cursor-pointer font-medium min-w-[100px]">
                        <!-- JS로 채워짐 -->
                    </select>

                    <button type="submit" class="bg-blue-600 text-white rounded-full px-8 py-3 font-semibold hover:bg-blue-700 transition flex items-center gap-2 m-1">
                        <i class="fa-solid fa-search"></i>
                        <span>탐색</span>
                    </button>
                </form>
                <p class="text-xs text-slate-400 mt-3">* 선택한 지역의 맛집 정보를 보여줍니다.</p>
            </div>
        </section>

        <!-- AdFit Banner Area (카카오 애드핏) -->
        <div id="kakao-adfit" class="max-w-7xl mx-auto px-4 mt-4 text-center">
            <ins class="kakao_ad_area" style="display:none;"
                data-ad-unit = "DAN-zFTiVOIXW666h4R5"
                data-ad-width = "728"
                data-ad-height = "90"></ins>
            <script type="text/javascript" src="//t1.daumcdn.net/kas/static/ba.min.js" async></script>
        </div>

        <!-- Coupang Partners Banner Area (쿠팡 파트너스) -->
        <div id="coupang-partners" class="max-w-7xl mx-auto px-4 mt-4 text-center">
            <script src="https://ads-partners.coupang.com/g.js"></script>
            <script>
                new PartnersCoupang.G({
                    "id": 961989,
                    "template": "carousel",
                    "trackingCode": "AF9667752",
                    "width": "100%",
                    "height": "140",
                    "tsource": ""
                });
            </script>
        </div>

        <!-- Map & List Section -->
        <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex flex-col md:flex-row gap-6 h-full">
            
            <!-- Map -->
            <div class="w-full md:w-1/2 h-full">
                <div id="map" class="shadow-md bg-slate-100"></div>
            </div>

            <!-- List -->
            <div class="w-full md:w-1/2 flex flex-col h-auto">
                <div class="flex justify-between items-center mb-4">
                    <h3 class="text-xl font-bold text-slate-900">검색 결과 <span class="text-blue-600 ml-1 text-base">${stores != null ? stores.size() : 0}개</span></h3>
                    <div class="text-sm text-slate-500">페이지 ${currentPage}/${totalPages}</div>
                </div>

                <div class="flex-1 overflow-y-auto pr-2 space-y-3 pb-4 max-h-[600px]">
                    <c:choose>
                        <c:when test="${not empty stores}">
                            <c:forEach var="store" items="${stores}" varStatus="status">
                                <div class="bg-white p-4 rounded-lg shadow-sm border border-slate-100 hover:shadow-md transition cursor-pointer flex justify-between items-start group">
                                    <div>
                                        <h5 class="font-bold text-slate-800 text-lg mb-1 group-hover:text-blue-600 transition">
                                            <c:choose>
                                                <c:when test="${not empty store.link}">
                                                    <a href="${store.link}" target="_blank" onclick="event.stopPropagation()" class="hover:underline">${store.name}</a>
                                                </c:when>
                                                <c:otherwise>${store.name}</c:otherwise>
                                            </c:choose>
                                        </h5>
                                        <p class="text-sm text-slate-500 mb-1">${store.address}</p>
                                        <c:if test="${not empty store.openingHours}">
                                            <p class="text-xs text-green-600 mt-1"><i class="fa-regular fa-clock"></i> ${store.openingHours}</p>
                                        </c:if>
                                    </div>
                                    <div class="text-right">
                                        <c:if test="${not empty store.link}">
                                            <a href="${store.link}" target="_blank" class="text-xs bg-slate-100 px-2 py-1 rounded text-slate-600 hover:bg-slate-200 mt-2 inline-block">상세보기</a>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-20 bg-slate-50 rounded-lg border border-dashed border-slate-300">
                                <p class="text-slate-400">해당 지역에 등록된 가게가 없습니다.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="flex justify-center gap-2 mt-4">
                        <c:if test="${currentPage > 1}">
                            <a href="?page=${currentPage - 1}&city=${currentCity}&district=${currentDistrict}" class="px-3 py-1 bg-white border border-slate-200 rounded text-slate-600 hover:bg-slate-50">이전</a>
                        </c:if>
                        
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="?page=${i}&city=${currentCity}&district=${currentDistrict}" class="px-3 py-1 ${currentPage == i ? 'bg-blue-600 text-white border-blue-600' : 'bg-white border-slate-200 text-slate-600 hover:bg-slate-50'} border rounded">${i}</a>
                        </c:forEach>
                        
                        <c:if test="${currentPage < totalPages}">
                            <a href="?page=${currentPage + 1}&city=${currentCity}&district=${currentDistrict}" class="px-3 py-1 bg-white border border-slate-200 rounded text-slate-600 hover:bg-slate-50">다음</a>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </section>
    </main>

    <footer class="bg-white border-t border-slate-200 py-6 mt-auto">
        <div class="max-w-7xl mx-auto px-4 text-center text-slate-500 text-sm">
            <p>&copy; 2026 Do-Jjeon-Coo Project. All rights reserved.</p>
        </div>
    </footer>

    <script>
        // 지역 데이터
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
            
            districtSelect.innerHTML = "";
            
            if (regionData[selectedCity]) {
                regionData[selectedCity].forEach(function(district) {
                    var option = document.createElement("option");
                    option.value = district;
                    option.text = district;
                    if (selectedCity === currentCity && district === currentDistrict) {
                        option.selected = true;
                    }
                    districtSelect.appendChild(option);
                });
            }
        }

        // 초기화
        window.addEventListener('load', function() {
            updateDistricts();
            initMap();
        });

        function initMap() {
            var mapContainer = document.getElementById('map');
            var mapOption = {
                center: new kakao.maps.LatLng(37.4782, 126.9515),
                level: 5
            };
            var map = new kakao.maps.Map(mapContainer, mapOption);
            var geocoder = new kakao.maps.services.Geocoder();
            var bounds = new kakao.maps.LatLngBounds();

            // JSP에서 주입된 데이터 (지도 표시용 전체 데이터라고 가정)
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

            if (stores.length > 0) {
                var processedCount = 0;
                stores.forEach(function(store) {
                    if (store.lat && store.lng) {
                        var coords = new kakao.maps.LatLng(store.lat, store.lng);
                        addMarker(map, coords, store.name);
                        bounds.extend(coords);
                        checkBounds();
                    } else {
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
                    if (processedCount === stores.length && !bounds.isEmpty()) {
                        map.setBounds(bounds);
                    }
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
                content: '<div style="padding:5px;font-size:12px;color:black;">' + title + '</div>'
            });

            kakao.maps.event.addListener(marker, 'click', function() {
                infowindow.open(map, marker);
            });
        }
    </script>
</body>
</html>
