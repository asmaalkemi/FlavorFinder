<?php 
header('Content-Type: application/json');
session_start();

// Database connection (same as before)
$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => "Database connection failed"]));
}

// Get recipe ID
$recipe_id = isset($_GET['id']) ? intval($_GET['id']) : 0;
if (!$recipe_id) {
    echo json_encode(['success' => false, 'message' => 'Invalid recipe ID']);
    exit;
}

// Fetch recipe
$stmt = $conn->prepare("SELECT * FROM recipes WHERE id = ?");
$stmt->bind_param('i', $recipe_id);
$stmt->execute();
$result = $stmt->get_result();
if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'Recipe not found']);
    exit;
}
$recipe = $result->fetch_assoc();

// Analyze recipe
include 'analyze_recipe.php'; // Include the analysis function
$analysis = analyzeRecipe($recipe);

// Return results
echo json_encode([
    'success' => true,
    'score' => $analysis['score'],
    'recommendation' => $analysis['recommendation']
]);
?>