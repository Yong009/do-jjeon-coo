import os
import sys
import random
import datetime
from PIL import Image, ImageDraw, ImageFont

# Windows 콘솔 인코딩 설정
sys.stdout.reconfigure(encoding='utf-8')

# ================================
# 1. 설정 (Settings)
# ================================
OUTPUT_DIR = "promo_output"
FONT_PATH = "C:/Windows/Fonts/malgunbd.ttf"  # 맑은 고딕 볼드 (Windows 기본)
FONT_SIZE_TITLE = 60
FONT_SIZE_SUB = 40
FONT_SIZE_TAG = 25

# 검색 키워드 리스트
SEARCH_KEYWORDS = ["두쫀쿠", "봄동비빔밥"]

# 지역 데이터 (index.html과 동일하게 유지)
REGION_DATA = {
    '서울': ['관악구', '강남구', '서초구', '마포구', '송파구', '홍대'],
    '대구': ['수성구', '중구', '동구', '달서구', '북구', '서구', '남구', '달성군', '군위군']
}

# 홍보 문구 템플릿
TITLES = [
    "광고 없는 {region} 찐맛집",
    "오늘 점심 뭐 먹지?",
    "현지인이 추천하는 {district} 맛집",
    "실패 없는 {region} {district} 맛집 지도",
    "나만 알고 싶은 {district} 숨은 맛집"
]

SUB_TITLES = [
    "두쫀쿠에서 확인하세요!",
    "직접 가보고 검증했습니다",
    "광고 0%, 순수 맛집 100%",
    "지금 바로 검색해보세요",
    "무료로 맛집 지도 보기"
]

# 배경 색상 팔레트 (파스텔 톤)
COLORS = [
    (255, 223, 186), # 살구색
    (186, 255, 201), # 연두색
    (186, 225, 255), # 하늘색
    (255, 179, 186), # 연분홍
    (255, 255, 186), # 연노랑
    (225, 247, 213), # 민트
]

def ensure_dir(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)

def draw_centered_text(draw, text, font, image_width, y_pos, color=(0, 0, 0)):
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    x_pos = (image_width - text_width) / 2
    draw.text((x_pos, y_pos), text, font=font, fill=color)
    return text_bbox[3] - text_bbox[1] # Height

def generate_promo_content(selected_keyword=None):
    ensure_dir(OUTPUT_DIR)
    
    # 1. 랜덤 데이터 선택
    city = random.choice(list(REGION_DATA.keys()))
    district = random.choice(REGION_DATA[city])
    
    title_template = random.choice(TITLES)
    title_text = title_template.format(region=city, district=district)
    
    sub_title_text = random.choice(SUB_TITLES)
    bg_color = random.choice(COLORS)
    
    # 키워드 선택 (매개변수가 있으면 사용, 없으면 랜덤)
    if selected_keyword and selected_keyword in SEARCH_KEYWORDS:
        search_keyword = selected_keyword
    else:
        search_keyword = random.choice(SEARCH_KEYWORDS)
    
    # 2. 이미지 생성 (Facebook/Instagram 용 1080x1080)
    width, height = 1080, 1080
    image = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(image)
    
    # 폰트 로드
    try:
        font_title = ImageFont.truetype(FONT_PATH, FONT_SIZE_TITLE)
        font_sub = ImageFont.truetype(FONT_PATH, FONT_SIZE_SUB)
        font_tag = ImageFont.truetype(FONT_PATH, FONT_SIZE_TAG)
        font_brand = ImageFont.truetype(FONT_PATH, 30)
    except IOError:
        print(f"[ERROR] 폰트 파일을 찾을 수 없습니다: {FONT_PATH}")
        print("기본 폰트를 사용합니다.")
        font_title = ImageFont.load_default()
        font_sub = ImageFont.load_default()
        font_tag = ImageFont.load_default()
        font_brand = ImageFont.load_default()

    # 3. 텍스트 그리기
    # 상단 브랜드
    draw.text((50, 50), "Do-Jjeon-Coo", font=font_brand, fill=(100, 100, 100))
    
    # 중앙 타이틀
    y = height / 2 - 100
    draw_centered_text(draw, "🍽️", font_title, width, y - 100)
    draw_centered_text(draw, title_text, font_title, width, y)
    draw_centered_text(draw, sub_title_text, font_sub, width, y + 100, color=(80, 80, 80))
    
    # 하단 검색창 모양
    search_box_y = y + 250
    search_box_w = 600
    search_box_h = 80
    search_box_x = (width - search_box_w) / 2
    
    draw.rectangle(
        [search_box_x, search_box_y, search_box_x + search_box_w, search_box_y + search_box_h],
        fill="white", outline=(200, 200, 200), width=2
    )
    
    # 검색어 텍스트
    search_text = f"검색창에 '{city} {district} {search_keyword}'"
    search_font = ImageFont.truetype(FONT_PATH, 35)
    
    # 검색 돋보기 아이콘 (약식 텍스트)
    draw.text((search_box_x + 30, search_box_y + 20), "🔍", font=search_font, fill=(50, 50, 50))
    draw.text((search_box_x + 100, search_box_y + 20), search_text, font=search_font, fill=(0, 0, 0))

    # 4. 파일 저장
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"promo_{city}_{district}_{timestamp}.png"
    filepath = os.path.join(OUTPUT_DIR, filename)
    image.save(filepath)
    
    return {
        "image_path": filepath,
        "city": city,
        "district": district,
        "title": title_text,
        "keyword": search_keyword
    }

if __name__ == "__main__":
    print("==========================================")
    print("      두쫀쿠 홍보 콘텐츠 생성기 v1.0")
    print("==========================================")
    
    print("\n어떤 키워드로 홍보 이미지를 만들까요?")
    for i, kw in enumerate(SEARCH_KEYWORDS, 1):
        print(f"[{i}] {kw}")
    print("[R] 랜덤 선택")
    
    choice = input("\n번호를 입력하세요 (기본값: 랜덤): ").strip().upper()
    
    selected_kw = None
    if choice.isdigit():
        idx = int(choice) - 1
        if 0 <= idx < len(SEARCH_KEYWORDS):
            selected_kw = SEARCH_KEYWORDS[idx]
    
    result = generate_promo_content(selected_kw)
    
    print("\n[SUCCESS] 이미지가 생성되었습니다!")
    print(f"👉 파일 위치: {os.path.abspath(result['image_path'])}")
    
    print("\n[COPY] 아래 내용을 복사해서 SNS에 올리세요:")
    print("------------------------------------------")
    print(f"{result['title']} 🍜")
    print("")
    print(f"매일 뭐 먹을지 고민이라면? 광고 없는 찐맛집 지도, 두쫀쿠!")
    print(f"지금 바로 '{result['city']} {result['district']}' 맛집을 확인해보세요.")
    print("")
    print(f"👉 프로필 링크 클릭 or 네이버에 '{result['keyword']}' 검색!")
    print("")
    print(f"#{result['city']}맛집 #{result['district']}맛집 #{result['keyword']} #두쫀쿠 #점심메뉴추천 #맛집지도 #노광고")
    print("------------------------------------------")
