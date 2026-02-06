# 구글 검색 등록 가이드 (Google Search Console)

두쫀쿠(Do-Jjeon-Coo) 사이트가 구글 검색 결과에 잘 나오게 하려면 **Google Search Console**에 직접 등록해야 합니다. 로봇이 저절로 찾아오기를 기다리면 몇 주가 걸릴 수 있지만, 직접 등록하면 **며칠 내로** 검색 될 수 있습니다.

## 1단계: Google Search Console 접속
1. [Google Search Console](https://search.google.com/search-console/about)에 접속합니다.
2. '시작하기'를 누르고 구글 아이디로 로그인합니다.

## 2단계: 속성 추가 (사이트 등록)
1. 좌측 상단 메뉴에서 **속성 추가**를 클릭합니다.
2. **URL 접두어 (URL Prefix)** 방식을 선택합니다. (오른쪽 박스)
3. 입력창에 `https://yong009.github.io/` 를 입력하고 **계속**을 누릅니다.

## 3단계: 소유권 확인
두쫀쿠 앱은 이미 `Google Analytics` 등의 코드가 없으므로 **'HTML 태그'** 방식을 추천합니다.

1. **'HTML 태그'** 항목을 펼칩니다.
2. `<meta name="google-site-verification" ... />` 로 시작하는 코드가 보입니다.
3. 이 코드 전체를 **복사**합니다.
4. **저(Antigravity)에게 이 코드를 알려주세요.** 제가 `index.html`에 넣어드리면 바로 확인이 가능합니다.
   - 예시: "메타태그 코드는 `<meta name="google-site-verification" content="abcdefg..." />` 이거야" 라고 말해주세요.

## 4단계: 사이트맵 제출 (중요!)
소유권 확인이 끝나면, 좌측 메뉴에서 **Sitemaps**를 클릭합니다.
1. '새 사이트맵 추가' 란에 `sitemap.xml` 이라고 입력합니다.
2. **제출** 버튼을 누릅니다.
3. 상태가 '성공'이라고 뜨면 완료된 것입니다.

---
**💡 팁:**
- 등록 후 실제 검색 반영까지는 **2~3일** 정도 소요됩니다.
- 네이버에도 등록하고 싶다면 [네이버 서치어드바이저](https://searchadvisor.naver.com/)에서 같은 방식으로 `https://yong009.github.io/`를 등록하고 `sitemap.xml`을 제출하면 됩니다.
