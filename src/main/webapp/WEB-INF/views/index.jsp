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

                
                <p class="text-xs text-slate-400 mt-3">* "선택 지역 + 두쫀쿠" 키워드로 검색된 결과를 표시합니다.</p>
                <div class="mt-6 flex justify-center">
                    <button onclick="startRoulette()" class="bg-gradient-to-r from-pink-500 to-rose-500 text-white px-6 py-2 rounded-full font-bold shadow-lg hover:shadow-xl hover:scale-105 transition flex items-center gap-2 animate-pulse">
                        <i class="fa-solid fa-dice text-xl"></i>
                        <span>오늘 뭐 먹지? (랜덤 추천)</span>
                    </button>
                </div>
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

    <!-- Roulette Modal -->
    <div id="rouletteModal" class="fixed inset-0 z-[100] flex items-center justify-center bg-black/50 backdrop-blur-sm hidden" onclick="closeRoulette()">
        <div id="rouletteBox" class="bg-white rounded-2xl p-8 max-w-sm w-[90%] text-center shadow-2xl transform transition-all scale-100" onclick="event.stopPropagation()">
            <div class="mb-6">
                <i class="fa-solid fa-utensils text-4xl text-rose-500 bg-rose-100 p-4 rounded-full"></i>
            </div>
            <h3 class="text-2xl font-bold text-slate-800 mb-2">오늘의 맛집은?</h3>
            
            <div class="my-6 py-6 border-y border-slate-100 min-h-[120px] flex flex-col justify-center items-center">
                <h2 id="rouletteResultTitle" class="text-xl font-bold text-slate-700 transition-all duration-100">
                    두구두구두구...
                </h2>
                <p id="rouletteResultMenu" class="text-sm text-slate-500 mt-2"></p>
            </div>

            <div class="flex flex-col gap-3">
                <a id="rouletteResultLink" href="#" target="_blank" class="hidden w-full bg-blue-600 text-white font-bold py-3 rounded-xl hover:bg-blue-700 transition">
                    상세보기 & 길찾기
                </a>
                <button onclick="closeRoulette()" class="w-full bg-slate-100 text-slate-600 font-bold py-3 rounded-xl hover:bg-slate-200 transition">
                    닫기
                </button>
            </div>
        </div>
    </div>
    
    <script>
        var map;
        var ps;
        var infowindow;
        var currentPlaces = []; // For roulette

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
            
            // JSP에서 선택된 값이 있으면 그것을 유지
            var cDistrict = "${currentDistrict}";
            
            districtSelect.innerHTML = "";
            
            if (regionData[selectedCity]) {
                regionData[selectedCity].forEach(function(district) {
                    var option = document.createElement("option");
                    option.value = district;
                    option.text = district;
                    if (district === cDistrict) {
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
            map = new kakao.maps.Map(mapContainer, mapOption);
            ps = new kakao.maps.services.Places();
            infowindow = new kakao.maps.InfoWindow({zIndex:1});
            
            var bounds = new kakao.maps.LatLngBounds();

            // JSP에서 주입된 데이터 (지도 표시용 전체 데이터라고 가정)
            // JSP Loop to JS Array
            var stores = [];
            <c:forEach var="store" items="${stores}" varStatus="status">
                stores.push({
                    name: "${store.name}",
                    address: "${store.address}",
                    link: "${store.link}",
                    latitude: "${store.latitude}",
                    longitude: "${store.longitude}"
                });
            </c:forEach>
            
            currentPlaces = []; // Reset for roulette
            
            // 기존 마커 표시 로직 + currentPlaces 채우기
             if (stores.length > 0) {
                var geocoder = new kakao.maps.services.Geocoder();
                
                stores.forEach(function(store) {
                    // Roulette 데이터 준비 (name, place_url 등등) -> Kakao API 구조와 맞추기 위해 변환
                    currentPlaces.push({
                        place_name: store.name,
                        place_url: store.link,
                        road_address_name: store.address
                    });

                    // 지도 마커 표시 (좌표가 있거나 주소로 검색)
                    // (JSP backend에서 좌표를 주면 베스트, 없으면 geocoder)
                    geocoder.addressSearch(store.address, function(result, status) {
                         if (status === kakao.maps.services.Status.OK) {
                            var coords = new kakao.maps.LatLng(result[0].y, result[0].x);
                            addMarker(map, coords, store.name);
                            bounds.extend(coords);
                            // 마지막에 setBounds
                            map.setBounds(bounds);
                        }
                    });
                });
            }
        }

        function addMarker(map, coords, title) {
            var marker = new kakao.maps.Marker({
                map: map,
                position: coords,
                title: title
            });
            
            var iwContent = '<div style="padding:5px;font-size:12px;color:black;">' + title + '</div>';
            var infowindow = new kakao.maps.InfoWindow({
                content: iwContent
            });

            kakao.maps.event.addListener(marker, 'click', function() {
                infowindow.open(map, marker);
            });
        }
        
        // === Roulette Logic ===
        function startRoulette() {
            if (!currentPlaces || currentPlaces.length === 0) {
                alert("먼저 지역을 검색해주세요!");
                return;
            }

            // Show Modal
            var modal = document.getElementById('rouletteModal');
            var rouletteBox = document.getElementById('rouletteBox');
            var resultTitle = document.getElementById('rouletteResultTitle');
            var resultLink = document.getElementById('rouletteResultLink');
            
            modal.classList.remove('hidden');
            resultTitle.innerText = "두구두구두구...";
            resultLink.classList.add('hidden');
            
            // Animation
            var count = 0;
            var maxCount = 20; // Number of shuffles
            var speed = 100;

            var interval = setInterval(function() {
                var randomIdx = Math.floor(Math.random() * currentPlaces.length);
                resultTitle.innerText = currentPlaces[randomIdx].place_name;
                count++;

                if (count >= maxCount) {
                    clearInterval(interval);
                    showFinalResult(currentPlaces[randomIdx]);
                }
            }, speed);
        }

        function showFinalResult(place) {
            var resultTitle = document.getElementById('rouletteResultTitle');
            var resultMenu = document.getElementById('rouletteResultMenu');
            var resultLink = document.getElementById('rouletteResultLink');
            
            // Effect
            resultTitle.classList.add('scale-125', 'text-pink-600');
            setTimeout(() => resultTitle.classList.remove('scale-125'), 200);

            resultTitle.innerHTML = '<span class="text-slate-900 text-base font-normal">오늘의 선택은...</span><br><span class="text-3xl font-bold text-pink-600">' + place.place_name + '</span>';
            if(place.road_address_name) {
                resultMenu.innerText = place.road_address_name;
            }
            
            resultLink.href = place.place_url;
            resultLink.classList.remove('hidden');
        }

        function closeRoulette() {
            document.getElementById('rouletteModal').classList.add('hidden');
        }

        // === Geolocation & Nearby Search (Simulated for JSP) ===
        // JSP는 서버 사이드 렌더링이므로, 클라이언트 위치를 받아서 Redirect하거나
        // AJAX로 다시 로딩해야 함. 여기서는 Redirect 방식을 사용.
        function searchNearby() {
            if (!navigator.geolocation) {
                alert('이 브라우저에서는 위치 정보를 지원하지 않습니다.');
                return;
            }
            
            alert("위치 정보를 기반으로 가까운 지역을 검색합니다.");

            navigator.geolocation.getCurrentPosition(function(position) {
                var lat = position.coords.latitude;
                var lng = position.coords.longitude;
                
                // Kakao Geocoder로 행정동 찾기
                var geocoder = new kakao.maps.services.Geocoder();
                geocoder.coord2RegionCode(lng, lat, function(result, status) {
                    if (status === kakao.maps.services.Status.OK) {
                         var regionName = "";
                        for(var i = 0; i < result.length; i++) {
                            // 행정동(H)을 우선 사용
                            if (result[i].region_type === 'H') {
                                regionName = result[i].region_3depth_name;
                                break;
                            }
                        }
                        if (!regionName && result.length > 0) {
                            regionName = result[0].region_3depth_name;
                        }
                        
                        if(regionName) {
                            // 단순화를 위해 query param으로 넘김 (실제로는 city/district 매핑이 필요할 수 있음)
                            // 여기서는 예시로 '서울' '관악구' 처럼 매핑 로직이 복잡하므로
                            // 단순히 검색어(regionName)를 가지고 서버에 요청하거나,
                            // 클라이언트 사이드인 docs/index.html 처럼 카카오 API 직접 호출 방식(AJAX)으로 변경해야 완벽함.
                            // JSP 구조상 서버 검색을 타야 하므로, 가장 유사한 로직으로 '검색'을 수행하도록 구현.
                            
                            // 하지만 JSP 백엔드에 '동' 단위 검색이 구현되어 있는지 불확실하므로,
                            // 여기서는 "클라이언트 사이드 렌더링 방식"을 일부 차용하거나
                            // 알림만 띄움.
                            
                            alert("현재 위치: " + regionName + "\n\n(JSP 버전에서는 해당 기능이 제한적일 수 있습니다. 정적 웹 버전을 이용해주세요.)");
                            // location.href = "./?city=서울&district=관악구"; // 예시
                        }
                    }
                });
            });
        }
    </script>
</body>
</html>
