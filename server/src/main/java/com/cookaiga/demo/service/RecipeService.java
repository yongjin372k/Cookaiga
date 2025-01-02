package com.cookaiga.demo.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class RecipeService {

    private final RestTemplate restTemplate;

    public RecipeService(RestTemplateBuilder restTemplateBuilder) {
        this.restTemplate = restTemplateBuilder.build();
    }

    public String getIngredients() {
        String apiUrl = "http://localhost:5000/ingredients";
        ResponseEntity<Map> response = restTemplate.getForEntity(apiUrl, Map.class);

        if (response.getStatusCode() == HttpStatus.OK) {
            return response.getBody().get("ingredients").toString();
        } else {
            throw new RuntimeException("Failed to fetch ingredients");
        }
    }

    public String generateRecipe(String ingredients) {
        String apiUrl = "http://localhost:5000/generate-recipe";
        Map<String, String> request = new HashMap<>();
        request.put("ingredients", ingredients);

        HttpEntity<Map<String, String>> entity = new HttpEntity<>(request);
        ResponseEntity<Map> response = restTemplate.postForEntity(apiUrl, entity, Map.class);

        if (response.getStatusCode() == HttpStatus.OK) {
            return response.getBody().get("recipe").toString();
        } else {
            throw new RuntimeException("Failed to generate recipe");
        }
    }
}