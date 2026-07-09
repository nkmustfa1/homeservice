<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

$servername = "127.0.0.1";  
$username = "root";         
$password = "";             
$dbname = "homeservices";   

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed"]));
}

$sql = "
    SELECT 
        sp.id AS provider_id, 
        sp.provider_name, 
        sp.phone_number, 
        sp.provider_image, 
        sp.provider_addrress,
        s.id AS service_id,
        s.service_name, 
        c.category_name,
        AVG(e.eva_byno) AS average_rating,
        COUNT(e.id) AS total_reviews
    FROM server_providers sp
    JOIN given_services gs ON sp.id = gs.provider_id
    JOIN services s ON gs.service_id = s.id
    JOIN categories c ON s.category_id = c.id
    LEFT JOIN evaluations e ON gs.id = e.provider_service_id  
    WHERE sp.acoount_status = 1  
    GROUP BY sp.id, sp.provider_name, sp.phone_number, sp.provider_image, sp.provider_addrress, s.service_name, c.category_name
    HAVING COUNT(e.id) > 0 
   ORDER BY
    average_rating DESC,
    total_reviews DESC,
    sp.id ASC
LIMIT 10";



$result = $conn->query($sql);

$providers = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        if (!empty($row['provider_image'])) {
            $row['provider_image'] = "data:image/jpeg;base64," . base64_encode($row['provider_image']);
        }
        $providers[] = $row;
    }
    echo json_encode(["success" => true, "providers" => $providers]);
} else {
    echo json_encode(["success" => false, "message" => "No providers found"]);
}

$conn->close();
?>
