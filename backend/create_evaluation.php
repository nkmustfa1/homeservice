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

if (
    isset($_POST['client_id']) &&
    isset($_POST['provider_id']) &&  
    isset($_POST['service_id']) &&   
    isset($_POST['eva_byno']) &&
    isset($_POST['comment'])
) {
    $client_id           = intval($_POST['client_id']);
    $provider_id         = intval($_POST['provider_id']);  
    $service_id          = intval($_POST['service_id']);  
    $eva_byno            = floatval($_POST['eva_byno']);
    $comment             = $conn->real_escape_string($_POST['comment']);

    $sql_given_services = "SELECT id FROM given_services WHERE provider_id = $provider_id AND service_id = $service_id LIMIT 1";
    $result = $conn->query($sql_given_services);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $provider_service_id = $row['id']; 

        $rate_date = date('Y-m-d');

        $sql_insert_evaluation = "INSERT INTO evaluations (eva_byno, comment, client_id, provider_service_id, created_at, updated_at)
                                  VALUES ('$eva_byno', '$comment', '$client_id', '$provider_service_id', NOW(), NOW())";

        if ($conn->query($sql_insert_evaluation) === TRUE) {
            echo json_encode(["success" => true, "message" => "Evaluation inserted successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => $conn->error]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "No matching provider_service_id found"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
}

$conn->close();
?>
