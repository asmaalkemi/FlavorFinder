<?php
header("Content-Type: application/json");
$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => "Connection failed: " . $conn->connect_error]));
}

$recipeId = $_GET['recipe_id'] ?? 0;
$userId = $_GET['user_id'] ?? null;

// Get average rating and count
$stmt = $conn->prepare("SELECT AVG(rating) as average_rating, COUNT(*) as rating_count 
                        FROM recipe_ratings 
                        WHERE recipe_id = ?");
$stmt->bind_param("i", $recipeId);
$stmt->execute();
$result = $stmt->get_result();
$ratings = $result->fetch_assoc();

// Get user's rating if provided
$userRating = null;
if ($userId) {
    $stmt = $conn->prepare("SELECT rating FROM recipe_ratings 
                            WHERE recipe_id = ? AND user_id = ?");
    $stmt->bind_param("ii", $recipeId, $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($row = $result->fetch_assoc()) {
        $userRating = $row['rating'];
    }
}

echo json_encode([
    'success' => true,
    'average_rating' => $ratings['average_rating'] ? (float)$ratings['average_rating'] : 0,
    'rating_count' => (int)$ratings['rating_count'],
    'user_rating' => $userRating
]);

$conn->close();
?>