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
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}
$sql = "SELECT id, category_name, icon FROM categories";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $categories = [];
    while ($row = $result->fetch_assoc()) {
        $iconBlob = $row["icon"];
        $iconBase64 = base64_encode($iconBlob);

        $categories[] = [
            "id" => $row["id"],
            "category_name" => $row["category_name"],
            "icon" => $iconBase64
        ];
    }
    echo json_encode(["success" => true, "categories" => $categories]);
} else {
    echo json_encode(["success" => false, "message" => "No categories found"]);
}
