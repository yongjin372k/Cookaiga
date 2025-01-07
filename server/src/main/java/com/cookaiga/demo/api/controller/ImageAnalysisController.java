package com.cookaiga.demo.api.controller;

import com.cookaiga.demo.api.service.ImageAnalysisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/image-analysis")
public class ImageAnalysisController {

    private final ImageAnalysisService imageAnalysisService;

    @Autowired
    public ImageAnalysisController(ImageAnalysisService imageAnalysisService) {
        this.imageAnalysisService = imageAnalysisService;
    }

    @PostMapping("/analyze")
    public ResponseEntity<Map<String, String>> analyzeImage(
            @RequestParam int userID,
            @RequestParam("imageUrl") MultipartFile imageFile) {
        Map<String, String> response = new HashMap<>();

        try {
            // Log file details
            System.out.println("File name: " + imageFile.getOriginalFilename());
            System.out.println("File size: " + imageFile.getSize() + " bytes");

            // Check if the file is empty
            if (imageFile.isEmpty()) {
                response.put("error", "Uploaded file is empty.");
                return ResponseEntity.badRequest().body(response);
            }

            // Process the file
            try (InputStream imageStream = imageFile.getInputStream()) {
                if (imageStream.available() <= 0) {
                    response.put("error", "Uploaded file stream is empty.");
                    return ResponseEntity.badRequest().body(response);
                }

                imageAnalysisService.analyzeAndSaveKitchenList(userID, imageStream);
                response.put("message", "Kitchen list updated successfully");
                response.put("userID", String.valueOf(userID));
                return ResponseEntity.ok(response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.put("error", "Error analyzing the image: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
}
