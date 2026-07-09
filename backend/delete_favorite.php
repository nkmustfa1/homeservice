<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$host = "127.0.0.1";
$dbname = "homeservices";
$user = "root";
$pass = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $favorite_id = isset($_GET['favorite_id']) ? intval($_GET['favorite_id']) : 0;

    if ($favorite_id <= 0) {
        echo json_encode(["success" => false, "message" => "Invalid favorite_id"]);
        exit;
    }

    $sql = "DELETE FROM favorites WHERE id = :favorite_id";
    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':favorite_id', $favorite_id, PDO::PARAM_INT);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo json_encode(["success" => true, "message" => "Favorite item deleted"]);
    } else {
        echo json_encode(["success" => false, "message" => "No favorite item found with this id"]);
    }

} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}

