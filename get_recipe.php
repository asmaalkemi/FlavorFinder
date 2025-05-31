<?php 
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) die(json_encode(["error" => "Connection failed"]));


$recipeId = $_GET['id'] ?? 0;

try {
    // Prepare statement to prevent SQL injection
    $stmt = $conn->prepare("SELECT * FROM recipes WHERE id = ?");
    $stmt->bind_param("i", $recipeId);
    $stmt->execute();
    
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        http_response_code(404);
        echo json_encode(["error" => "Recipe not found"]);
        exit;
    }
    
    $recipe = $result->fetch_assoc();
    
    // Get user info if available
    if ($recipe['user_id']) {
        $userStmt = $conn->prepare("SELECT username FROM users WHERE id = ?");
        $userStmt->bind_param("i", $recipe['user_id']);
        $userStmt->execute();
        $userResult = $userStmt->get_result();
        $recipe['author'] = $userResult->fetch_assoc()['username'] ?? null;
    }
    
    echo json_encode($recipe);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => "Database error: " . $e->getMessage()]);
}

$conn->close();
?>

