<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$servername = "127.0.0.1";
$username   = "root";
$password   = "";
$dbname     = "homeservices";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed"]));
}

$email = $_POST['email'];
$otp_code = $_POST['otp_code'];

$sql = "SELECT otp_code, otp_expiration FROM clients WHERE email='$email'";
$result = $conn->query($sql);
$row = $result->fetch_assoc();

if ($row) {
    $storedOtp = $row['otp_code'];
    $otp_expiry_time = strtotime($row['otp_expiration']);

    if (time() > $otp_expiry_time) {
        $delete_sql = "UPDATE clients SET otp_code=NULL, otp_expiration=NULL WHERE email='$email'";
        $conn->query($delete_sql);
        echo json_encode(["status" => "error", "message" => "رمز OTP قد انتهت صلاحيتة."]);
    } 
     elseif ($otp_code == $storedOtp) {
        $update_sql = "UPDATE clients SET acount_state=1 WHERE email='$email'";
        $conn->query($update_sql);
        echo json_encode(["status" => "success", "message" => "OTP صحيح وتم تفعيل الحساب"]);
    } else {
        echo json_encode(["status" => "error", "message" => "رمز OTP غير صحيح"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "البريد الإلكتروني غير مسجل"]);
}

$conn->close();
?>
