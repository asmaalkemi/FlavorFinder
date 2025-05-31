<?php 
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(['success' => false, 'message' => "Connection failed: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents('php://input'), true);
$ip = $_SERVER['REMOTE_ADDR'];

// Basic validation
if (!isset($data['comment']) || strlen($data['comment']) < 5) {
    http_response_code(400);
    die(json_encode(['success' => false, 'message' => 'Comment too short (minimum 5 characters)']));
}

if (!isset($data['recipe_id']) || !is_numeric($data['recipe_id'])) {
    http_response_code(400);
    die(json_encode(['success' => false, 'message' => 'Invalid recipe ID']));
}

try {
    // Use mysqli prepared statements for INSERT
    $stmt = $conn->prepare("INSERT INTO recipe_comments
                          (recipe_id, user_id, comment, is_anonymous, guest_name, user_ip)
                          VALUES (?, ?, ?, ?, ?, ?)");
    if ($stmt === false) {
        throw new Exception("Failed to prepare INSERT statement: " . $conn->error);
    }

    $recipe_id = (int)$data['recipe_id'];
    $user_id = isset($data['user_id']) ? (int)$data['user_id'] : null;
    $comment = htmlspecialchars($data['comment'], ENT_QUOTES, 'UTF-8');
    $is_anonymous = isset($data['is_anonymous']) ? (bool)$data['is_anonymous'] : true;
    $guest_name = isset($data['guest_name']) ? substr(htmlspecialchars($data['guest_name'], ENT_QUOTES, 'UTF-8'), 0, 32) : null;

    $stmt->bind_param("iisiss", $recipe_id, $user_id, $comment, $is_anonymous, $guest_name, $ip);
    
    if (!$stmt->execute()) {
        throw new Exception("Failed to execute INSERT statement: " . $stmt->error);
    }
    $stmt->close();

    // Update comment count
    $updateStmt = $conn->prepare("UPDATE recipes SET comment_count = COALESCE(comment_count, 0) + 1 WHERE id = ?");
    
    if ($updateStmt === false) {
        throw new Exception("Failed to prepare comment count UPDATE statement: " . $conn->error);
    }
    
    $updateStmt->bind_param("i", $recipe_id);
    
    if (!$updateStmt->execute()) {
        throw new Exception("Failed to execute comment count UPDATE statement: " . $updateStmt->error);
    }
    $updateStmt->close();

    // Return success response
    http_response_code(200);
    echo json_encode([
        'success' => true, 
        'message' => 'Comment added successfully!'
    ]);

} catch (Exception $e) {
    error_log("Comment submission error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'Error adding comment: ' . $e->getMessage()
    ]);
}

$conn->close();
?>