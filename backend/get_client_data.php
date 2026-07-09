<?php

$servername = "127.0.0.1";
$username   = "root";
$password   = "";
$dbname     = "homeservices";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : 0;

$stmt = $conn->prepare("
    SELECT client_name, email, telphone, address, image, ST_X(coordinates) AS latitude, ST_Y(coordinates) AS longitude
    FROM clients
    WHERE id = ?
    LIMIT 1
");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$response = array();

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    
    $imageBase64 = null;
    if (!empty($row['image'])) {
        $imageBase64 = base64_encode($row['image']);
    }
  
    $latitude = $row['latitude'];  
    $longitude = $row['longitude']; 

    $response['success'] = true;
    $response['user'] = array(
        'client_name' => $row['client_name'],
        'email'       => $row['email'],
        'telphone'    => $row['telphone'],
        'address'     => $row['address'],
        'image'       => $imageBase64, 
        'latitude'    => $latitude,
        'longitude'   => $longitude 
    );
} else {
    $response['success'] = false;
    $response['message'] = "User not found";
}

$stmt->close();
$conn->close();

header('Content-Type: application/json; charset=utf-8');
echo json_encode($response);


?>