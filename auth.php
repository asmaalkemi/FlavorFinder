<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Origin: *");
session_start();

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) {
    error_log("Database connection failed: " . $conn->connect_error);
    die(json_encode(['success' => false, 'message' => "Database connection failed"]));
}

// Get raw POST data
$json = file_get_contents('php://input');
$data = json_decode($json, true);
error_log("Received data: " . print_r($data, true));

$action = $data['action'] ?? '';
$response = ['success' => false, 'message' => ''];

try {
    if ($action === 'register') {
        error_log("Register action");
        $username = trim($data['username'] ?? '');
        $email = trim($data['email'] ?? '');
        $password = $data['password'] ?? '';
        
        // Validation
        if (empty($username) || empty($email) || empty($password)) {
            throw new Exception("All fields are required");
        }
        
        // Check if username or email already exists
        $stmt = $conn->prepare("SELECT id FROM users WHERE username = ? OR email = ?");
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        $stmt->bind_param("ss", $username, $email);
        if (!$stmt->execute()) {
            throw new Exception("Execute failed: " . $stmt->error);
        }
        
        $result = $stmt->get_result();
        if ($result->num_rows > 0) {
            throw new Exception("Username or email already exists");
        }
        
        // Hash password
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        
        // Default to non-admin
        $is_admin = 0;
        
        // Insert new user
        $stmt = $conn->prepare("INSERT INTO users (username, email, password, is_admin) VALUES (?, ?, ?, ?)");
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        $stmt->bind_param("sssi", $username, $email, $hashed_password, $is_admin);
        if (!$stmt->execute()) {
            throw new Exception("Execute failed: " . $stmt->error);
        }
        
        $user_id = $conn->insert_id;
        $_SESSION['user_id'] = $user_id;
        $_SESSION['is_admin'] = $is_admin;
        
        $response = [
            'success' => true,
            'message' => 'Registration successful',
            'user' => ['id' => $user_id, 'username' => $username, 'is_admin' => $is_admin]
        ];
        error_log("Registration success for user: " . $username);
        
    } elseif ($action === 'login') {
        error_log("Login action");
        $username = trim($data['username'] ?? '');
        $password = $data['password'] ?? '';
        
        if (empty($username) || empty($password)) {
            throw new Exception("Username and password are required");
        }
        
        $stmt = $conn->prepare("SELECT id, username, password, is_admin FROM users WHERE username = ?");
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        $stmt->bind_param("s", $username);
        if (!$stmt->execute()) {
            throw new Exception("Execute failed: " . $stmt->error);
        }
        
        $result = $stmt->get_result();
        if ($result->num_rows === 0) {
            throw new Exception("User not found");
        }
        
        $user = $result->fetch_assoc();
        if (!password_verify($password, $user['password'])) {
            throw new Exception("Invalid password");
        }
        
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['is_admin'] = $user['is_admin'];
        $response = [
            'success' => true,
            'message' => 'Login successful',
            'user' => ['id' => $user['id'], 'username' => $user['username'], 'is_admin' => $user['is_admin']]
        ];
        error_log("Login success for user: " . $user['username']);
    } elseif ($action === 'make_admin') {
        // Check if the current user is an admin
        if (!isset($_SESSION['is_admin']) || $_SESSION['is_admin'] != 1) {
            throw new Exception("Unauthorized: Admin privileges required");
        }
        
        $user_id = $data['user_id'] ?? 0;
        if (!$user_id) {
            throw new Exception("User ID required");
        }
        
        // Update user to admin
        $stmt = $conn->prepare("UPDATE users SET is_admin = 1 WHERE id = ?");
        $stmt->bind_param("i", $user_id);
        if (!$stmt->execute()) {
            throw new Exception("Failed to update user role");
        }
        
        $response = [
            'success' => true,
            'message' => 'User promoted to admin'
        ];
    } else {
        throw new Exception("Invalid action");
    }
} catch (Exception $e) {
    error_log("Error: " . $e->getMessage());
    $response['message'] = $e->getMessage();
}

error_log("Sending response: " . json_encode($response));
echo json_encode($response);
?>