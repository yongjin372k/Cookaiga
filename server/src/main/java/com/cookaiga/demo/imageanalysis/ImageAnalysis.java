package com.cookaiga.demo.imageanalysis;

import com.azure.ai.vision.imageanalysis.*;
import com.azure.ai.vision.imageanalysis.models.*;
import com.azure.core.credential.KeyCredential;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Component
public class ImageAnalysis {

    // Inject the endpoint and key from application.properties
    @Value("${azure.vision.endpoint}")
    private String endpoint;

    @Value("${azure.vision.key}")
    private String key;

    public void performImageAnalysis() {
        // Validate endpoint and key
        if (endpoint == null || key == null || endpoint.isEmpty() || key.isEmpty()) {
            System.out.println("Missing Azure Vision API endpoint or key.");
            throw new IllegalStateException("Azure Vision API configuration is missing.");
        }

        // Create a synchronous Image Analysis client
        ImageAnalysisClient client = new ImageAnalysisClientBuilder()
            .endpoint(endpoint)
            .credential(new KeyCredential(key))
            .buildClient();

        // Perform image analysis
        ImageAnalysisResult result = client.analyzeFromUrl(
            "https://learn.microsoft.com/azure/ai-services/computer-vision/media/quickstarts/presentation.png",
            Arrays.asList(VisualFeatures.CAPTION, VisualFeatures.READ),
            new ImageAnalysisOptions().setGenderNeutralCaption(true)
        );

        // Print analysis results to the console
        System.out.println("Image analysis results:");
        System.out.println(" Caption:");
        System.out.println("   \"" + result.getCaption().getText() + "\", Confidence "
            + String.format("%.4f", result.getCaption().getConfidence()));
        System.out.println(" Read:");
        for (DetectedTextLine line : result.getRead().getBlocks().get(0).getLines()) {
            System.out.println("   Line: '" + line.getText()
                + "', Bounding polygon " + line.getBoundingPolygon());
            for (DetectedTextWord word : line.getWords()) {
                System.out.println("     Word: '" + word.getText()
                    + "', Bounding polygon " + word.getBoundingPolygon()
                    + ", Confidence " + String.format("%.4f", word.getConfidence()));
            }
        }
    }
}
