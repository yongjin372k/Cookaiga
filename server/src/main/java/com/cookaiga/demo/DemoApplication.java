package com.cookaiga.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import com.cookaiga.demo.imageanalysis.ImageAnalysis;

@SpringBootApplication
public class DemoApplication implements CommandLineRunner {

    @Autowired
    private ImageAnalysis imageAnalysis;

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @Override
    public void run(String... args) {
        imageAnalysis.performImageAnalysis();
    }
}
