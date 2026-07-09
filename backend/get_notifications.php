<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "homeservices";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $sql = "SELECT
                n.id AS notification_id,
                os.client_id,
                os.provider_id, 
                os.service_id,
                s.service_name,
                sp.provider_name,
                n.price,
                n.service_replay_details,
                n.provider_reject_reason,
                
                n.provider_confirm,
                n.client_confirm,
                n.Payment_status,  
                n.updated_at AS notification_date
            FROM
                notifications n
            JOIN
                order_services os ON n.order_id = os.id
            JOIN
                services s ON os.service_id = s.id
            JOIN
                server_providers sp ON os.provider_id = sp.id
            WHERE
                os.client_id = :client_id
                AND (
                    n.price IS NOT NULL
                    OR n.provider_confirm IS NOT NULL
                    
                )
            ORDER BY
                n.updated_at DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->bindParam(':client_id', $_GET['client_id'], PDO::PARAM_INT);

    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $notifications = [];

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $notifications[] = [
                'notification_id'       => $row['notification_id'],
                'client_id'             => $row['client_id'],
                'provider_id'           => $row['provider_id'],
                'service_id'            => $row['service_id'],
                'service_name'          => $row['service_name'],
                'provider_name'         => $row['provider_name'],
                'price'                 => $row['price'],
                'service_replay_details'=> $row['service_replay_details'],
                'provider_reject_reason'=> $row['provider_reject_reason'],
                'provider_confirm'      => $row['provider_confirm'],
                'client_confirm'        => $row['client_confirm'],
                'Payment_status'        => $row['Payment_status'],  
                'notification_date'     => $row['notification_date'],
            ];
            
        }

        echo json_encode(['success' => true, 'notifications' => $notifications]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No notifications found.']);
    }

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>