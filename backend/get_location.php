<?php
header("Content-Type: application/json");
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

$host = "127.0.0.1"; 
$username = "root";
$password = ""; 
$dbname = "homeservices"; 

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if (!isset($_GET['user_id']) || empty($_GET['user_id'])) {
        echo json_encode([
            "success" => false,
            "message" => "User ID is required."
        ]);
        exit();
    }

    $userId = $_GET['user_id'];

    $stmt = $conn->prepare("SELECT address,client_name FROM clients WHERE id = :user_id");
    $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
    $stmt->execute();

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode([
            "success" => true,
            "location" => $result['address'],
            "client_name" => $result['client_name']
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Location not found for this user."
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Database error: " . $e->getMessage()
    ]);
}
?>
