<?php
header('Content-Type: application/json; charset=utf-8');

$servername = "127.0.0.1";
$username   = "root";
$password   = "";
$dbname     = "homeservices";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode([
        'success' => false,
        'message' => "Connection failed: " . $conn->connect_error
    ]);
    exit;
}

$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, true);

if (!isset($input['order_id']) || empty($input['order_id'])) {
    echo json_encode([
        'success' => false,
        'message' => "Missing order_id"
    ]);
    exit;
}

$order_id = $input['order_id'];

$stmt = $conn->prepare("INSERT INTO notifications (order_id) VALUES (?)");
if (!$stmt) {
    echo json_encode([
        'success' => false,
        'message' => "Prepare failed: " . $conn->error
    ]);
    exit;
}

$stmt->bind_param("i", $order_id);

if ($stmt->execute()) {
    echo json_encode([
        'success' => true,
        'message' => "Notification created successfully"
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => "Failed to create notification: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
