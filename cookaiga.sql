-- Cookaiga Database --
create database if not exists cookaiga;

use cookiaga;

-- USER TABLE --
drop table user;
CREATE TABLE IF NOT EXISTS USER (
 userID INT PRIMARY KEY auto_increment,
    username VARCHAR(50) NOT NULL,
    fullname VARCHAR(50),
    password VARCHAR(255) NOT NULL,
    points INT DEFAULT 0 CHECK (points >= 0),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
SELECT * FROM USER;
-- If DROPPING USER TABLE, need DROP REDEMPTION, KITCHEN and POST first--
INSERT INTO user (userID, username, fullname, password) VALUES (1, 'johnnyt', 'John Tan', 'xxxx');
INSERT INTO user (userID, username, fullname, password) VALUES (2, 'sueL', 'Sue Lim', 'xxxx');

-- KITCHEN TABLE --
drop table kitchen;
CREATE TABLE IF NOT EXISTS KITCHEN (       -- This is the MyKitchen, Processes current items ready for cooking
 kitchenID INT PRIMARY KEY AUTO_INCREMENT,
 kitchenList TEXT,
 userID INT NOT NULL,
 added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (userID) REFERENCES user(userID)
);
SELECT * FROM KITCHEN;

-- STICKER TABLE --								-- The Collection. Use Coins to Redeem
drop table sticker;
CREATE TABLE IF NOT EXISTS STICKER (
    stickerID INT PRIMARY KEY AUTO_INCREMENT,
    stickerName VARCHAR(100) NOT NULL,
    stickerDesc TEXT,
    points_required INT NOT NULL,
    file_path VARCHAR(255) 
);
SELECT * FROM STICKER;
describe STICKER; -- INSERT ALL THE STICKERS BELOW --
INSERT INTO sticker (stickerName, stickerDesc, points_required, file_path) VALUES 
    ('Strawberry Cake Stix', 'Sweet, soft, and bursting with berry goodness — this Strawberry Cake Stix captures the charm of a deliciously layered strawberry treat, topped with whipped cream and fresh strawberries. A perfect reward for your sweetest achievements!', 60, 'assets/stickers/sample_sticks_01.png'),
    ('Cookie Cupcake Stix', 'A delightful fusion of cookie crunch and cupcake fluff — this Cookie Cupcake Stix is the ultimate treat, featuring a swirl of frosting crowned with a cookie topper. A scrumptious reward for your tastiest triumphs!', 60, 'assets/stickers/sample_sticks_02.png'),
    ('Strawberry Mille-feuille Stix', 'Elegant and irresistible, this Strawberry Mille-feuille Stix celebrates the charm of flaky pastry layers, rich cream, and sweet strawberry slices. A sophisticated reward for your most refined accomplishments!', 60, 'assets/stickers/sample_sticks_03.png'),
    ('Croissant Stix', 'Golden, buttery, and irresistibly flaky — this Croissant Stix embodies the classic charm of a perfectly baked croissant. A delightful reward for your most layered successes!', 60, 'assets/stickers/sample_sticks_04.png'),
    ('Cherry Cupcake Stix', 'Sweet and cheerful, this Cherry Cupcake Stix showcases a fluffy cupcake topped with swirls of frosting and a shiny cherry. A perfectly playful reward for your sweetest moments!', 60, 'assets/stickers/sample_sticks_05.png');


-- REDEMPTION HISTORY TABLE --
drop table redemption;
CREATE TABLE IF NOT EXISTS REDEMPTION (
    redemptionID INT PRIMARY KEY AUTO_INCREMENT,
    userID INT NOT NULL,
    stickerID INT NOT NULL,
    redeemed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES USER(userID),
    FOREIGN KEY (stickerID) REFERENCES STICKER(stickerID)
);
SELECT * FROM redemption;

-- POST TABLE --
drop table post;
CREATE TABLE IF NOT EXISTS POST (
	postID INT PRIMARY KEY AUTO_INCREMENT,
    userID INT NOT NULL,
    imagePath VARCHAR(255) NOT NULL,
    caption VARCHAR(255),
    postDate TIMESTAMP default CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES USER(userID)
);
SELECT * FROM POST;

INSERT INTO POST (userID, imagePath) VALUES -- THESE ARE SAMPLE POSTS, DONT HAVE TO INSERT ALL --
    (1, 'assets/posts/sample post 01.jpg'),
    (1, 'assets/posts/sample post 02.jpg'),
    (1, 'assets/posts/sample post 03.jpg'),
    (2, 'assets/posts/sample post 04.jpg'),	-- FOR USER ID 2 ONLY --
    (2, 'assets/posts/sample post 05.jpg'),	-- FOR USER ID 2 ONLY --
    (2, 'assets/posts/sample post 06.jpg'),	-- FOR USER ID 2 ONLY --
    (1, 'assets/posts/sample post 07.jpg'),
    (1, 'assets/posts/sample post 08.jpg'),
    (1, 'assets/posts/sample post 09.jpg'),
    (1, 'assets/posts/sample post 10.jpg');


-- Create the 'inventory_item' table
drop table ingredients;
CREATE TABLE ingredients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item VARCHAR(255) NOT NULL,
    quantity_with_unit VARCHAR(100),
    expiry DATE,
    userID INT NOT NULL
);
SELECT * FROM ingredients;

SELECT item, quantity_with_unit, expiry FROM ingredients WHERE quantity_with_unit > 0;
INSERT INTO ingredients (item, quantity_with_unit, expiry, userID)
VALUES
    -- Meats & Proteins
    ('Chicken', '2 pieces', '2025-04-01', '1'),
    ('Beef', '500 grams', '2025-04-03', '1'),
    ('Salmon Fillet', '2 pieces', '2025-04-02', '1'),
    ('Tofu', '300 grams', '2025-04-05', '1'),
    ('Egg', '12 pieces', '2025-04-10', '1'),

    -- Dairy
    ('Milk', '1 liter', '2025-04-08', '1'),
    ('Cheese', '200 grams', '2025-04-12', '1'),
    ('Yogurt', '2 cups', '2025-04-06', '1'),
    ('Butter', '250 grams', '2025-06-01', '1'),

    -- Vegetables
    ('Broccoli', '1 head', '2025-04-03', '1'),
    ('Carrot', '3 pieces', '2025-04-07', '1'),
    ('Spinach', '150 grams', '2025-04-04', '1'),
    ('Onion', '2 pieces', '2025-04-10', '1'),
    ('Tomato', '3 pieces', '2025-04-05', '1'),
    ('Garlic', '5 cloves', '2025-04-09', '1'),

    -- Grains / Pantry
    ('Rice', '1 kg', '2026-01-01', '1'),
    ('Brown Rice', '1 kg', '2026-02-15', '1'),
    ('Noodle', '500 grams', '2026-03-01', '1'),
    ('Flour', '1 kg', '2026-06-01', '1'),
    ('Sugar', '500 grams', '2026-12-31', '1'),

    -- Condiments / Misc
    ('Soy Sauce', '250 ml', '2026-08-01', '1'),
    ('Olive Oil', '500 ml', '2026-11-01', '1'),
    ('Salt', '200 grams', '2027-01-01', '1'),
    ('Black Pepper', '100 grams', '2027-01-01', '1');


