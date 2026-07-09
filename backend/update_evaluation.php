<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "homeservices";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("فشل الاتصال: " . $conn->connect_error);
}

if(isset($_POST['review_id']) && isset($_POST['client_id']) && isset($_POST['provider_id']) && isset($_POST['service_id']) && isset($_POST['eva_byno']) && isset($_POST['comment'])) {
    $review_id = $_POST['review_id'];
    $client_id = $_POST['client_id'];
    $provider_id = $_POST['provider_id'];
    $service_id = $_POST['service_id'];
    $eva_byno = $_POST['eva_byno'];
    $comment = $_POST['comment'];  

    $stmt = $conn->prepare("UPDATE evaluations SET eva_byno = ?, comment = ? WHERE id = ?");
    $stmt->bind_param("sss", $eva_byno, $comment, $review_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "تم تعديل التقييم بنجاح"]);
    } else {
        echo json_encode(["success" => false, "message" => "حدث خطأ أثناء تعديل التقييم: " . $stmt->error]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "معلومات غير مكتملة"]);
}

$conn->close();
?>
