<?php
header('Content-Type: application/json; charset=utf-8');

$host = "localhost";
$user = "root";
$pass = "";
$db   = "homeservices"; 

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die(json_encode(["error" => $conn->connect_error]));
}
$conn->set_charset("utf8");

$client_id = isset($_GET['client_id']) ? intval($_GET['client_id']) : 0;

$sql = "
    SELECT
        e.id AS review_id,
        e.eva_byno AS rating,
        e.comment AS comment,
        e.provider_service_id,
        e.updated_at AS created_time,
       
        sp.provider_name AS provider_name,
         sp.provider_image AS provider_image,
        sp.id AS provider_id,
        s.id AS service_id,
        s.service_name AS service_name
    FROM evaluations e
    JOIN clients c ON e.client_id = c.id
    JOIN given_services gs ON e.provider_service_id = gs.id
    JOIN server_providers sp ON gs.provider_id = sp.id
    JOIN services s ON gs.service_id = s.id
    WHERE e.client_id = $client_id
    ORDER BY e.updated_at DESC
";

$result = $conn->query($sql);

$data = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        if (!empty($row['provider_image'])) {
            $row['provider_image'] = base64_encode($row['provider_image']);
        } else {
            $row['provider_image'] = ""; 
        }
        $data[] = $row;
        
    }
}



echo json_encode($data, JSON_UNESCAPED_UNICODE);
$conn->close();
