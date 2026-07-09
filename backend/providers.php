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
        'success' => false,
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]));
}

if (isset($_GET['category'])) {
    $category_id = intval($_GET['category']);
    if (empty($_GET['service'])) {
        $sql = "SELECT 
                    sp.id AS provider_id, 
                    s.id AS service_id,
                    s.service_name,
                    sp.provider_name, 
                    sp.phone_number, 
                    sp.email, 
                    sp.provider_addrress, 
                    sp.provider_image,
                    (SELECT IFNULL(AVG(e.eva_byno), 0)
                       FROM evaluations e
                       JOIN given_services gs2 ON e.provider_service_id = gs2.id
                      WHERE gs2.provider_id = sp.id
                         AND  gs2.service_id  = gs.service_id
                    ) AS average_rating,
                    ST_X(sp.coordinates) AS   longitude  ,
                    ST_Y(sp.coordinates) AS  latitude,
                    sp.acoount_status, 
                    gs.service_description
                FROM server_providers sp
                INNER JOIN given_services gs ON sp.id = gs.provider_id
                INNER JOIN services s ON gs.service_id = s.id
                WHERE s.category_id = ? AND sp.acoount_status = 1";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $category_id);
    } else {
        $service_id = intval($_GET['service']);
        $sql = "SELECT 
                    sp.id AS provider_id, 
                    s.id AS service_id,
                    sp.provider_name, 
                    sp.phone_number, 
                    sp.email, 
                    sp.provider_addrress, 
                    sp.provider_image,
                    (SELECT IFNULL(AVG(e.eva_byno), 0)
                       FROM evaluations e
                       JOIN given_services gs2 ON e.provider_service_id = gs2.id
                       WHERE gs2.provider_id = sp.id
                    ) AS average_rating,
                    ST_X(sp.coordinates) AS longitude ,
                    ST_Y(sp.coordinates) AS latitude,
                    sp.acoount_status, 
                    gs.service_description
                FROM server_providers sp
                INNER JOIN given_services gs ON sp.id = gs.provider_id
                INNER JOIN services s ON gs.service_id = s.id
                WHERE gs.service_id = ? AND s.category_id = ? AND sp.acoount_status = 1";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ii", $service_id, $category_id);
    }

    $stmt->execute();
    $result = $stmt->get_result();
 

    $providers = [];
    while ($row = $result->fetch_assoc()) {
        $rawImage = $row['provider_image'];
    
        if (!empty($rawImage)) {
            $base64Image = base64_encode($rawImage);
            $row['provider_image'] = $base64Image;
        } else {
            $row['provider_image'] = "";
        }
      

        $providers[] = $row;
    }
    
    echo json_encode(["success" => !empty($providers), "providers" => $providers]);

} else {
    echo json_encode(["success" => false, "message" => "يجب إرسال category و service"]);
}

$conn->close();
?>
