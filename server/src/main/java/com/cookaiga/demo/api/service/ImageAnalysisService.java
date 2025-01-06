package com.cookaiga.demo.api.service;

import com.azure.ai.vision.imageanalysis.*;
import com.azure.ai.vision.imageanalysis.models.*;
import com.azure.core.credential.KeyCredential;
import com.cookaiga.demo.api.repository.ImageAnalysisRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ImageAnalysisService {

    @Value("${azure.vision.endpoint}")
    private String endpoint;

    @Value("${azure.vision.key}")
    private String key;

    private final ImageAnalysisRepository repository;

    public ImageAnalysisService(ImageAnalysisRepository repository) {
        this.repository = repository;
    }

    public void analyzeAndSaveKitchenList(int userID, String imageUrl) {
        // Validate endpoint and key
        if (endpoint == null || key == null || endpoint.isEmpty() || key.isEmpty()) {
            throw new IllegalStateException("Azure Vision API configuration is missing.");
        }

        // Create a synchronous Image Analysis client
        ImageAnalysisClient client = new ImageAnalysisClientBuilder()
            .endpoint(endpoint)
            .credential(new KeyCredential(key))
            .buildClient();

        try {
            // Perform image analysis
            ImageAnalysisResult result = client.analyzeFromUrl(
                imageUrl,
                Arrays.asList(VisualFeatures.DENSE_CAPTIONS),
                new ImageAnalysisOptions().setGenderNeutralCaption(true)
            );

            // Convert dense captions to a comma-separated string
            String kitchenList = result.getDenseCaptions().getValues().stream()
                .map(DenseCaption::getText)
                .collect(Collectors.joining(", "));

            // Save to the database
            repository.insertOrUpdateKitchenList(userID, kitchenList);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Image analysis failed: " + e.getMessage());
        }
    }
}
