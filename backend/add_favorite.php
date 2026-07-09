<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = "127.0.0.1";
$dbname = "homeservices";
$user = "root";
$pass = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $client_id = isset($_POST['client_id']) ? intval($_POST['client_id']) : 0;
    $given_service_id = isset($_POST['provider_service_id']) ? intval($_POST['provider_service_id']) : 0;

    if($client_id <= 0 || $given_service_id <= 0) {
        echo json_encode(["success" => false, "message" => "Invalid client_id or provider_service_id"]);
        exit;
    }

    $check_sql = "SELECT 1 FROM favorites 
                  WHERE client_id = :client_id 
                    AND provider_service_id = :provider_service_id 
                  LIMIT 1";
    $stmt = $pdo->prepare($check_sql);
    $stmt->bindValue(':client_id', $client_id, PDO::PARAM_INT);
    $stmt->bindValue(':provider_service_id', $given_service_id, PDO::PARAM_INT);
    $stmt->execute();

    if($stmt->rowCount() > 0) {
        echo json_encode(["success" => false, "message" => "Favorite already exists"]);
        exit;
    }

    $sql = "INSERT INTO favorites (client_id, provider_service_id) 
            VALUES (:client_id, :provider_service_id)";
    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':client_id', $client_id, PDO::PARAM_INT);
    $stmt->bindValue(':provider_service_id', $given_service_id, PDO::PARAM_INT);

    if($stmt->execute()){
        echo json_encode(["success" => true, "message" => "Favorite added successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to add favorite"]);
    }

} catch(PDOException $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
