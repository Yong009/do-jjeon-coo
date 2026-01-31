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
            Page page = browser.newPage();

            // 최적화: 불필요한 리소스 차단
            page.route("**/*.{png,jpg,jpeg,gif,svg,css,woff,woff2}", route -> route.abort());

            page.navigate("https://map.kakao.com/?q=" + keyword);

            try {
                // 리스트 아이템 대기 (타임아웃 15초)
                page.waitForSelector("#info\\.search\\.place\\.list > li.PlaceItem",
                        new Page.WaitForSelectorOptions().setTimeout(15000));

                Locator items = page.locator("#info\\.search\\.place\\.list > li.PlaceItem");
                int count = items.count(); // 첫 페이지의 아이템 개수 (카카오는 보통 15개 표시)

                // 참고: 모든 매장을 가져오려면 지도 사이트의 페이지네이션을 처리해야 합니다.
                // 현재 로직대로 첫 페이지 결과만 스크래핑합니다.

                for (int i = 0; i < count; i++) {
                    Locator item = items.nth(i);

                    // 이름
                    Locator nameEl = item.locator(".head_item .tit_name .link_name").first();
                    String name = nameEl.innerText();

                    // 링크
                    String link = "";
                    // 1. 'moreview' 시도
                    Locator moreViewBtn = item.locator(".moreview").first();
                    if (moreViewBtn.count() > 0) {
                        String href = moreViewBtn.getAttribute("href");
                        if (href != null && !href.isEmpty() && !href.equals("#")) {
                            link = href;
                        }
                    }
                    // 2. 대체 방법
                    if (link.isEmpty() && nameEl.count() > 0) {
                        String href = nameEl.getAttribute("href");
                        if (href != null && !href.isEmpty())
                            link = href;
                    }

                    // 주소
                    String address = "";
                    if (item.locator(".info_item .addr p").count() > 0) {
                        address = item.locator(".info_item .addr p").first().innerText();
                    }

                    if (!name.isEmpty() && !address.isEmpty()) {
                        list.add(new Store(name, address, null, null, link));
                    }
                }

            } catch (Exception e) {
                // 타임아웃 무시
            }

            browser.close();
        } catch (Exception e) {
            // 설정 오류 무시
        }

        return list;
    }
}
