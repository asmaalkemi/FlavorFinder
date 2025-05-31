<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
session_start();

// Database connection
$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => "Database connection failed"]));
}

// Authentication check
if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'message' => 'Not authenticated']);
    exit;
}

// Get input data
$data = json_decode(file_get_contents('php://input'), true);

// Basic validation
$required = ['name', 'ingredients', 'instructions'];
foreach ($required as $field) {
    if (empty($data[$field])) {
        echo json_encode(['success' => false, 'message' => "$field is required"]);
        exit;
    }
}

// AI Recipe Validation (simple version)
function validateRecipe($recipeData) {
    $text = strtolower(implode(' ', [
        $recipeData['name'],
        $recipeData['ingredients'],
        $recipeData['instructions']
    ]));

    $checks = [
        'ingredients' => preg_match('/(salt|pepper|oil|butter|flour|sugar|egg|milk)/', $text),
        'measurements' => preg_match('/\d+\s*(tbsp|tsp|cup|ounce|gram|kg|lb)/', $text),
        'cooking_verbs' => preg_match('/(mix|stir|bake|fry|boil|grill|chop|dice)/', $text)
    ];

    return [
        'is_valid' => !in_array(false, $checks, true),
        'failed_checks' => array_keys(array_filter($checks, fn($v) => !$v))
    ];
}

$validation = validateRecipe($data);
$is_admin = ($_SESSION['user_id'] === 1); // Hardcoded admin ID

// Prepare recipe status
$status = $is_admin ? 'approved' : ($validation['is_valid'] ? 'pending' : 'flagged');
$validation_issues = $validation['failed_checks'] ?? [];

try {
    $stmt = $conn->prepare("INSERT INTO recipes 
        (name, description, ingredients, instructions, prep_time, cook_time, 
         difficulty, user_id, status, validation_issues)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    
    $success = $stmt->execute([
        $data['name'],
        $data['description'] ?? '',
        $data['ingredients'],
        $data['instructions'],
        $data['prep_time'] ?? 0,
        $data['cook_time'] ?? 0,
        $data['difficulty'] ?? 'Medium',
        $_SESSION['user_id'],
        $status,
        json_encode($validation_issues)
    ]);
    
    echo json_encode([
        'success' => $success,
        'recipe_id' => $conn->insert_id,
        'status' => $status,
        'validation' => $validation,
        'is_admin' => $is_admin
    ]);
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>