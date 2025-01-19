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

    public List<Ingredients> getAllIngredients(Long userID) {
        return ingredientRepository.findAllByUserID(userID);
    }

    public Ingredients addOrUpdateIngredient(Ingredients newIngredient, Long userID) {
        // Check if an ingredient with the same name exists for the user
        Ingredients existingIngredient = ingredientRepository.findByItemAndUserID(newIngredient.getItem(), userID);

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
            // If not found, add the new ingredient and assign userID
            newIngredient.setUserID(userID);
            return ingredientRepository.save(newIngredient);
        }
    }

    public Ingredients updateIngredient(Long id, Ingredients updatedIngredient, Long userID) {
        return ingredientRepository.findById(id).map(existingIngredient -> {
            // Ensure the ingredient belongs to the specified user
            if (!existingIngredient.getUserID().equals(userID)) {
                throw new RuntimeException("Ingredient does not belong to the specified user");
            }
    
            // Replace fields ONLY if they are provided in the update request
            if (updatedIngredient.getItem() != null) {
                existingIngredient.setItem(updatedIngredient.getItem());
            }
            if (updatedIngredient.getQuantityWithUnit() != null) {
                // Replace the quantity with the new value
                existingIngredient.setQuantityWithUnit(updatedIngredient.getQuantityWithUnit());
            }
            if (updatedIngredient.getExpiry() != null) {
                existingIngredient.setExpiry(updatedIngredient.getExpiry());
            }
    
            // Save and return the updated ingredient
            return ingredientRepository.save(existingIngredient);
        }).orElseThrow(() -> new RuntimeException("Ingredient with ID " + id + " not found"));
    }
    

    public void deleteIngredient(Long id, Long userID) {
        Ingredients ingredient = ingredientRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Ingredient with ID " + id + " not found"));
    
        // Ensure the ingredient belongs to the user
        if (!ingredient.getUserID().equals(userID)) {
            throw new RuntimeException("Ingredient does not belong to the specified user");
        }
    
        // Delete the ingredient
        ingredientRepository.deleteById(id);
    }
    
}