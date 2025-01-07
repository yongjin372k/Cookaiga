package com.cookaiga.demo.api.service;

import com.azure.ai.vision.imageanalysis.*;
import com.azure.ai.vision.imageanalysis.models.*;
import com.azure.core.credential.KeyCredential;
import com.azure.core.util.BinaryData;
import com.cookaiga.demo.api.repository.ImageAnalysisRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.InputStream;
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

    public void analyzeAndSaveKitchenList(int userID, InputStream imageStream) {
        try {
            // Validate InputStream
            if (imageStream == null || imageStream.available() <= 0) {
                throw new IllegalArgumentException("InputStream is null or empty.");
            }
    
            // Convert InputStream to BinaryData
            System.out.println("Reading InputStream...");
            byte[] buffer = imageStream.readAllBytes();
            System.out.println("InputStream length: " + buffer.length);
    
            BinaryData imageData = BinaryData.fromBytes(buffer);
            if (imageData == null || imageData.getLength() == null || imageData.getLength() <= 0) {
                throw new IllegalArgumentException("BinaryData is null or has zero length.");
            }
    
            System.out.println("BinaryData created successfully. Length: " + imageData.getLength());
    
            // Create Image Analysis client
            ImageAnalysisClient client = new ImageAnalysisClientBuilder()
                .endpoint(endpoint)
                .credential(new KeyCredential(key))
                .buildClient();
    
            // Perform image analysis
            ImageAnalysisResult result = client.analyze(
                imageData,
                Arrays.asList(VisualFeatures.DENSE_CAPTIONS),
                new ImageAnalysisOptions().setGenderNeutralCaption(true)
            );
    
            // Convert dense captions to a comma-separated string
            String kitchenList = result.getDenseCaptions().getValues().stream()
                .map(DenseCaption::getText)
                .collect(Collectors.joining(", "));
    
            System.out.println("Generated kitchen list: " + kitchenList);
    
            // Save to the database
            repository.insertOrUpdateKitchenList(userID, kitchenList);
    
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Image analysis failed: " + e.getMessage());
        }
    }
    
    
    
}
