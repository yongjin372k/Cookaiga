package com.cookaiga.demo.api.controller;

import com.cookaiga.demo.api.service.KitchenService;
import com.cookaiga.demo.models.Kitchen;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/kitchen")
public class KitchenController {

    @Autowired
    private KitchenService kitchenService;

    // Get kitchen details by userID
    @GetMapping("/user/{userID}")
    public Kitchen getKitchenByUserID(@PathVariable int userID) {
        return kitchenService.getKitchenByUserID(userID);
    }

    // Save or update kitchen list for a user
    @PostMapping("/save")
    public int saveKitchenList(@RequestParam int userID, @RequestParam String kitchenList) {
        return kitchenService.saveKitchenList(userID, kitchenList);
    }

    // Delete a kitchen item by kitchenID
    @DeleteMapping("/delete/{kitchenID}")
    public String deleteKitchenById(@PathVariable int kitchenID) {
        kitchenService.deleteKitchenById(kitchenID);
        return "Kitchen item with ID " + kitchenID + " has been deleted successfully.";
    }
}
