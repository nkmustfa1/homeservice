<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = "127.0.0.1";
$dbname = "homeservices";
$user = "root";
$pass = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $provider_id = isset($_GET['provider_id']) ? intval($_GET['provider_id']) : 0;
    $service_id  = isset($_GET['service_id'])  ? intval($_GET['service_id'])  : 0;

    if ($provider_id <= 0) {
        echo json_encode(["success" => false, "message" => "Missing or invalid provider_id."]);
        exit;
    }

   
    $sql_provider = "
        SELECT 
            sp.id AS provider_id,
            s.id AS service_id,
            sp.provider_name,
            sp.provider_addrress,
            sp.provider_image,
            gs.service_description,
            gs.id AS given_service_id,
            gs.service_experties,
            s.service_name,
            c.category_name,
            gs.service_id,  
              (
               SELECT IFNULL(AVG(e.eva_byno), 0)
               FROM evaluations e
               WHERE e.provider_service_id = gs.id
              ) AS average_rating,

              (
                 SELECT COUNT(*)
                 FROM evaluations e
                 WHERE e.provider_service_id = gs.id
              ) AS total_reviews

        FROM server_providers sp
      JOIN given_services gs ON gs.provider_id = sp.id
      JOIN services s ON gs.service_id = s.id
        JOIN categories c ON s.category_id = c.id
        WHERE sp.id = :provider_id
    ";

    if ($service_id > 0) {
        $sql_provider .= " AND gs.service_id = :service_id";
    } else {
        $sql_provider .= " LIMIT 1";
    }

    $stmt = $pdo->prepare($sql_provider);
    $stmt->bindValue(':provider_id', $provider_id, PDO::PARAM_INT);
    if ($service_id > 0) {
        $stmt->bindValue(':service_id', $service_id, PDO::PARAM_INT);
    }
    $stmt->execute();

    $provider_details = $stmt->fetch(PDO::FETCH_ASSOC);

   
    if ($provider_details) {

        $rawImage = $provider_details["provider_image"];
    
        if (!empty($rawImage)) {
            $base64Image = base64_encode($rawImage);
            $provider_details["provider_image"] = $base64Image;
        } else {
            $provider_details["provider_image"] = "";
        }
    }
    
    
    if ($service_id <= 0 && isset($provider_details["service_id"])) {
        $service_id = intval($provider_details["service_id"]);
    }

  
    $sql_reviews = "
        SELECT 
            e.id,
            e.eva_byno AS rating,
            e.comment,
           
        DATE_FORMAT(e.updated_at, '%Y-%m-%d %H:%i:%s') AS comment_time,  
            c.client_name AS user_name,
            c.image  
        FROM evaluations e
        JOIN given_services gs ON e.provider_service_id = gs.id
        JOIN clients c ON e.client_id = c.id
        WHERE gs.provider_id = :provider_id AND gs.service_id = :service_id
        ORDER BY e.updated_at DESC
        LIMIT 50
    ";
    $stmt = $pdo->prepare($sql_reviews);
    $stmt->bindValue(':provider_id', $provider_id, PDO::PARAM_INT);
    $stmt->bindValue(':service_id', $service_id, PDO::PARAM_INT);
    $stmt->execute();
    $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);
    

    foreach ($reviews as $index => $row) {
        if (!empty($row['image'])) {
            $reviews[$index]['image'] = base64_encode($row['image']);
        } else {
            $reviews[$index]['image'] = "";
        }
    }
    

    $sql_other_services = "
        SELECT 
            gs.id AS given_service_id,
            gs.service_id,
            gs.service_description,
            s.service_name,
            c.category_name
        FROM given_services gs
        JOIN services s ON gs.service_id = s.id
        JOIN categories c ON s.category_id = c.id
        WHERE gs.provider_id = :provider_id
    ";
    if ($service_id > 0) {
        $sql_other_services .= " AND gs.service_id != :service_id2";
    }

    $stmt = $pdo->prepare($sql_other_services);
    $stmt->bindValue(':provider_id', $provider_id, PDO::PARAM_INT);
    if ($service_id > 0) {
        $stmt->bindValue(':service_id2', $service_id, PDO::PARAM_INT);
    }
    $stmt->execute();
    $other_services = $stmt->fetchAll(PDO::FETCH_ASSOC);

   
    $response = [
        "success" => true,
        "provider_details" => [
            "provider_id"         => $provider_details["provider_id"] ?? 0,
            "provider_name"       => $provider_details["provider_name"] ?? "",
            "provider_addrress"   => $provider_details["provider_addrress"] ?? "",
            "provider_image"      => $provider_details["provider_image"] ?? "",
            "service_description" => $provider_details["service_description"] ?? "",
            "service_experties"   => $provider_details["service_experties"] ?? "",
            "service_name"        => $provider_details["service_name"] ?? "",
            "category_name"       => $provider_details["category_name"] ?? "",
            "average_rating"      => $provider_details["average_rating"] ?? 0,
            "total_reviews"       => $provider_details["total_reviews"] ?? 0,
            "given_service_id"    => $provider_details["given_service_id"] ?? 0

        ],
        "reviews" => $reviews,
        "other_services" => $other_services
    ];

    echo json_encode($response, JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
