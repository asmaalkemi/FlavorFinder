<?php
session_start();

// Check if user is logged in and is admin
if (!isset($_SESSION['user_id']) || !isset($_SESSION['is_admin']) || $_SESSION['is_admin'] != 1) {
    header("Location: index.html");
    exit;
}

// Database connection
$conn = new mysqli("localhost", "root", "", "recipe_master");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle recipe validation updates
if (isset($_POST['action']) && $_POST['action'] == 'validate_recipe') {
    $recipe_id = $_POST['recipe_id'];
    $status = $_POST['status']; // 'approved' or 'rejected'

    $stmt = $conn->prepare("UPDATE recipes SET status = ? WHERE id = ?");
    $stmt->bind_param("si", $status, $recipe_id);
    $stmt->execute();
}

// Get pending recipes
$pendingRecipes = [];
$stmt = $conn->prepare("SELECT * FROM recipes WHERE status = 'pending' OR status IS NULL ORDER BY created_at DESC");
$stmt->execute();
$result = $stmt->get_result();
while ($row = $result->fetch_assoc()) {
    $pendingRecipes[] = $row;
}

// Get all users
$users = [];
$stmt = $conn->prepare("SELECT id, username, email, is_admin FROM users ORDER BY username");
$stmt->execute();
$result = $stmt->get_result();
while ($row = $result->fetch_assoc()) {
    $users[] = $row;
}

// Handle comment 
if (isset($_POST['action']) && $_POST['action'] == 'validate_comment') {
    $comment_id = $_POST['comment_id'];
    $status = $_POST['status']; // 'approved' or 'rejected'

    $stmt = $conn->prepare("UPDATE recipe_comments SET status = ? WHERE id = ?");
    $stmt->bind_param("si", $status, $comment_id);
    $stmt->execute();
}

//Get pending comment
$pendingComments = [];
$stmt = $conn->prepare("SELECT c.*, r.name as recipe_name, u.username as user_name
                       FROM recipe_comments c
                       LEFT JOIN recipes r ON c.recipe_id = r.id
                       LEFT JOIN users u ON c.user_id = u.id
                       WHERE c.status = 'pending'
                       ORDER BY c.created_at DESC");
$stmt->execute();
$result = $stmt->get_result();
while ($row = $result->fetch_assoc()) {
    $pendingComments[] = $row;
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FlavorFinder Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

    <link rel="icon" type="image/png" href="favicon.png">


    <link rel="stylesheet" href="auth.css">
    <link rel="stylesheet" href="hey.css">
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .admin-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .admin-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .admin-tab {
            padding: 10px 20px;
            background-color: #f0f0f0;
            border-radius: 4px;
            cursor: pointer;
        }

        .admin-tab.active {
            background-color: #4CAF50;
            color: white;
        }

        .admin-content {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .admin-section {
            display: none;
        }

        .admin-section.active {
            display: block;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        table th, table td {
            text-align: left;
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }

        table th {
            background-color: #f5f5f5;
        }

        .action-btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 5px;
        }

        .approve-btn {
            background-color: #4CAF50;
            color: white;
        }

        .reject-btn {
            background-color: #f44336;
            color: white;
        }

        .admin-btn {
            background-color: #2196F3;
            color: white;
        }

        .recipe-preview {
            margin-top: 10px;
            padding: 10px;
            background-color: #f9f9f9;
            border-radius: 4px;
        }
         .comment-text {
            max-height: 100px; /* Adjust as needed */
            overflow-y: auto;
        }
    </style>
</head>
<body>
    <div class="admin-container">
        <div class="admin-header">
            <h1>FlavorFinder Admin Dashboard</h1>
            <div>
                <a href="index.html" class="action-btn">Back to Site</a>
                <button id="logoutBtn" class="action-btn reject-btn">Logout</button>
            </div>
        </div>

        <div class="admin-tabs">
            <div class="admin-tab active" data-tab="recipes">Pending Recipes</div>
            <div class="admin-tab" data-tab="users">User Management</div>
             <div class="admin-tab" data-tab="comments">Pending Comments</div>
        </div>

        <div class="admin-content">
            <div class="admin-section active" id="recipes-section">
                <h2>Pending Recipes (<?php echo count($pendingRecipes); ?>)</h2>

                <?php if (count($pendingRecipes) > 0): ?>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>User</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($pendingRecipes as $recipe): ?>
                        <tr>
                            <td><?php echo $recipe['id']; ?></td>
                            <td><?php echo htmlspecialchars($recipe['name']); ?></td>
                            <td><?php echo $recipe['user_id']; ?></td>
                            <td><?php echo $recipe['created_at']; ?></td>
                            <td>
                                <button class="action-btn approve-btn" onclick="validateRecipe(<?php echo $recipe['id']; ?>, 'approved')">Approve</button>
                                <button class="action-btn reject-btn" onclick="validateRecipe(<?php echo $recipe['id']; ?>, 'rejected')">Reject</button>
                                <button class="action-btn" onclick="previewRecipe(<?php echo $recipe['id']; ?>)">Preview</button>
                            </td>
                        </tr>
                        <tr id="preview-<?php echo $recipe['id']; ?>" style="display: none;">
                            <td colspan="5">
                                <div class="recipe-preview">
                                    <h3><?php echo htmlspecialchars($recipe['name']); ?></h3>
                                    <p><strong>Description:</strong> <?php echo htmlspecialchars($recipe['description'] ?? 'No description'); ?></p>
                                    <p><strong>Ingredients:</strong> <?php echo htmlspecialchars($recipe['ingredients']); ?></p>
                                    <p><strong>Instructions:</strong> <?php echo nl2br(htmlspecialchars($recipe['instructions'])); ?></p>
                                    <div><strong>ML Validation Result:</strong> <span id="ml-result-<?php echo $recipe['id']; ?>">Processing...</span></div>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php else: ?>
                <p>No pending recipes to validate.</p>
                <?php endif; ?>
            </div>

            <div class="admin-section" id="users-section">
                <h2>User Management (<?php echo count($users); ?>)</h2>

                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Admin</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($users as $user): ?>
                        <tr>
                            <td><?php echo $user['id']; ?></td>
                            <td><?php echo htmlspecialchars($user['username']); ?></td>
                            <td><?php echo htmlspecialchars($user['email']); ?></td>
                            <td><?php echo $user['is_admin'] ? 'Yes' : 'No'; ?></td>
                            <td>
                                <?php if (!$user['is_admin']): ?>
                                <button class="action-btn admin-btn" onclick="makeAdmin(<?php echo $user['id']; ?>)">Make Admin</button>
                                <?php else: ?>
                                <span>Admin User</span>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

             <div class="admin-section" id="comments-section">
                <h2>Pending Comments (<?php echo count($pendingComments); ?>)</h2>

                <?php if (count($pendingComments) > 0): ?>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Recipe</th>
                            <th>User</th>
                            <th>Comment</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($pendingComments as $comment): ?>
                        <tr>
                            <td><?php echo $comment['id']; ?></td>
                            <td><?php echo htmlspecialchars($comment['recipe_name']); ?></td>
                            <td><?php echo htmlspecialchars($comment['user_name'] ?? $comment['guest_name'] ?? 'Anonymous'); ?></td>
                            <td class="comment-text"><?php echo htmlspecialchars($comment['comment']); ?></td>
                            <td><?php echo $comment['created_at']; ?></td>
                            <td>
                                <button class="action-btn approve-btn" onclick="validateComment(<?php echo $comment['id']; ?>, 'approved')">Approve</button>
                                <button class="action-btn reject-btn" onclick="validateComment(<?php echo $comment['id']; ?>, 'rejected')">Reject</button>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php else: ?>
                <p>No pending comments to review.</p>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <script>
        // Tab switching
        document.querySelectorAll('.admin-tab').forEach(tab => {
            tab.addEventListener('click', () => {
                // Update active tab
                document.querySelectorAll('.admin-tab').forEach(t => t.classList.remove('active'));
                tab.classList.add('active');

                // Show corresponding section
                const tabId = tab.dataset.tab;
                document.querySelectorAll('.admin-section').forEach(section => {
                    section.classList.remove('active');
                });
                document.getElementById(tabId + '-section').classList.add('active');
            });
        });

        // Preview recipe
        function previewRecipe(id) {
            const previewRow = document.getElementById(`preview-${id}`);
            previewRow.style.display = previewRow.style.display === 'none' ? 'table-row' : 'none';

            if (previewRow.style.display !== 'none') {
                // ML validation
                validateRecipeML(id);
            }
        }

        
        /* async function validateRecipeML(id) {
              const resultSpan = document.getElementById(`ml-result-${id}`);
              resultSpan.textContent = 'Analyzing...';

              try {
                  const response = await fetch(`validate_recipe_ml.php?id=${id}`);
                  const data = await response.json();
                  console.log(">>> Response from validate_recipe_ml.php:", data);

                  if (data.success) {
                      resultSpan.textContent = `${data.score}% match - ${data.recommendation}`;
                      resultSpan.style.color = data.score > 70 ? 'green' : data.score > 40 ? 'orange' : 'red';
                  } else {
                      resultSpan.textContent = 'Error: ' + data.message;
                      resultSpan.style.color = 'red';
                  }
              } catch (error) {
                  resultSpan.textContent = 'Error running validation';
                  resultSpan.style.color = 'red';
                  console.error('ML validation error:', error);
              }
          } */
        async function validateRecipeML(id) {
            const resultSpan = document.getElementById(`ml-result-${id}`);
            resultSpan.textContent = 'Analyzing...';

            try {
                const response = await fetch(`validate_recipe_ml.php?id=${id}`);
                const data = await response.json();

                if (data.success) {
                    resultSpan.innerHTML = `
                        <strong>${data.score}%</strong> - ${data.recommendation}
                    `;
                    resultSpan.style.color = data.score > 70 ? 'green' : data.score > 40 ? 'orange' : 'red';
                } else {
                    resultSpan.textContent = 'Error: ' + data.message;
                    resultSpan.style.color = 'red';
                }
            } catch (error) {
                resultSpan.textContent = 'Error running validation';
                resultSpan.style.color = 'red';
                console.error('ML validation error:', error);
            }
        }

        // Validate recipe 
        async function validateRecipe(id, status) {
            try {
                const formData = new FormData();
                formData.append('action', 'validate_recipe');
                formData.append('recipe_id', id);
                formData.append('status', status);

                const response = await fetch('admin.php', {
                    method: 'POST',
                    body: formData
                });

                // Reload page to update list
                window.location.reload();
            } catch (error) {
                console.error('Error validating recipe:', error);
                alert('Failed to update recipe status');
            }
        }

        // Make user an admin
        async function makeAdmin(userId) {
            if (!confirm('Are you sure you want to make this user an admin?')) {
                return;
            }

            try {
                const response = await fetch('auth.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'make_admin',
                        user_id: userId
                    })
                });

                const result = await response.json();

                if (result.success) {
                    alert('User has been made an admin');
                    window.location.reload();
                } else {
                    alert('Error: ' + result.message);
                }
            } catch (error) {
                console.error('Error making admin:', error);
                alert('Failed to update user role');
            }
        }

        // Validate Comment function
        async function validateComment(id, status) {
            try {
                const formData = new FormData();
                formData.append('action', 'validate_comment');
                formData.append('comment_id', id);
                formData.append('status', status);

                const response = await fetch('admin.php', {
                    method: 'POST',
                    body: formData
                });

                // Reload page to update list
                window.location.reload();
            } catch (error) {
                console.error('Error validating comment:', error);
                alert('Failed to update comment status');
            }
        }

        // Logout button
        document.getElementById('logoutBtn').addEventListener('click', async () => {
            try {
                await fetch('session.php', {
                    method: 'DELETE',
                    credentials: 'include'
                });
                window.location.href = 'index.html';
            } catch (error) {
                console.error('Logout error:', error);
                alert('Logout failed');
            }
        });
    </script>
</body>
</html>
