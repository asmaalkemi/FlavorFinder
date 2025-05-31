<?php 
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) die(json_encode(["error" => "Connection failed"]));

// Handle random recipes for homepage
if (isset($_GET['random'])) {
    $limit = (int)$_GET['random'];
    // Modified to include status filter
    $stmt = $conn->prepare("SELECT * FROM recipes WHERE status = 'approved' ORDER BY RAND() LIMIT ?");
    $stmt->bind_param("i", $limit);
    $stmt->execute();
    $result = $stmt->get_result();
    echo json_encode($result->fetch_all(MYSQLI_ASSOC));
    exit;
}

// Handle ingredient search
$terms = isset($_GET['search']) ?
    array_map('trim', explode(',', $_GET['search'])) : [];

// Base query now includes status filter
$query = "SELECT * FROM recipes WHERE status = 'approved'";
$params = [];
$types = "";

if (!empty($terms)) {
    $conditions = [];
    foreach ($terms as $term) {
        // Use parameterized queries for safety and correct filtering
        $conditions[] = "ingredients LIKE ?";
        $params[] = '%' . $term . '%';
        $types .= "s";
    }
    $query .= " AND (" . implode(" OR ", $conditions) . ")"; // Use OR for search terms, AND with status
}

// Prepare and execute the statement for ingredient search (or all approved recipes if no search terms)
$stmt = $conn->prepare($query);
if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}
$stmt->execute();
$result = $stmt->get_result();
echo json_encode($result->fetch_all(MYSQLI_ASSOC));
$conn->close();
?>