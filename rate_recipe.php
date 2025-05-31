<?php
header("Content-Type: application/json");
$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => "Connection failed: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents('php://input'), true);
$ip = $_SERVER['REMOTE_ADDR'];

// Validate rating
if (!isset($data['rating']) || $data['rating'] < 1 || $data['rating'] > 5) {
    http_response_code(400);
    die(json_encode(['success' => false, 'message' => 'Invalid rating']));
}

try {
    // Use mysqli prepared statements instead of PDO
    $stmt = $conn->prepare("INSERT INTO recipe_ratings 
                          (recipe_id, user_id, rating, is_anonymous, user_ip)
                          VALUES (?, ?, ?, ?, ?)
                          ON DUPLICATE KEY UPDATE rating = VALUES(rating)");
    
    $user_id = $data['user_id'] ?? null;
    $is_anonymous = $data['is_anonymous'] ?? false;
    $stmt->bind_param("iiiss", $data['recipe_id'], $user_id, $data['rating'], $is_anonymous, $ip);
    $stmt->execute();
    
    // Update recipe's average rating
    $recipe_id = $data['recipe_id'];
    $conn->query("UPDATE recipes SET 
                average_rating = (
                    SELECT AVG(rating) 
                    FROM recipe_ratings 
                    WHERE recipe_id = $recipe_id
                ),
                rating_count = (
                    SELECT COUNT(*) 
                    FROM recipe_ratings 
                    WHERE recipe_id = $recipe_id
                )
                WHERE id = $recipe_id");
    
    echo json_encode(['success' => true]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
$conn->close();
?>