<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = "127.0.0.1";
$dbname = "homeservices";
$user = "root";
$password = ""; 

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $client_id = isset($_POST['client_id']) ? intval($_POST['client_id']) : 0;
    $provider_service_id = isset($_POST['provider_service_id']) ? intval($_POST['provider_service_id']) : 0;

    if ($client_id <= 0 || $provider_service_id <= 0) {
        echo json_encode(["success" => false, "message" => "Invalid parameters provided"]);
        exit;
    }

    $delete_sql = "DELETE FROM favorites WHERE client_id = :client_id AND provider_service_id = :provider_service_id";
    $stmt = $pdo->prepare($delete_sql);
    $stmt->bindParam(':client_id', $client_id);
    $stmt->bindParam(':provider_service_id', $provider_service_id);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo json_encode(["success" => true, "message" => "Favorite deleted successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Favorite not found or already deleted"]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}


