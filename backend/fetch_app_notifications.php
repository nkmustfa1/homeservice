<?php
header('Content-Type: application/json');

$servername = "127.0.0.1";
$username   = "root";
$password   = "";
$dbname     = "homeservices";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("فشل الاتصال: " . $conn->connect_error);
}

$client_id = isset($_GET['client_id']) ? $_GET['client_id'] : '';
if (empty($client_id)) {
    echo json_encode(['success' => false, 'message' => 'معرّف العميل مفقود.']);
    exit();
}

$sql = "
  SELECT 
    id,
    admin_id,
    notification_title,
    notification_text,
    destination,
    client_id,
    updated_at AS notification_date
  FROM app_notifications
  WHERE 
    destination = 'clients'
    OR (
      destination = 'specific_client'
      AND client_id = '" . $conn->real_escape_string($client_id) . "'
    )
  ORDER BY updated_at DESC
";

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $notifications = [];
    while ($row = $result->fetch_assoc()) {
        $notifications[] = [
            'id'                => $row['id'],
            'admin_id'          => $row['admin_id'],
            'notification_title'=> $row['notification_title'],
            'notification_text' => $row['notification_text'],
            'destination'       => $row['destination'],
            'client_id'         => $row['client_id'],
            'notification_date' => $row['notification_date'],
        ];
    }
    echo json_encode(['success' => true, 'notifications' => $notifications]);
} else {
    echo json_encode(['success' => false, 'message' => 'لا توجد إشعارات للعميل.']);
}

$conn->close();
?>
