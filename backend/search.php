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
        'message' => 'فشل الاتصال بقاعدة البيانات: ' . $conn->connect_error
    ]));
}

if (isset($_GET['search']) && trim($_GET['search']) !== '') {
    $search = "%" . $conn->real_escape_string($_GET['search']) . "%";

    $sql = "SELECT 
                sp.id AS provider_id,
                s.id AS service_id,
                sp.provider_name,
                sp.provider_image,  
                (
                    SELECT IFNULL(AVG(e.eva_byno), 0)
                    FROM evaluations e
                    JOIN given_services gs2 ON e.provider_service_id = gs2.id
                    WHERE gs2.provider_id = sp.id
                ) AS average_rating,
                s.service_name,
                gs.service_description,
                c.category_name
            FROM server_providers sp
            INNER JOIN given_services gs ON sp.id = gs.provider_id
            INNER JOIN services s ON gs.service_id = s.id
            INNER JOIN categories c ON s.category_id = c.id  
            WHERE (s.service_name LIKE ? OR sp.provider_name LIKE ?)
              AND sp.acoount_status = 1";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $search, $search);
    $stmt->execute();
    $result = $stmt->get_result();

    $providers = [];
   
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        if (!empty($row['provider_image'])) {
            $row['provider_image'] = "data:image/jpeg;base64," . base64_encode($row['provider_image']);
        }
        $providers[] = $row;
    }
    echo json_encode(["success" => true, "providers" => $providers]);
}  else {
    echo json_encode(["success" => false, "message" => "يرجى إدخال كلمة للبحث"]);
}
}
$conn->close();
?>