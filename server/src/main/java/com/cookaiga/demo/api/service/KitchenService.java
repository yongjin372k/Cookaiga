package com.cookaiga.demo.api.service;

import com.cookaiga.demo.api.repository.KitchenRepository;
import com.cookaiga.demo.models.Kitchen;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class KitchenService {

    @Autowired
    private KitchenRepository kitchenRepository;

    // Create or update kitchen list for a user
    public int saveKitchenList(int userID, String kitchenList) {
        return kitchenRepository.insertOrUpdateKitchenList(userID, kitchenList);
    }

    // Get kitchen details by user ID
    public Kitchen getKitchenByUserID(int userID) {
        return kitchenRepository.findByUserID(userID);
    }

    // Delete a kitchen item by kitchenID
    public void deleteKitchenById(int kitchenID) {
        if (!kitchenRepository.existsById(kitchenID)) {
            throw new RuntimeException("Kitchen not found with ID: " + kitchenID);
        }
        kitchenRepository.deleteById(kitchenID);
    }
}
