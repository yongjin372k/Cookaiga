package com.cookaiga.demo.api.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.cookaiga.demo.api.service.ImageAnalysisService;
import com.cookaiga.demo.api.service.KitchenService;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/kitchen")
public class KitchenController {

    @Autowired
    private ImageAnalysisService imageAnalysisService;

    @Autowired
    private KitchenService kitchenService;

    /**
     * Analyzes an image and saves the results in the kitchen table.
     */
    @PostMapping("/analyze-and-save")
    public List<String> analyzeAndSave(
            @RequestParam String imageUrl,
            @RequestParam int userID,
            @RequestParam Long foodID,
            @RequestParam BigDecimal quantity,
            @RequestParam String unit,
            @RequestParam(required = false) LocalDate expiryDate) {

        // Step 1: Analyze the image to get dense captions
        List<String> captions = imageAnalysisService.analyzeImageFromUrl(imageUrl);

        // Step 2: Pass captions and other parameters to KitchenService for saving/updating
        kitchenService.processAndSaveKitchenData(captions, userID, foodID, quantity, unit, expiryDate);

        // Step 3: Return the captions to the client
        return captions;
    }
}
