package com.example.service;

import com.example.model.Store;
import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserType;
import com.microsoft.playwright.Locator;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Playwright;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class CrawlingService {

    // StoreMapper 제거됨 (DB 없음)

    public List<Store> searchStores(String keyword) {
        // 저장하지 않고 바로 크롤링하여 리스트 반환
        return crawlKakaoMapWithPlaywright(keyword);
    }

    private List<Store> crawlKakaoMapWithPlaywright(String keyword) {
        List<Store> list = new ArrayList<>();

        try (Playwright playwright = Playwright.create()) {
            Browser browser = playwright.chromium().launch(new BrowserType.LaunchOptions().setHeadless(true));
            // 상세 페이지 이동 시 새 탭을 쓰는 게 아니라 현재 페이지를 계속 재활용하거나 새 탭을 여닫습니다.
            // 여기서는 심플하게 메인 검색용 컨텍스트와 상세용 컨텍스트를 분리하지 않고
            // 검색 -> 리스트 파싱 -> (링크 있으면) 상세 페이지 방문 -> 뒤로가기 혹은 별도 페이지 객체 활용

            // 더 효율적인 방법: 검색 결과에서 링크만 싹 긁은 뒤, 별도의 페이지 객체로 병렬 방문 (너무 복잡해지니 순차 방문으로 구현)
            Page page = browser.newPage();
            page.route("**/*.{png,jpg,jpeg,gif,svg,css,woff,woff2}", route -> route.abort());

            page.navigate("https://map.kakao.com/?q=" + keyword);

            try {
                // 리스트 아이템 대기
                page.waitForSelector("#info\\.search\\.place\\.list > li.PlaceItem",
                        new Page.WaitForSelectorOptions().setTimeout(10000));

                Locator items = page.locator("#info\\.search\\.place\\.list > li.PlaceItem");
                int count = items.count();

                // 임시 저장용 리스트 (상세 페이지 방문을 위해 링크만 먼저 수집)
                List<Store> tempList = new ArrayList<>();

                for (int i = 0; i < count; i++) {
                    Locator item = items.nth(i);
                    String name = item.locator(".head_item .tit_name .link_name").first().innerText();
                    String address = "";
                    if (item.locator(".info_item .addr p").count() > 0) {
                        address = item.locator(".info_item .addr p").first().innerText();
                    }

                    String link = "";
                    Locator moreViewBtn = item.locator(".moreview").first();
                    if (moreViewBtn.count() > 0) {
                        String href = moreViewBtn.getAttribute("href");
                        if (href != null && !href.isEmpty() && !href.equals("#")) {
                            link = href;
                        }
                    }
                    if (link.isEmpty() && item.locator(".head_item .tit_name .link_name").count() > 0) {
                        String href = item.locator(".head_item .tit_name .link_name").getAttribute("href");
                        if (href != null && !href.isEmpty())
                            link = href;
                    }

                    if (!name.isEmpty() && !address.isEmpty()) {
                        tempList.add(new Store(name, address, null, null, link, null));
                    }
                }

                // 상세 페이지 방문하여 영업시간 추출 (속도 향상을 위해 5개까지만 제한하거나 전체 다 함)
                // 사용자 요청: "하나하나 다 들어갔다 나오게" -> 전체 수행
                for (Store store : tempList) {
                    if (store.getLink() != null && !store.getLink().isEmpty()) {
                        try {
                            Page detailPage = browser.newPage(); // 새 탭
                            detailPage.route("**/*.{png,jpg,jpeg,gif,svg,css,woff,woff2}", route -> route.abort());

                            // 로컬서버 등에서의 차단을 막기 위해 User-Agent 설정
                            // detailPage.setExtraHTTPHeaders(...); (필요시)

                            detailPage.navigate(store.getLink());

                            // 영업시간 추출
                            // 선택자: .location_present .txt_operation
                            Locator hoursEl = detailPage.locator(".location_present .txt_operation").first();
                            // 영업시간 더보기 버튼이 있을 수 있음. 단순 텍스트만 가져옴.
                            if (hoursEl.count() > 0) { // 타임아웃 없이 확인
                                String hours = hoursEl.innerText();
                                store.setOpeningHours(hours); // 예: "매일 10:00 ~ 22:00"
                            } else {
                                store.setOpeningHours("정보 없음");
                            }

                            detailPage.close();
                        } catch (Exception e) {
                            store.setOpeningHours("확인 불가");
                        }
                    } else {
                        store.setOpeningHours("-");
                    }
                    list.add(store);
                }

            } catch (Exception e) {
                e.printStackTrace();
            }

            browser.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
