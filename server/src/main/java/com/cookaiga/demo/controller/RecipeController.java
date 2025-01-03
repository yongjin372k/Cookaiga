package com.cookaiga.demo.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cookaiga.demo.service.RecipeService;

@RestController
@RequestMapping("/api/recipes")
public class RecipeController {

    private final RecipeService recipeService;

    public RecipeController(RecipeService recipeService) {
        this.recipeService = recipeService;
    }

    @GetMapping("/ingredients")
    public ResponseEntity<String> getIngredients() {
        return ResponseEntity.ok(recipeService.getIngredients());
    }

    @PostMapping("/generate")
    public ResponseEntity<String> generateRecipe(@RequestBody Map<String, String> request) {
        String ingredients = request.get("ingredients");
        return ResponseEntity.ok(recipeService.generateRecipe(ingredients));
    }
}