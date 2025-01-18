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
    public List<Ingredients> getAllIngredients() {
        return ingredientService.getAllIngredients();
    }

    @PostMapping
    public Ingredients addOrUpdateIngredient(@RequestBody Ingredients ingredient) {
        return ingredientService.addOrUpdateIngredient(ingredient);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteIngredient(@PathVariable Long id) {
        ingredientService.deleteIngredient(id);
        return ResponseEntity.noContent().build();
    }
}