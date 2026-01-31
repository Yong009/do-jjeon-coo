package com.example.util;

import com.example.mapper.StoreMapper;
import com.example.model.Store;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@SpringBootApplication
@ComponentScan(basePackages = "com.example")
public class DataExporter implements CommandLineRunner {

    @Autowired
    private StoreMapper storeMapper;

    public static void main(String[] args) {
        System.setProperty("spring.main.web-application-type", "none"); // Web 서버 실행 안 함
        SpringApplication.run(DataExporter.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        System.out.println("Starting Data Export...");

        // 1. 모든 데이터 조회
        List<Store> allStores = storeMapper.findAll();
        System.out.println("Found " + allStores.size() + " stores.");

        // 2. 지역별 그룹화 (주소 기반 단순 그룹화)
        // 예: "서울 관악구 ..." -> "관악구"
        Map<String, List<Store>> groupedData = allStores.stream()
                .collect(Collectors.groupingBy(store -> {
                    String addr = store.getAddress();
                    if (addr.contains("관악구"))
                        return "관악구";
                    if (addr.contains("강남구"))
                        return "강남구";
                    if (addr.contains("마포구"))
                        return "마포구";
                    if (addr.contains("서초구"))
                        return "서초구";
                    if (addr.contains("종로구"))
                        return "종로구";
                    if (addr.contains("대구"))
                        return "대구"; // 대구 전체
                    return "기타";
                }));

        // 3. JSON 변환 및 저장
        ObjectMapper mapper = new ObjectMapper();
        File outputFile = new File("docs/data.json");

        try {
            mapper.writerWithDefaultPrettyPrinter().writeValue(outputFile, groupedData);
            System.out.println("Successfully exported data to: " + outputFile.getAbsolutePath());
        } catch (IOException e) {
            e.printStackTrace();
            System.err.println("Failed to export data.");
        }
    }
}
