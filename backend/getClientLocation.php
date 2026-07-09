<?php
header("Content-Type: application/json");
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

$host = "127.0.0.1"; 
$username = "root"; 
$password = ""; 
$dbname = "homeservices"; 

$conn = new mysqli($host, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode([
        "success" => false,
        "message" => "Connection failed: " . $conn->connect_error
    ]);
    exit;
}

if (!isset($_GET['clientId'])) {
    echo json_encode([
        "success" => false,
        "message" => "clientId parameter missing"
    ]);
    exit;
}

$clientId = intval($_GET['clientId']);

$stmt = $conn->prepare("SELECT ST_X(coordinates) AS latitude, ST_Y(coordinates) AS longitude FROM clients WHERE id = ?");
$stmt->bind_param("i", $clientId);
$stmt->execute();
$stmt->bind_result($latitude, $longitude);

if ($stmt->fetch()) {
    echo json_encode([
        "success"   => true,
        "latitude"  => $latitude,
        "longitude" => $longitude
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Client not found"
    ]);
}

$stmt->close();
$conn->close();
?>
