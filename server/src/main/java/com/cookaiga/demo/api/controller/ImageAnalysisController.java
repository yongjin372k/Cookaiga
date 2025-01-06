package com.cookaiga.demo.api.controller;

import com.cookaiga.demo.api.service.ImageAnalysisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/image-analysis")
public class ImageAnalysisController {

    private final ImageAnalysisService imageAnalysisService;

    @Autowired
    public ImageAnalysisController(ImageAnalysisService imageAnalysisService) {
        this.imageAnalysisService = imageAnalysisService;
    }

    @PostMapping("/analyze")
    public ResponseEntity<String> analyzeImage(@RequestParam int userID, @RequestParam String imageUrl) {
        try {
            // Perform image analysis and save the results to the database
            imageAnalysisService.analyzeAndSaveKitchenList(userID, imageUrl);
            return ResponseEntity.ok("Kitchen list updated successfully for userID: " + userID);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }
}
