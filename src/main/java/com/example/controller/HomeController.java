package com.example.controller;

import com.example.service.CrawlingService;
import com.example.model.Store;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;
import java.util.Collections;
import java.util.List;

@Controller
public class HomeController {

    @Autowired
    private CrawlingService crawlingService;

    @GetMapping("/")
    public String home(Model model,
            HttpSession session,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "서울") String city,
            @RequestParam(defaultValue = "관악구") String district,
            @RequestParam(value = "refresh", required = false) boolean refresh) {

        int pageSize = 10;
        String regionKeyword = city + " " + district;
        String sessionKey = "cachedStores_" + regionKeyword;

        // 세션에서 가져오기
        List<Store> allStores = (List<Store>) session.getAttribute(sessionKey);

        // 세션에 없거나 명시적 새로고침 요청이 있거나 지역이 변경된 경우 (키로 처리됨), 새로 크롤링
        if (allStores == null || refresh) {
            String searchKeyword = regionKeyword + " 두쫀쿠";
            allStores = crawlingService.searchStores(searchKeyword);

            // 세션에 저장 (캐시)
            session.setAttribute(sessionKey, allStores);
            // 다른 키 지우기? 간단하게 하기 위해 이것만 설정합니다.
            // 이상적으로는 메모리 절약을 위해 이전 검색을 지우고 싶겠지만, 단일 사용자/단일 세션의 경우 괜찮습니다.
            // 더 깔끔하게 하려면 "currentStores"와 "currentRegion" 속성만 사용할 수 있습니다.
            session.setAttribute("currentStores", allStores);
            session.setAttribute("currentRegionKey", regionKeyword);
        } else {
            // 지역을 전환했지만 일반 캐시에 적중했는지 확인?
            // 사실, 단순화합시다.
            // "현재 목록"을 위한 저장 공간 하나만 사용합니다.
            // 아래 로직 참조.
        }

        // 단순화된 로직: 파라미터가 변경되지 않는 한 항상 세션의 "currentStores"에 의존
        String lastRegion = (String) session.getAttribute("currentRegionKey");
        if (lastRegion == null || !lastRegion.equals(regionKeyword)) {
            // 새로운 검색 필요
            String searchKeyword = regionKeyword + " 두쫀쿠";
            allStores = crawlingService.searchStores(searchKeyword);
            session.setAttribute("currentStores", allStores);
            session.setAttribute("currentRegionKey", regionKeyword);
        } else {
            // 동일 지역, 메모리에서 가져오기
            allStores = (List<Store>) session.getAttribute("currentStores");
            if (allStores == null)
                allStores = Collections.emptyList();
        }

        // 페이지네이션 로직 (인메모리)
        int totalCount = allStores.size();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages == 0)
            totalPages = 1;

        // 인덱스 범위 초과 방지
        if (page < 1)
            page = 1;
        if (page > totalPages)
            page = totalPages;

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalCount);

        List<Store> pagedStores = Collections.emptyList();
        if (totalCount > 0 && fromIndex < totalCount) {
            pagedStores = allStores.subList(fromIndex, toIndex);
        }

        model.addAttribute("stores", pagedStores);
        model.addAttribute("mapStores", allStores);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);

        // 선택 항목을 뷰로 전달
        model.addAttribute("currentCity", city);
        model.addAttribute("currentDistrict", district);

        return "index";
    }
}
