<?php
header('Content-Type: application/json; charset=utf-8');

$host = '127.0.0.1';
$user = 'root';
$pass = '';
$db   = 'homeservices';

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(['error' => 'فشل الاتصال بقاعدة البيانات']);
    exit;
}

$client_id = isset($_GET['client_id']) ? intval($_GET['client_id']) : 0;
if ($client_id <= 0) {
    echo json_encode(['ongoing_orders' => 0]);
    exit;
}

$sql = "
    SELECT COUNT(*) AS ongoing_orders
    FROM order_services o
    JOIN notifications os ON o.id = os.order_id
    WHERE o.client_id = ?
      AND (
            os.client_confirm   <> 0
         OR os.provider_confirm <> 0
         OR os.Payment_status   <> 1
      )
";
$stmt = $conn->prepare($sql);
$stmt->bind_param('i', $client_id);
$stmt->execute();
$stmt->bind_result($count);
$stmt->fetch();
$stmt->close();

echo json_encode(['ongoing_orders' => (int)$count]);

$conn->close();
