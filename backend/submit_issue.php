<?php
header('Content-Type: application/json');

$servername = "127.0.0.1";
$username   = "root";
$password   = "";
$dbname     = "homeservices";

$conn = new mysqli($servername, $username, $password, $dbname);

$client_id = $_POST['client_id'];  
$issue_type = $_POST['issue_type']; 
$message = $_POST['message'];  

if (empty($client_id) || empty($issue_type) || empty($message)) {
    echo json_encode(['status' => 'error', 'message' => 'يرجى ملء جميع الحقول.']);
    exit();
}

$sql = "INSERT INTO enquiries (client_id, issue_type, message, created_at, updated_at) 
        VALUES (?, ?, ?, NOW(), NOW())";  
$stmt = $conn->prepare($sql);

$stmt->bind_param("iss", $client_id, $issue_type, $message);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'تم إرسال المشكلة بنجاح']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'فشل إرسال المشكلة']);
    echo "Error: " . $stmt->error; 
}

$stmt->close();
$conn->close();
?>
