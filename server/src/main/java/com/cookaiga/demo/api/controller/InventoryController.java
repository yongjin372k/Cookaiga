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
        System.out.println("Received Ingredient Addition Request:");
        System.out.println("User ID: " + userID);
        System.out.println("Item Name: " + ingredient.getItem());
        System.out.println("Quantity: " + ingredient.getQuantityWithUnit());
        System.out.println("Expiry Date: " + ingredient.getExpiry());

        return ingredientService.addOrUpdateIngredient(ingredient, userID);
    }

    @PostMapping("/update/{id}")
    public Ingredients updateIngredient(
        @PathVariable Long id,
        @RequestBody Ingredients ingredient,
        @RequestParam Long userID
    ) {
        System.out.println("Update Ingredient Request Received");
        System.out.println("User ID: " + userID);
        System.out.println("Ingredient ID: " + id);
        System.out.println("Updated Item Name: " + ingredient.getItem());
        System.out.println("Updated Quantity: " + ingredient.getQuantityWithUnit());
        System.out.println("Updated Expiry Date: " + ingredient.getExpiry());

        return ingredientService.updateIngredient(id, ingredient, userID);
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteIngredient(@PathVariable Long id, @RequestParam Long userID) {
        ingredientService.deleteIngredient(id, userID);
        return ResponseEntity.noContent().build();
    }
}