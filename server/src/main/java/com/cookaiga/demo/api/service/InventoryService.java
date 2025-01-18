package com.cookaiga.demo.api.service;

import org.springframework.stereotype.Service;

import com.cookaiga.demo.api.repository.IngredientRepository;
import com.cookaiga.demo.models.Ingredients;

import java.util.List;

@Service
public class InventoryService {

    private final IngredientRepository ingredientRepository;

    public InventoryService(IngredientRepository ingredientRepository) {
        this.ingredientRepository = ingredientRepository;
    }

    public List<Ingredients> getAllIngredients() {
        return ingredientRepository.findAll();
    }

    public Ingredients addOrUpdateIngredient(Ingredients newIngredient) {
        // Check if an ingredient with the same name exists
        Ingredients existingIngredient = ingredientRepository.findByItem(newIngredient.getItem());

        if (existingIngredient != null) {
            // Parse existing quantity and unit
            String[] existingQuantityUnit = existingIngredient.getQuantityWithUnit().split(" ");
            int existingQuantity = Integer.parseInt(existingQuantityUnit[0]);
            String existingUnit = existingQuantityUnit[1];

            // Parse new quantity
            String[] newQuantityUnit = newIngredient.getQuantityWithUnit().split(" ");
            int newQuantity = Integer.parseInt(newQuantityUnit[0]);
            String newUnit = newQuantityUnit[1];

            // Ensure units are the same before combining
            if (existingUnit.equalsIgnoreCase(newUnit)) {
                // Combine quantities
                int totalQuantity = existingQuantity + newQuantity;
                existingIngredient.setQuantityWithUnit(totalQuantity + " " + existingUnit);
                existingIngredient.setExpiry(newIngredient.getExpiry());
                return ingredientRepository.save(existingIngredient);
            } else {
                throw new IllegalArgumentException("Unit mismatch: cannot combine quantities with different units");
            }
        } else {
            // If not found, add the new ingredient
            return ingredientRepository.save(newIngredient);
        }
    }

    public Ingredients updateIngredient(Long id, Ingredients updatedIngredient) {
        return ingredientRepository.findById(id).map(existingIngredient -> {
            // Validate quantity_with_unit format
            String[] quantityUnit = updatedIngredient.getQuantityWithUnit().split(" ");
            if (quantityUnit.length != 2) {
                throw new IllegalArgumentException("Invalid format for quantity_with_unit");
            }
    
            // Update fields
            existingIngredient.setItem(updatedIngredient.getItem());
            existingIngredient.setQuantityWithUnit(updatedIngredient.getQuantityWithUnit());
            existingIngredient.setExpiry(updatedIngredient.getExpiry());
    
            return ingredientRepository.save(existingIngredient);
        }).orElseThrow(() -> new RuntimeException("Ingredient not found"));
    }
    

    public void deleteIngredient(Long id) {
        ingredientRepository.deleteById(id);
    }
}