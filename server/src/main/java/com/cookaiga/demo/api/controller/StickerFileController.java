package com.cookaiga.demo.api.controller;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.MalformedURLException;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/api/stickers")
public class StickerFileController {

    @GetMapping("/{filename}")
    public ResponseEntity<Resource> getStickerFile(@PathVariable String filename) {
        try {
            // Define the folder where stickers are stored
            Path file = Paths.get("src/main/resources/assets/stickers").resolve(filename).normalize();

            // Load the file as a resource
            Resource resource = new UrlResource(file.toUri());

            if (resource.exists()) {
                // Dynamically determine the content type
                String contentType = "image/png"; // Default MIME type
                if (filename.endsWith(".jpg") || filename.endsWith(".jpeg")) {
                    contentType = "image/jpeg";
                } else if (filename.endsWith(".gif")) {
                    contentType = "image/gif";
                }

                System.out.println("Serving sticker file: " + filename + " as " + contentType);

                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .body(resource);
            } else {
                System.out.println("Sticker file not found: " + filename);
                return ResponseEntity.notFound().build();
            }
        } catch (MalformedURLException e) {
            e.printStackTrace();
            System.err.println("Error accessing sticker file: " + filename);
            return ResponseEntity.internalServerError().build();
        }
    }
}
