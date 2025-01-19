package com.cookaiga.demo.api.controller;

// import com.example.inventory.model.InventoryItem;
// import com.example.inventory.service.InventoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.cookaiga.demo.api.service.InventoryService;
import com.cookaiga.demo.models.Ingredients;

import java.util.List;

@RestController
@RequestMapping("/api/ingredients")
public class InventoryController {

    private final InventoryService ingredientService;

    public InventoryController(InventoryService ingredientService) {
        this.ingredientService = ingredientService;
    }

    @GetMapping
    public List<Ingredients> getAllIngredients(@RequestParam Long userID) {
        return ingredientService.getAllIngredients(userID);
    }

    @PostMapping
    public Ingredients addOrUpdateIngredient(@RequestBody Ingredients ingredient, @RequestParam Long userID) {
        return ingredientService.addOrUpdateIngredient(ingredient, userID);
    }

    @PostMapping("/update/{id}")
    public Ingredients updateIngredient(
        @PathVariable Long id,
        @RequestBody Ingredients ingredient,
        @RequestParam(value = "userID", defaultValue = "1") Long userID // Default userID to 1
    ) {
        return ingredientService.updateIngredient(id, ingredient, userID);
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteIngredient(@PathVariable Long id, @RequestParam Long userID) {
        ingredientService.deleteIngredient(id, userID);
        return ResponseEntity.noContent().build();
    }
}