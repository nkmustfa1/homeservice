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

if(isset($_POST['review_id'])) {
    $review_id = $_POST['review_id'];

    if(!empty($review_id)) {
        $query = "DELETE FROM evaluations WHERE id = ?"; 

        if ($stmt = $conn->prepare($query)) {
            $stmt->bind_param("i", $review_id);

            if ($stmt->execute()) {
                echo json_encode(["success" => true, "message" => "تم حذف التقييم بنجاح"]);
            } else {
                echo json_encode(["success" => false, "message" => "حدث خطأ أثناء الحذف"]);
            }

            $stmt->close();
        } else {
            echo json_encode(["success" => false, "message" => "فشل الاتصال بقاعدة البيانات"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "معرّف التقييم مفقود"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "الطلب غير صحيح"]);
}

$conn->close();
?>
