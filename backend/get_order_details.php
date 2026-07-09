<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
ini_set('display_errors', 1);
error_reporting(E_ALL);

$host = "127.0.0.1";
$user = "root";
$pass = "";
$db   = "homeservices";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $order_id = isset($_GET['order_id']) ? intval($_GET['order_id']) : 0;

    $sql = "
        SELECT 
            os.id AS order_id,
            os.client_id,
            os.provider_id,
            os.service_id,
            os.order_date,
            os.order_time,
            os.provider_notes,
            os.problem_photo,  
            os.order_details,

            n.service_replay_details,
            n.provider_reject_reason,
            n.client_reject_reason,
            n.price, 
            
            gs.id AS given_service_id,
            gs.service_experties,

            sp.provider_name,
            sp.phone_number AS provider_phone,
            sp.provider_addrress AS provider_address,
            sp.email AS provider_email,
             (
                SELECT IFNULL(AVG(e.eva_byno), 0)
                FROM evaluations e
                JOIN given_services gs2 ON e.provider_service_id = gs2.id
                WHERE gs2.provider_id = sp.id
            ) AS average_rating,
            sp.provider_image,

            s.service_name,

            c.client_name,
            c.address AS client_address,
            ct.category_name

        FROM order_services os

        JOIN given_services gs 
            ON gs.provider_id = os.provider_id
            AND gs.service_id = os.service_id

        LEFT JOIN notifications n 
            ON n.order_id = os.id

        JOIN services s
            ON gs.service_id = s.id

        JOIN server_providers sp
            ON gs.provider_id = sp.id

        JOIN clients c
            ON os.client_id = c.id

        JOIN categories ct
            ON ct.id = s.category_id

        WHERE os.id = :oid
        LIMIT 1
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':oid', $order_id, PDO::PARAM_INT);
    $stmt->execute();

    if ($stmt->rowCount() === 0) {
        echo json_encode([
            "error"   => true,
            "message" => "No order found with id = $order_id"
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $orderRow = $stmt->fetch(PDO::FETCH_ASSOC);

 // provider_image
$providerImageBase64 = '';
if (!empty($orderRow['provider_image'])) {
    $providerImageBase64 = base64_encode($orderRow['provider_image']);
}



    $problemPhotoBase64 = "";
    if (!empty($orderRow['problem_photo'])) {
        $problemPhotoBase64 = base64_encode($orderRow['problem_photo']);
    }

    
    $output = [
        "order_id"              => intval($orderRow['order_id']),
        "order_date"            => $orderRow['order_date'] ?? "",
        "order_time"            => $orderRow['order_time'] ?? "",
        "provider_notes"        => $orderRow['provider_notes'] ?? "",
        "service_replay_details"=> $orderRow['service_replay_details'] ?? "", 
        "order_details"         => $orderRow['order_details'] ?? "", 


        "problem_photo"         => $problemPhotoBase64, 

        "service_name"          => $orderRow['service_name'] ?? "",

        "provider_id"           => intval($orderRow['provider_id']),
        "provider_name"         => $orderRow['provider_name'] ?? "",
        "provider_phone"        => $orderRow['provider_phone'] ?? "",
        "provider_address"      => $orderRow['provider_address'] ?? "",
        "provider_email"        => $orderRow['provider_email'] ?? "",
        "average_rating"        => floatval($orderRow['average_rating']),

        "provider_image"        => $providerImageBase64,
        "service_experties"     => $orderRow['service_experties'] ?? "",

        "client_name"           => $orderRow['client_name'] ?? "",
        "client_address"        => $orderRow['client_address'] ?? "",
        "category_name"         => $orderRow['category_name'] ?? "",

        "is_rejected"           => (!empty($orderRow['provider_reject_reason']) 
                                    || !empty($orderRow['client_reject_reason'])) ? true : false,
        "provider_reject_reason"=> $orderRow['provider_reject_reason'] ?? "",
        "client_reject_reason"  => $orderRow['client_reject_reason'] ?? "",
        "price"                 => $orderRow['price'],


    ];

    echo json_encode($output, JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    echo json_encode([
        "error"   => true,
        "message" => "DB Error: " . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
