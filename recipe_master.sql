-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : sam. 31 mai 2025 à 13:09
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `recipe_master`
--

-- --------------------------------------------------------

--
-- Structure de la table `recipes`
--

CREATE TABLE `recipes` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `ingredients` text NOT NULL,
  `instructions` text NOT NULL,
  `prep_time` int(11) DEFAULT NULL,
  `cook_time` int(11) DEFAULT NULL,
  `difficulty` enum('Easy','Medium','Hard') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `calories` int(11) DEFAULT NULL,
  `protein` decimal(5,2) DEFAULT NULL,
  `carbs` decimal(5,2) DEFAULT NULL,
  `fats` decimal(5,2) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `average_rating` decimal(3,2) DEFAULT 0.00,
  `rating_count` int(11) DEFAULT 0,
  `status` varchar(20) DEFAULT (case when `user_id` = 1 then 'approved' else 'pending' end),
  `validation_issues` text DEFAULT NULL,
  `comment_count` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `recipes`
--

INSERT INTO `recipes` (`id`, `name`, `description`, `image`, `ingredients`, `instructions`, `prep_time`, `cook_time`, `difficulty`, `created_at`, `calories`, `protein`, `carbs`, `fats`, `user_id`, `average_rating`, `rating_count`, `status`, `validation_issues`, `comment_count`) VALUES
(1, 'Classic Margherita Pizza', 'Simple Italian favorite with fresh basil', 'pizza.jpg', 'flour, yeast, water, salt, tomato sauce, fresh mozzarella, basil, olive oil', '1. Make dough 2. Stretch into base 3. Add toppings 4. Bake at 475°F for 12 mins', 30, 12, 'Medium', '2025-04-03 01:22:35', NULL, NULL, NULL, NULL, NULL, 2.67, 3, 'approved', NULL, 1),
(2, 'Spaghetti Carbonara', 'Creamy Roman pasta dish', 'carbonara.jpg', 'spaghetti, eggs, pancetta, parmesan, black pepper, salt', '1. Cook pasta 2. Fry pancetta 3. Mix eggs with cheese 4. Combine quickly', 15, 15, 'Medium', '2025-04-03 01:22:35', 450, 18.50, 45.20, 15.80, NULL, 3.57, 7, 'approved', NULL, 1),
(3, 'Chocolate Chip Cookies', 'Classic American cookies', 'cookies.jpg', 'flour, butter, sugar, eggs, chocolate chips, vanilla, baking soda', '1. Cream butter/sugar 2. Add eggs 3. Mix dry ingredients 4. Bake at 375°F for 10 mins', 15, 10, 'Easy', '2025-04-03 01:22:35', NULL, NULL, NULL, NULL, NULL, 5.00, 1, 'approved', NULL, 0),
(4, 'Beef Bourguignon', 'French red wine stew', 'bourguignon.jpg', 'beef chuck, red wine, carrots, onions, mushrooms, bacon, garlic, thyme', '1. Sear beef 2. Cook vegetables 3. Simmer in wine 4. Cook 3 hours', 30, 180, 'Hard', '2025-04-03 01:22:35', 520, 38.20, 18.50, 32.40, NULL, 1.00, 1, 'approved', NULL, 0),
(5, 'Greek Salad', 'Fresh Mediterranean salad', 'salad.jpg', 'cucumber, tomato, red onion, feta, olives, olive oil, oregano', '1. Chop vegetables 2. Combine with feta 3. Dress with oil/herbs', 15, 0, 'Easy', '2025-04-03 01:22:35', NULL, NULL, NULL, NULL, NULL, 4.33, 3, 'approved', NULL, 0),
(6, 'Tiramisu', 'Italian coffee dessert', 'tiramisu.jpg', 'ladyfingers, mascarpone, coffee, eggs, sugar, cocoa', '1. Make cream 2. Dip ladyfingers 3. Layer 4. Chill overnight', 30, 0, 'Medium', '2025-04-03 01:22:35', 420, 8.20, 45.60, 22.40, NULL, 2.00, 4, 'approved', NULL, 0),
(7, 'Margherita Pizza', 'Classic Italian pizza with fresh basil', 'pizza.jpg', 'flour, yeast, water, salt, tomato sauce, fresh mozzarella, basil, olive oil', '1. Make dough 2. Stretch into base 3. Add toppings 4. Bake at 475°F for 12 mins', 30, 12, 'Medium', '2025-04-03 01:31:27', 285, 12.30, 35.70, 10.20, NULL, 0.00, 0, 'approved', NULL, 0),
(8, 'Spaghetti Carbonara', 'Creamy Roman pasta', 'carbonara.jpg', 'spaghetti, eggs, pancetta, parmesan, black pepper, salt', '1. Cook pasta 2. Fry pancetta 3. Mix eggs with cheese 4. Combine quickly', 15, 15, 'Medium', '2025-04-03 01:31:27', 450, 18.50, 45.20, 15.80, NULL, 0.00, 0, 'approved', NULL, 0),
(9, 'Risotto alla Milanese', 'Creamy saffron risotto', 'risotto.jpg', 'arborio rice, saffron, white wine, chicken stock, parmesan, onion, butter', '1. Sauté onion 2. Toast rice 3. Deglaze with wine 4. Add stock gradually 5. Stir in saffron and cheese', 10, 25, 'Hard', '2025-04-03 01:31:27', 320, 7.80, 42.30, 12.10, NULL, 0.00, 0, 'approved', NULL, 0),
(10, 'Tiramisu', 'Coffee-flavored dessert', 'tiramisu.jpg', 'ladyfingers, mascarpone, coffee, eggs, sugar, cocoa powder', '1. Make coffee 2. Prepare cream 3. Layer ingredients 4. Chill overnight', 30, 0, 'Medium', '2025-04-03 01:31:27', 420, 8.20, 45.60, 22.40, NULL, 0.00, 0, 'approved', NULL, 0),
(11, 'Minestrone Soup', 'Hearty vegetable soup', 'minestrone.jpg', 'carrots, celery, tomatoes, beans, pasta, zucchini, garlic, vegetable stock', '1. Sauté vegetables 2. Add stock 3. Simmer 30 mins 4. Add pasta and beans', 20, 30, 'Easy', '2025-04-03 01:31:27', 180, 6.50, 25.30, 5.20, NULL, 0.00, 0, 'approved', NULL, 0),
(12, 'Bruschetta', 'Toasted bread with tomato topping', 'bruschetta.jpg', 'bread, tomatoes, garlic, basil, olive oil, balsamic vinegar', '1. Toast bread 2. Mix tomatoes with other ingredients 3. Top bread', 15, 5, 'Easy', '2025-04-03 01:31:27', 150, 3.20, 18.40, 7.50, NULL, 0.00, 0, 'approved', NULL, 0),
(13, 'Osso Buco', 'Milanese braised veal shanks', 'ossobuco.jpg', 'veal shanks, white wine, carrots, celery, onion, garlic, gremolata', '1. Brown meat 2. Sauté vegetables 3. Deglaze with wine 4. Braise 2 hours', 30, 120, 'Hard', '2025-04-03 01:31:27', 480, 32.50, 12.80, 28.60, NULL, 0.00, 0, 'approved', NULL, 0),
(14, 'Panna Cotta', 'Italian cream dessert', 'pannacotta.jpg', 'heavy cream, sugar, vanilla, gelatin, berries', '1. Heat cream 2. Add gelatin 3. Pour into molds 4. Chill 4 hours', 15, 0, 'Medium', '2025-04-03 01:31:27', 320, 4.20, 25.40, 22.50, NULL, 0.00, 0, 'approved', NULL, 0),
(15, 'Beef Bourguignon', 'Red wine beef stew', 'bourguignon.jpg', 'beef chuck, red wine, carrots, onions, mushrooms, bacon, garlic, thyme', '1. Sear beef 2. Cook vegetables 3. Simmer in wine 4. Cook 3 hours', 30, 180, 'Hard', '2025-04-03 01:31:27', 520, 38.20, 18.50, 32.40, NULL, 0.00, 0, 'approved', NULL, 0),
(16, 'Coq au Vin', 'Chicken in red wine', 'coqauvin.jpg', 'chicken, red wine, mushrooms, pearl onions, bacon, garlic, thyme', '1. Brown chicken 2. Sauté vegetables 3. Deglaze with wine 4. Simmer 1.5 hours', 30, 90, 'Medium', '2025-04-03 01:31:27', 480, 34.60, 15.20, 28.70, NULL, 0.00, 0, 'approved', NULL, 0),
(17, 'Ratatouille', 'Provençal vegetable stew', 'ratatouille.jpg', 'eggplant, zucchini, bell peppers, tomatoes, onion, garlic, herbs', '1. Sauté vegetables 2. Layer in dish 3. Bake 45 mins', 30, 45, 'Easy', '2025-04-03 01:31:27', 210, 4.20, 22.50, 12.30, NULL, 0.00, 0, 'approved', NULL, 0),
(18, 'Croque Monsieur', 'French ham and cheese sandwich', 'croque.jpg', 'bread, ham, gruyere cheese, béchamel sauce, butter', '1. Make sandwich 2. Top with sauce 3. Broil until golden', 15, 10, 'Easy', '2025-04-03 01:31:27', 420, 22.50, 32.40, 21.30, NULL, 0.00, 0, 'approved', NULL, 0),
(19, 'Soufflé au Fromage', 'Cheese soufflé', 'souffle.jpg', 'eggs, cheese, milk, butter, flour, nutmeg', '1. Make béchamel 2. Fold in egg whites 3. Bake 25 mins', 20, 25, 'Hard', '2025-04-03 01:31:27', 280, 12.50, 15.20, 18.40, NULL, 0.00, 0, 'approved', NULL, 0),
(20, 'Quiche Lorraine', 'Savory bacon tart', 'quiche.jpg', 'pie crust, eggs, cream, bacon, gruyere cheese, nutmeg', '1. Blind bake crust 2. Cook filling 3. Bake 35 mins', 30, 35, 'Medium', '2025-04-03 01:31:27', 380, 15.20, 22.50, 24.30, NULL, 0.00, 0, 'approved', NULL, 0),
(21, 'Bouillabaisse', 'Provençal fish stew', 'bouillabaisse.jpg', 'fish, shellfish, tomatoes, saffron, fennel, garlic, orange zest', '1. Cook fish bones for stock 2. Add vegetables 3. Add seafood last', 45, 30, 'Hard', '2025-04-03 01:31:27', 320, 28.50, 12.40, 15.80, NULL, 0.00, 0, 'approved', NULL, 0),
(22, 'Crème Brûlée', 'Burnt cream dessert', 'cremebrulee.jpg', 'heavy cream, egg yolks, sugar, vanilla bean', '1. Heat cream 2. Mix with yolks 3. Bake in water bath 4. Caramelize sugar', 20, 40, 'Medium', '2025-04-03 01:31:27', 460, 6.20, 32.50, 32.80, NULL, 0.00, 0, 'approved', NULL, 0),
(23, 'Pad Thai', 'Thai stir-fried noodles', 'padthai.jpg', 'rice noodles, shrimp, tofu, eggs, peanuts, bean sprouts, tamarind', '1. Soak noodles 2. Stir-fry ingredients 3. Add sauce 4. Top with peanuts', 30, 15, 'Medium', '2025-04-03 01:31:27', 480, 18.50, 62.40, 15.20, NULL, 0.00, 0, 'approved', NULL, 0),
(24, 'Beef Pho', 'Vietnamese noodle soup', 'pho.jpg', 'beef bones, rice noodles, star anise, cinnamon, ginger, fish sauce', '1. Simmer broth 6 hours 2. Cook noodles 3. Assemble bowls', 60, 360, 'Hard', '2025-04-03 01:31:27', 350, 22.40, 45.20, 5.80, NULL, 0.00, 0, 'approved', NULL, 0),
(25, 'Chicken Tikka Masala', 'Indian creamy curry', 'tikka.jpg', 'chicken, yogurt, tomatoes, cream, garam masala, garlic, ginger', '1. Marinate chicken 2. Grill 3. Simmer in sauce', 30, 30, 'Medium', '2025-04-03 01:31:27', 420, 28.50, 18.40, 24.60, NULL, 0.00, 0, 'approved', NULL, 0),
(26, 'Sushi Rolls', 'Japanese vinegared rice rolls', 'sushi.jpg', 'sushi rice, nori, fish, avocado, cucumber, rice vinegar', '1. Prepare rice 2. Fill nori sheets 3. Roll tightly 4. Slice', 60, 0, 'Hard', '2025-04-03 01:31:27', 320, 12.50, 45.20, 5.40, NULL, 0.00, 0, 'approved', NULL, 0),
(27, 'Peking Duck', 'Crispy Chinese duck', 'pekingduck.jpg', 'duck, honey, soy sauce, hoisin sauce, pancakes, cucumber', '1. Dry duck 2. Glaze 3. Roast 4. Serve with pancakes', 1440, 120, 'Hard', '2025-04-03 01:31:27', 520, 32.50, 15.20, 32.40, NULL, 0.00, 0, 'approved', NULL, 0),
(28, 'Bibimbap', 'Korean mixed rice bowl', 'bibimbap.jpg', 'rice, beef, vegetables, egg, gochujang, sesame oil', '1. Cook rice 2. Prepare toppings 3. Assemble bowl 4. Add egg', 45, 15, 'Medium', '2025-04-03 01:31:27', 480, 18.50, 62.40, 15.20, NULL, 0.00, 0, 'approved', NULL, 0),
(29, 'Ramen', 'Japanese noodle soup', 'ramen.jpg', 'ramen noodles, pork belly, eggs, nori, scallions, soy sauce', '1. Make broth 2. Cook noodles 3. Assemble toppings', 60, 120, 'Hard', '2025-04-03 01:31:27', 450, 22.50, 52.30, 12.40, NULL, 0.00, 0, 'approved', NULL, 0),
(30, 'Dim Sum', 'Chinese dumplings', 'dimsum.jpg', 'pork, shrimp, dumpling wrappers, ginger, soy sauce', '1. Make filling 2. Fill wrappers 3. Steam 10 mins', 60, 10, 'Medium', '2025-04-03 01:31:27', 280, 12.50, 22.40, 12.50, NULL, 0.00, 0, 'approved', NULL, 0),
(31, 'Green Curry', 'Thai coconut curry', 'greencurry.jpg', 'chicken, coconut milk, green curry paste, eggplant, basil', '1. Cook paste 2. Add coconut milk 3. Add vegetables 4. Simmer', 20, 25, 'Easy', '2025-04-03 01:31:27', 380, 18.50, 22.40, 22.50, NULL, 0.00, 0, 'approved', NULL, 0),
(32, 'Bao Buns', 'Steamed Chinese buns', 'bao.jpg', 'pork belly, flour, yeast, sugar, hoisin sauce', '1. Make dough 2. Steam buns 3. Fill with pork', 90, 20, 'Hard', '2025-04-03 01:31:27', 320, 15.20, 35.20, 12.40, NULL, 0.00, 0, 'approved', NULL, 0),
(33, 'Kimchi Fried Rice', 'Korean spicy rice', 'kimchirice.jpg', 'rice, kimchi, spam, egg, gochujang, sesame oil', '1. Fry kimchi 2. Add rice 3. Top with egg', 10, 15, 'Easy', '2025-04-03 01:31:27', 420, 12.50, 62.40, 15.20, NULL, 0.00, 0, 'approved', NULL, 0),
(34, 'Miso Soup', 'Japanese soybean soup', 'miso.jpg', 'dashi stock, miso paste, tofu, seaweed, scallions', '1. Heat stock 2. Dissolve miso 3. Add tofu and seaweed', 5, 10, 'Easy', '2025-04-03 01:31:27', 120, 6.50, 12.40, 5.20, NULL, 0.00, 0, 'approved', NULL, 0),
(35, 'Classic Burger', 'Juicy beef patty', 'burger.jpg', 'beef patty, buns, lettuce, tomato, cheese, pickles', '1. Grill patty 2. Toast buns 3. Assemble toppings', 15, 10, 'Easy', '2025-04-03 01:31:27', 650, 32.50, 45.20, 35.40, NULL, 0.00, 0, 'approved', NULL, 0),
(36, 'Mac & Cheese', 'Creamy pasta bake', 'macncheese.jpg', 'macaroni, cheddar, milk, butter, flour, breadcrumbs', '1. Cook pasta 2. Make cheese sauce 3. Bake 20 mins', 20, 25, 'Easy', '2025-04-03 01:31:27', 520, 18.50, 62.40, 22.50, NULL, 0.00, 0, 'approved', NULL, 0),
(37, 'BBQ Ribs', 'Sticky pork ribs', 'ribs.jpg', 'pork ribs, BBQ sauce, brown sugar, paprika, garlic powder', '1. Season ribs 2. Slow cook 3. Glaze with sauce', 15, 240, 'Medium', '2025-04-03 01:31:27', 680, 42.50, 32.40, 42.50, NULL, 0.00, 0, 'approved', NULL, 0),
(38, 'Pancakes', 'Fluffy breakfast staple', 'pancakes.jpg', 'flour, eggs, milk, baking powder, butter, maple syrup', '1. Mix batter 2. Cook on griddle 3. Serve with syrup', 10, 15, 'Easy', '2025-04-03 01:31:27', 320, 8.20, 45.20, 12.40, NULL, 0.00, 0, 'approved', NULL, 0),
(39, 'Clam Chowder', 'New England soup', 'chowder.jpg', 'clams, potatoes, bacon, cream, onions, celery', '1. Cook bacon 2. Sauté vegetables 3. Add clams and cream', 20, 30, 'Medium', '2025-04-03 01:31:27', 280, 12.50, 22.40, 15.20, NULL, 0.00, 0, 'approved', NULL, 0),
(40, 'Fried Chicken', 'Crispy Southern-style', 'friedchicken.jpg', 'chicken, buttermilk, flour, spices, oil', '1. Marinate chicken 2. Dredge in flour 3. Fry until golden', 240, 15, 'Medium', '2025-04-03 01:31:27', 520, 32.50, 25.20, 32.40, NULL, 0.00, 0, 'approved', NULL, 0),
(41, 'Apple Pie', 'Classic American dessert', 'applepie.jpg', 'apples, pie crust, sugar, cinnamon, butter', '1. Prepare filling 2. Fill crust 3. Bake 45 mins', 30, 45, 'Medium', '2025-04-03 01:31:27', 420, 4.20, 68.50, 15.20, NULL, 0.00, 0, 'approved', NULL, 0),
(42, 'Cornbread', 'Southern-style bread', 'cornbread.jpg', 'cornmeal, flour, buttermilk, eggs, baking powder', '1. Mix batter 2. Bake in skillet 3. Serve warm', 10, 25, 'Easy', '2025-04-03 01:31:27', 280, 6.50, 42.40, 8.50, NULL, 0.00, 0, 'approved', NULL, 0),
(43, 'Hummus', 'Chickpea dip', 'hummus.jpg', 'chickpeas, tahini, lemon, garlic, olive oil', '1. Blend ingredients 2. Drizzle with oil', 10, 0, 'Easy', '2025-04-03 01:31:27', 180, 5.20, 15.40, 10.20, NULL, 0.00, 0, 'approved', NULL, 0),
(44, 'Falafel', 'Fried chickpea balls', 'falafel.jpg', 'chickpeas, parsley, garlic, cumin, flour', '1. Blend mixture 2. Form balls 3. Fry until crisp', 30, 15, 'Medium', '2025-04-03 01:31:27', 320, 12.50, 25.40, 15.20, NULL, 0.00, 0, 'approved', NULL, 0),
(45, 'Shakshuka', 'Eggs poached in tomato sauce', 'shakshuka.jpg', 'eggs, tomatoes, bell peppers, onions, cumin, paprika', '1. Cook sauce 2. Make wells for eggs 3. Simmer until set', 15, 20, 'Easy', '2025-04-03 01:31:27', 280, 15.20, 12.40, 18.50, NULL, 0.00, 0, 'approved', NULL, 0),
(46, 'Baklava', 'Sweet nut pastry', 'baklava.jpg', 'phyllo dough, walnuts, honey, butter, cinnamon', '1. Layer dough and nuts 2. Bake 3. Pour syrup', 45, 45, 'Hard', '2025-04-03 01:31:27', 420, 8.50, 52.40, 22.50, NULL, 0.00, 0, 'approved', NULL, 0),
(47, 'Tabbouleh', 'Herb salad', 'tabbouleh.jpg', 'bulgur, parsley, mint, tomatoes, lemon, olive oil', '1. Soak bulgur 2. Chop herbs 3. Mix ingredients', 30, 0, 'Easy', '2025-04-03 01:31:27', 180, 5.20, 22.40, 8.50, NULL, 0.00, 0, 'approved', NULL, 0),
(48, 'Kofta Kebabs', 'Spiced meat skewers', 'kofta.jpg', 'ground lamb, onion, parsley, cumin, coriander', '1. Mix ingredients 2. Form skewers 3. Grill 10 mins', 20, 10, 'Medium', '2025-04-03 01:31:27', 320, 22.50, 12.40, 18.50, NULL, 0.00, 0, 'approved', NULL, 0),
(49, 'Tacos al Pastor', 'Marinated pork tacos', 'tacos.jpg', 'pork, pineapple, corn tortillas, onion, cilantro', '1. Marinate pork 2. Grill 3. Serve in tortillas', 120, 20, 'Medium', '2025-04-03 01:31:27', 320, 22.50, 25.40, 15.20, NULL, 0.00, 0, 'approved', NULL, 0),
(50, 'Mole Poblano', 'Complex chili-chocolate sauce', 'mole.jpg', 'chicken, chocolate, chilies, nuts, spices', '1. Toast ingredients 2. Blend 3. Simmer with chicken', 60, 120, 'Hard', '2025-04-03 01:31:27', 480, 32.50, 22.40, 28.50, NULL, 0.00, 0, 'approved', NULL, 0),
(51, 'Chiles Rellenos', 'Stuffed peppers', 'rellenos.jpg', 'poblano peppers, cheese, eggs, tomato sauce', '1. Roast peppers 2. Stuff 3. Batter and fry', 45, 20, 'Hard', '2025-04-03 01:31:27', 380, 18.50, 32.40, 18.50, NULL, 0.00, 0, 'approved', NULL, 0),
(52, 'Guacamole', 'Avocado dip', 'guacamole.jpg', 'avocados, lime, onion, cilantro, tomato', '1. Mash avocados 2. Mix ingredients 3. Season', 15, 0, 'Easy', '2025-04-03 01:31:27', 220, 2.50, 12.40, 18.50, NULL, 0.00, 0, 'approved', NULL, 0),
(53, 'Chocolate Soufflé', 'Light chocolate dessert', 'soufflechoc.jpg', 'chocolate, eggs, sugar, butter, flour', '1. Melt chocolate 2. Fold in egg whites 3. Bake 18 mins', 30, 18, 'Hard', '2025-04-03 01:31:27', 320, 8.50, 42.40, 15.20, NULL, 0.00, 0, 'approved', NULL, 0),
(54, 'Crêpes', 'French thin pancakes', 'crepes.jpg', 'flour, eggs, milk, butter, sugar', '1. Make batter 2. Cook in pan 3. Fill as desired', 10, 20, 'Medium', '2025-04-03 01:31:27', 220, 6.50, 32.40, 8.50, NULL, 0.00, 0, 'approved', NULL, 0),
(55, 'Cheesecake', 'Creamy New York-style', 'cheesecake.jpg', 'cream cheese, sugar, eggs, graham crackers, butter', '1. Make crust 2. Prepare filling 3. Bake 1 hour', 30, 60, 'Medium', '2025-04-03 01:31:27', 520, 8.50, 45.20, 32.40, NULL, 3.00, 1, 'approved', NULL, 0),
(56, 'Panna Cotta', 'Italian set cream', 'pannacotta.jpg', 'cream, sugar, gelatin, vanilla, berries', '1. Heat cream 2. Add gelatin 3. Chill 4 hours', 15, 0, 'Easy', '2025-04-03 01:31:27', 320, 4.20, 25.40, 22.50, NULL, 0.00, 0, 'approved', NULL, 0),
(57, 'kesra', 'flat algerian semolina bread', NULL, 'semolina,oil,baking powder', 'make dough, let it rest, bake', 20, 5, 'Easy', '2025-04-03 20:51:18', NULL, NULL, NULL, NULL, 1, 0.00, 0, 'approved', NULL, 0),
(58, 'orange juice', 'orange', NULL, 'orange,water', 'blend ing', 2, 2, 'Easy', '2025-04-15 12:38:45', NULL, NULL, NULL, NULL, 1, 0.00, 0, 'approved', NULL, 0),
(59, 'hot chocolate', 'warm', NULL, 'chocolate,milk', 'heat up milk and choco', 5, 5, 'Easy', '2025-04-16 00:18:22', NULL, NULL, NULL, NULL, 1, 0.00, 0, 'approved', NULL, 0),
(60, 'salted popcorn', 'salty popcorn', NULL, 'kernels,salt,oil', '1.add oil and salt to a pan 2. add the kernels 3.wait til they pop', 5, 15, 'Easy', '2025-04-22 21:42:37', NULL, NULL, NULL, NULL, 2, 0.00, 0, 'rejected', '[\"measurements\",\"cooking_verbs\"]', 0),
(64, 'hi', 'hhh', NULL, 'yeast,flour', 'cook,clean', 3, 4, 'Hard', '2025-05-30 13:00:52', NULL, NULL, NULL, NULL, 2, 0.00, 0, 'rejected', '[\"measurements\",\"cooking_verbs\"]', 0),
(65, 'sandwitch', 'ds', NULL, 'fgh,jfj', 'dfj,fjd', 2, 2, 'Easy', '2025-05-30 13:08:06', NULL, NULL, NULL, NULL, 2, 0.00, 0, 'rejected', '[\"ingredients\",\"measurements\",\"cooking_verbs\"]', 0),
(66, 'fries air fried ', 'air frayed Fries ', NULL, 'potatos,salt,paprica ', 'cut the potato, season it, bake at 180c', 5, 15, 'Easy', '2025-05-30 15:55:24', NULL, NULL, NULL, NULL, 2, 0.00, 0, 'approved', '[\"measurements\"]', 0),
(67, 'brownie', 'hi', NULL, 'jsp', 'jsp', 10, 4, 'Easy', '2025-05-30 21:49:49', NULL, NULL, NULL, NULL, 2, 0.00, 0, 'pending', '[\"ingredients\",\"measurements\",\"cooking_verbs\"]', 0);

-- --------------------------------------------------------

--
-- Structure de la table `recipe_comments`
--

CREATE TABLE `recipe_comments` (
  `id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `comment` text NOT NULL,
  `is_anonymous` tinyint(1) DEFAULT 0,
  `guest_name` varchar(32) DEFAULT NULL,
  `user_ip` varchar(45) NOT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `recipe_comments`
--

INSERT INTO `recipe_comments` (`id`, `recipe_id`, `user_id`, `comment`, `is_anonymous`, `guest_name`, `user_ip`, `status`, `created_at`) VALUES
(1, 1, NULL, 'im so scared', 1, NULL, '::1', 'rejected', '2025-04-04 23:10:37'),
(2, 1, NULL, 'im so scared', 1, NULL, '::1', 'rejected', '2025-04-04 23:10:43'),
(3, 1, NULL, 'im so scared', 1, NULL, '::1', 'rejected', '2025-04-04 23:10:47'),
(4, 1, NULL, 'scared', 1, NULL, '::1', 'rejected', '2025-04-04 23:11:00'),
(5, 1, NULL, 'scared', 1, NULL, '::1', 'rejected', '2025-04-04 23:11:04'),
(6, 5, NULL, 'yes!!!!', 1, NULL, '::1', 'pending', '2025-04-04 23:12:12'),
(7, 6, NULL, 'fave!!!!!!!', 1, NULL, '::1', 'pending', '2025-04-05 00:09:11'),
(8, 6, NULL, 'absolute favorite', 1, NULL, '::1', 'pending', '2025-04-05 00:09:28'),
(9, 2, NULL, 'looks good', 1, NULL, '::1', 'pending', '2025-04-05 22:01:59'),
(10, 2, NULL, '!!!!!!!!!!!!!!!!!!', 1, NULL, '::1', 'pending', '2025-04-08 23:42:02'),
(11, 2, NULL, '!!!!!!!!!!!!!!!!!!', 1, NULL, '::1', 'pending', '2025-04-08 23:42:05'),
(12, 5, 2, 'loveeee this', 0, NULL, '::1', 'approved', '2025-04-14 20:00:05'),
(13, 5, 2, 'love this!!!', 0, NULL, '::1', 'pending', '2025-04-14 20:00:20'),
(14, 5, 2, 'yes yes yes', 0, NULL, '::1', 'approved', '2025-04-14 20:00:30'),
(15, 55, NULL, 'i love cheesecake', 1, NULL, '::1', 'pending', '2025-04-15 12:06:14'),
(16, 55, NULL, 'i love cheesecake', 1, NULL, '::1', 'pending', '2025-04-15 12:06:16'),
(17, 3, 1, 'cookies hit', 0, NULL, '::1', 'pending', '2025-04-15 12:35:46'),
(18, 6, 1, 'tiramisu yes', 0, NULL, '::1', 'approved', '2025-04-23 10:12:27'),
(19, 2, 1, 'best classic', 0, NULL, '::1', 'approved', '2025-05-30 15:56:40'),
(20, 5, 1, 'perfect for summer', 0, NULL, '::1', 'pending', '2025-05-30 15:57:35'),
(21, 6, 2, 'i need to try this', 0, NULL, '::1', 'pending', '2025-05-30 20:05:35'),
(22, 5, 2, 'perfect and fresh', 0, NULL, '::1', 'pending', '2025-05-30 20:31:43'),
(23, 1, 2, 'i wish to try', 0, NULL, '::1', 'pending', '2025-05-30 20:32:06'),
(24, 1, 2, 'pizaaaaaaaaaaaaaaa', 0, NULL, '::1', 'pending', '2025-05-30 20:37:20'),
(25, 2, NULL, 'i love patsta', 1, NULL, '::1', 'pending', '2025-05-30 20:39:41'),
(26, 2, NULL, 'i love patsta', 1, NULL, '::1', 'pending', '2025-05-30 20:39:47'),
(27, 2, NULL, 'i love patsta', 1, NULL, '::1', 'pending', '2025-05-30 20:41:03'),
(28, 1, NULL, 'love this', 1, NULL, '::1', 'approved', '2025-05-30 20:45:44'),
(29, 2, 2, 'yummmm', 0, NULL, '::1', 'pending', '2025-05-30 22:21:51');

-- --------------------------------------------------------

--
-- Structure de la table `recipe_ratings`
--

CREATE TABLE `recipe_ratings` (
  `id` int(11) NOT NULL,
  `recipe_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `is_anonymous` tinyint(1) DEFAULT 0,
  `user_ip` varchar(45) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `recipe_ratings`
--

INSERT INTO `recipe_ratings` (`id`, `recipe_id`, `user_id`, `rating`, `is_anonymous`, `user_ip`, `created_at`) VALUES
(1, 6, NULL, 1, 1, '::1', '2025-04-04 23:09:31'),
(2, 6, NULL, 1, 1, '::1', '2025-04-04 23:09:31'),
(3, 1, NULL, 2, 1, '::1', '2025-04-04 23:10:46'),
(4, 1, NULL, 2, 1, '::1', '2025-04-04 23:10:46'),
(5, 5, NULL, 5, 1, '::1', '2025-04-04 23:12:01'),
(6, 5, NULL, 5, 1, '::1', '2025-04-04 23:12:01'),
(7, 6, NULL, 2, 1, '::1', '2025-04-05 00:09:35'),
(8, 2, NULL, 3, 1, '::1', '2025-04-05 22:01:36'),
(9, 2, NULL, 3, 1, '::1', '2025-04-05 22:01:40'),
(10, 2, NULL, 3, 1, '::1', '2025-04-05 22:01:45'),
(11, 2, NULL, 3, 1, '::1', '2025-04-08 23:41:43'),
(12, 2, NULL, 3, 1, '::1', '2025-04-08 23:41:47'),
(13, 5, 2, 3, 0, '::1', '2025-04-14 19:59:53'),
(14, 55, NULL, 3, 1, '::1', '2025-04-15 12:06:51'),
(15, 2, 1, 5, 0, '::1', '2025-04-15 12:35:15'),
(16, 3, 1, 5, 0, '::1', '2025-04-15 12:35:53'),
(17, 1, 1, 4, 0, '::1', '2025-04-15 20:42:30'),
(18, 2, 1, 5, 0, '::1', '2025-04-15 20:42:42'),
(19, 4, 1, 1, 0, '::1', '2025-04-15 20:43:00'),
(20, 6, 1, 4, 0, '::1', '2025-04-23 10:12:05');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_admin` tinyint(1) DEFAULT 0,
  `dob` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `created_at`, `is_admin`, `dob`) VALUES
(1, 'hana', '$2y$10$MTUbQ/oc0cznehD4cEJdXuys.SrJBJvCbyKjBqHhSh3yAQWUBDYyy', 'hana@gmail.com', '2025-04-03 20:46:58', 1, NULL),
(2, 'numerodeux', '$2y$10$94toiFSL4KJ4KSt0ElAB4eOhABRZMS0hcbgIvdFnLnFetGdJOth0W', 'deuxdeux@gmail.com', '2025-04-13 23:44:43', 0, NULL),
(3, 'starlight', '$2y$10$QtnL.GP3P.qk3esei2sY3u9tS3UaW0Sg3ilaEmMZXv50pyzahxZYW', 'starlight@gmail.com', '2025-05-06 10:29:38', 0, NULL),
(4, 'asma', '$2y$10$gmHHnyczUFCLMHMgc33X9O.THnHe5tBa8meyx/UmNI0Tlw25CtSWW', 'asmaalkemo@gmail.com', '2025-05-13 20:20:43', 1, NULL);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `recipes`
--
ALTER TABLE `recipes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `recipe_comments`
--
ALTER TABLE `recipe_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_comments_recipe` (`recipe_id`);

--
-- Index pour la table `recipe_ratings`
--
ALTER TABLE `recipe_ratings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_ratings_recipe` (`recipe_id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `recipes`
--
ALTER TABLE `recipes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT pour la table `recipe_comments`
--
ALTER TABLE `recipe_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT pour la table `recipe_ratings`
--
ALTER TABLE `recipe_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `recipe_comments`
--
ALTER TABLE `recipe_comments`
  ADD CONSTRAINT `recipe_comments_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`),
  ADD CONSTRAINT `recipe_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Contraintes pour la table `recipe_ratings`
--
ALTER TABLE `recipe_ratings`
  ADD CONSTRAINT `recipe_ratings_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`),
  ADD CONSTRAINT `recipe_ratings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
