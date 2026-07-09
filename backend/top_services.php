<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$host     = "127.0.0.1";
$user     = "root";
$pass     = "";
$dbname   = "homeservices";

try {
    $pdo = new PDO("mysql:host={$host};dbname={$dbname}", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $sql = "
        SELECT 
            s.id           AS service_id,
            s.service_name,
            s.category_id,
            c.category_name,
            c.icon         AS category_icon,
            COUNT(os.id)   AS total_requests
        FROM order_services os
        JOIN services s ON os.service_id = s.id
        JOIN categories c ON s.category_id = c.id
        WHERE s.service_statues = 1
        GROUP BY s.id
        ORDER BY total_requests DESC
        LIMIT 10
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    $services = [];
    while ($row = $stmt->fetch()) {
        $iconBlob = $row['category_icon'];
      
            $base64     = base64_encode($iconBlob);
       

        $services[] = [
            'service_id'    => $row['service_id'],
            'service_name'  => $row['service_name'],
            'category_id'   => $row['category_id'],
            'category_name' => $row['category_name'],
            'total_requests'=> (int)$row['total_requests'],
            'category_icon' => $base64
        ];
    }

    echo json_encode([
        'success'  => true,
        'services' => $services
    ]);

} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'DB Error: ' . $e->getMessage()
    ]);
}
