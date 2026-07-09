<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$host = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "homeservices";

$conn = new mysqli($host, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode([
        "success" => false, 
        "message" => "Database connection failed: " . $conn->connect_error
    ]));
}

if (!isset($_GET['category_id'])) {
    echo json_encode([
        "success" => false,
        "message" => "category_id not provided"
    ]);
    exit;
}

$category_id = intval($_GET['category_id']);

$stmt = $conn->prepare("SELECT id, service_name, service_statues FROM services WHERE category_id = ? AND service_statues = 1");
$stmt->bind_param("i", $category_id);
$stmt->execute();
$result = $stmt->get_result();

$services = [];
while ($row = $result->fetch_assoc()) {
    $services[] = $row;
}

if (!empty($services)) {
    echo json_encode([
        "success" => true,
        "services" => $services
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "No services found for this category"
    ]);
}

$stmt->close();
$conn->close();
?>
