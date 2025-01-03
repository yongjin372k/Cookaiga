package com.cookaiga.demo.api.service;

import com.cookaiga.demo.models.Kitchen;
import com.cookaiga.demo.api.repository.KitchenRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class KitchenService {

    @Autowired
    private KitchenRepository kitchenRepository;

    /**
     * Handles JSON data from ImageAnalysisService and updates or creates records in the kitchen table.
     */
    public void processAndSaveKitchenData(List<String> captions, int userID, Long foodID, BigDecimal quantity, String unit, LocalDate expiryDate) {
        // Convert captions list to JSON-like string (comma-separated)
        String kitchenList = String.join(", ", captions);

        // Check if a record for the user and foodID already exists
        List<Kitchen> existingItems = kitchenRepository.findByUserIDAndFoodID(userID, foodID);

        if (existingItems.isEmpty()) {
            // Create a new record
            Kitchen newKitchenItem = new Kitchen();
            newKitchenItem.setKitchenList(kitchenList); // Save captions as a single string
            newKitchenItem.setUserID(userID);
            newKitchenItem.setFoodID(foodID);
            newKitchenItem.setQuantity(quantity);
            newKitchenItem.setUnit(unit);
            newKitchenItem.setExpiryDate(expiryDate);
            newKitchenItem.setAddedAt(LocalDateTime.now());
            kitchenRepository.save(newKitchenItem);
        } else {
            // Update existing records
            for (Kitchen item : existingItems) {
                item.setKitchenList(kitchenList); // Update captions
                item.setQuantity(quantity); // Update quantity
                item.setUnit(unit); // Update unit
                item.setExpiryDate(expiryDate); // Update expiry date
                kitchenRepository.save(item);
            }
        }
    }
}
