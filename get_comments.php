<?php
header("Content-Type: application/json");
$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => "Connection failed: " . $conn->connect_error]));
}

$recipeId = $_GET['recipe_id'] ?? 0;

// Use mysqli prepared statements
$stmt = $conn->prepare("
    SELECT c.*, 
           COALESCE(u.username, c.guest_name, 'Anonymous') as display_name
    FROM recipe_comments c
    LEFT JOIN users u ON c.user_id = u.id
    WHERE c.recipe_id = ? AND c.status = 'approved'  --  Only approved comments
    ORDER BY c.created_at DESC
    LIMIT 50
");
$stmt->bind_param("i", $recipeId);
$stmt->execute();

$result = $stmt->get_result();
$comments = [];
while ($row = $result->fetch_assoc()) {
    $comments[] = $row;
}

echo json_encode($comments);
$conn->close();
?>