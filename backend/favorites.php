<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = "127.0.0.1";
$dbname = "homeservices";
$user = "root";
$pass = "";

$client_id = isset($_GET['client_id']) ? intval($_GET['client_id']) : 0;

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($client_id <= 0) {
        echo json_encode(["success" => false, "message" => "Invalid client_id"]);
        exit;
    }

    $sql = "
        SELECT 
            f.client_id,
            f.provider_service_id,
            gs.service_description,
            sp.id AS provider_id,
            sp.provider_name,
            sp.provider_image,
            s.id AS service_id,
            s.service_name,
            (
                SELECT IFNULL(AVG(e.eva_byno), 0)
                FROM evaluations e
                WHERE e.provider_service_id = gs.id
            ) AS average_rating
        FROM favorites f
        JOIN given_services gs ON f.provider_service_id = gs.id
        JOIN server_providers sp ON gs.provider_id = sp.id
        JOIN services s ON gs.service_id = s.id
        WHERE f.client_id = :client_id
        ORDER BY gs.id DESC
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':client_id', $client_id, PDO::PARAM_INT);
    $stmt->execute();

    $favorites = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($favorites as $index => $row) {
        if (!empty($row['provider_image'])) {
            $favorites[$index]['provider_image'] = base64_encode($row['provider_image']);
        } else {
            $favorites[$index]['provider_image'] = "";
        }
    }
    echo json_encode([
        "success" => true,
        "favorites" => $favorites
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
