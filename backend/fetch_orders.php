<?php
header('Content-Type: application/json; charset=UTF-8');

$host = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "homeservices";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if (!isset($_GET['user_id'])) {
        echo json_encode(['error' => 'user_id مطلوب']);
        exit;
    }

    $client_id = $_GET['user_id']; 

    $sql = "
    SELECT
        n.id AS id,
        n.order_id,
        n.provider_confirm AS provider_confirm,
        n.client_confirm AS client_confirm,
        n.Payment_status AS Payment_status,
        n.price AS price,
        o.order_date AS order_date,
        o.order_time AS order_time,
        o.order_details AS order_details,
        s.service_name AS service_name,
        
        sp.provider_name AS provider_name,
        (
            SELECT IFNULL(AVG(e.eva_byno), 0)
            FROM evaluations e
            JOIN given_services gs2 ON e.provider_service_id = gs2.id
            WHERE gs2.provider_id = sp.id
        ) AS provider_rating,
        sp.provider_image AS provider_image,
        n.provider_reject_reason AS provider_reject_reason,
        n.client_reject_reason AS client_reject_reason,

        c.category_name AS category_name

    FROM notifications n
    JOIN order_services o ON o.id = n.order_id         
    JOIN services s ON s.id = o.service_id             
    JOIN server_providers sp ON sp.id = o.provider_id  
    JOIN categories c ON  c.id = s.category_id 
    WHERE o.client_id = :client_id
    ORDER BY n.id DESC
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['client_id' => $client_id]);

    $orders = array();

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $orders[] = array(
            "id"              => (int)$row['id'],
            "order_id"        => (int)$row['order_id'],
            "provider_confirm" => isset($row['provider_confirm']) ? (int)$row['provider_confirm'] : null,
            "client_confirm"   => isset($row['client_confirm'])   ? (int)$row['client_confirm']   : null,
            "Payment_status"   => isset($row['Payment_status'])   ? (int)$row['Payment_status']   : null,
            "price"            => (int)$row['price'],
            "order_date"       => $row['order_date'], 
            "order_time"       => $row['order_time'],
            "service_name"     => $row['service_name'],
            "category_name"    => $row['category_name'],
            "provider_image"   => base64_encode($row['provider_image']),
            "provider_name"    => $row['provider_name'],
            "provider_rating"  => isset($row['provider_rating']) ? (float)$row['provider_rating'] : null,
            "order_details"    => $row['order_details'] ?? null,
            
            "provider_reject_reason" => $row['provider_reject_reason'] ?? null,
            "client_reject_reason"   => $row['client_reject_reason'] ?? null,
        );
    }

    echo json_encode($orders, JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    echo json_encode(array("error" => $e->getMessage()));
}
?>
