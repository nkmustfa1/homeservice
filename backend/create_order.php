<?php
header('Content-Type: application/json; charset=utf-8');

// إعدادات الاتصال بقاعدة البيانات
$servername = "127.0.0.1";
$username   = "root";
$password   = "";
$dbname     = "homeservices";

// إنشاء اتصال
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode([
        'success' => false,
        'message' => "Connection failed: " . $conn->connect_error
    ]));
}

$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, true);

if (
    !isset($input['client_id']) ||
    !isset($input['provider_id']) ||
    !isset($input['service_id']) ||
    !isset($input['order_date']) ||
    !isset($input['order_time'])
) {
    echo json_encode([
        'success' => false,
        'message' => "Missing required fields"
    ]);
    exit;
}

$client_id      = $input['client_id'];
$provider_id    = $input['provider_id'];
$service_id     = $input['service_id'];
$order_date     = $input['order_date']; 
$order_time     = $input['order_time']; 
$provider_notes = $input['order_details'] ?? null;
$imageBase64    = $input['image_base64'] ?? null;

$problem_image = null;
if ($imageBase64) {
    $problem_image = base64_decode($imageBase64);

}

$stmt = $conn->prepare("INSERT INTO order_services 
    (client_id, provider_id, service_id, order_date, order_time, order_details, problem_photo, created_at) 
    VALUES (?, ?, ?, ?, ?, ?, ?, NOW())");

if (!$stmt) {
    echo json_encode([
        'success' => false,
        'message' => "Prepare failed: " . $conn->error
    ]);
    exit;
}

if ($problem_image === null) {
    $stmt->bind_param("iisssss", $client_id, $provider_id, $service_id, $order_date, $order_time, $provider_notes, $problem_image);
} else {
    $stmt->bind_param("iisssss", $client_id, $provider_id, $service_id, $order_date, $order_time, $provider_notes, $problem_image);
}

if ($stmt->execute()) {
    $order_id = $conn->insert_id;
    echo json_encode([
        'success'  => true,
        'order_id' => $order_id,
        'message'  => "Order created successfully"
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => "Failed to create order: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
