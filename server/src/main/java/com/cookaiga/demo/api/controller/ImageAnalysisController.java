package com.cookaiga.demo.api.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.cookaiga.demo.api.service.ImageAnalysisService;

import java.util.List;

@RestController
@RequestMapping("/api/image-analysis")
public class ImageAnalysisController {

    @Autowired
    private ImageAnalysisService imageAnalysisService;

    @PostMapping("/analyze")
    public List<String> analyzeImage(@RequestParam String imageUrl) {
        return imageAnalysisService.analyzeImageFromUrl(imageUrl);
    }
}
