<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$host     = '127.0.0.1';
$dbname   = 'homeservices';
$db_user  = 'root';
$db_pass  = '';

$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
if ($user_id === 0) {
    echo json_encode(["success" => false, "message" => "user_id is required"]);
    exit;
}

try {
    $dsn  = "mysql:host=$host;dbname=$dbname;charset=utf8mb4";
    $pdo  = new PDO($dsn, $db_user, $db_pass, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    $stmt = $pdo->prepare('SELECT email FROM clients WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $user_id]);
    $row = $stmt->fetch();

    if ($row) {
        echo json_encode([
            "success" => true,
            "email"   => $row['email']
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "User not found"
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Database error",
    ]);
}
?>
