package com.cookaiga.demo.controller;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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

    @PostMapping("/generate-from-database")
    public ResponseEntity<List<String>> generateRecipeFromDatabase() {
        // Fetch ingredients from the database
        String ingredients = recipeService.getIngredients();

        // Generate recipe using the fetched ingredients
        String rawRecipeText = recipeService.generateRecipe(ingredients);

        // Process raw recipe text into a structured list of recipe names and remove brackets
        List<String> recipes = Arrays.stream(rawRecipeText.split("\\r?\\n|,"))
                                    .map(String::trim) // Remove leading/trailing whitespace
                                    .filter(recipe -> !recipe.isEmpty()) // Remove empty lines
                                    .map(recipe -> recipe.replace("[", "").replace("]", "")) // Remove brackets
                                    .collect(Collectors.toList());

        return ResponseEntity.ok(recipes);
    }



}