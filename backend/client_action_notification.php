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

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $notification_id = $_POST['notification_id'] ?? null;
        $action = $_POST['action'] ?? null; 

        if (!$notification_id || !$action) {
            echo json_encode(['success' => false, 'message' => 'Invalid parameters']);
            exit;
        }

        if ($action === 'accept') {
            $sql = "UPDATE notifications
                    SET client_confirm = 1,
                        client_reject_reason = NULL
                    WHERE id = :notification_id";

            $stmt = $pdo->prepare($sql);
            $stmt->bindParam(':notification_id', $notification_id, PDO::PARAM_INT);
            $stmt->execute();

            echo json_encode(['success' => true, 'message' => 'Accepted successfully']);

        } elseif ($action === 'reject') {
            $reject_reason = $_POST['reject_reason'] ?? '';

            $sql = "UPDATE notifications
                    SET client_confirm = 0,
                        client_reject_reason = :reject_reason
                    WHERE id = :notification_id";

            $stmt = $pdo->prepare($sql);
            $stmt->bindParam(':reject_reason', $reject_reason, PDO::PARAM_STR);
            $stmt->bindParam(':notification_id', $notification_id, PDO::PARAM_INT);
            $stmt->execute();

            echo json_encode(['success' => true, 'message' => 'Rejected successfully']);

        } else {
            echo json_encode(['success' => false, 'message' => 'Unknown action']);
        }

    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid request method']);
    }

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
