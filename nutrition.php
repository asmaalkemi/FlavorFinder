<?php
header("Content-Type: application/json");
$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) die(json_encode(["error" => "Connection failed"]));


$recipeId = $_GET['id'] ?? 0;
$stmt = $conn->prepare("SELECT calories, protein, carbs, fats FROM recipes WHERE id = ?");
$stmt->bind_param("i", $recipeId);
$stmt->execute();
echo json_encode($stmt->get_result()->fetch_assoc());
?>