<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php';
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
$otp_code = rand(100000, 999999);
$otp_expiry = date("Y-m-d H:i:s", strtotime("+10 minutes")); // صلاحية الرمز 10 دقائق

$result = $conn->query("SELECT * FROM clients WHERE email='$email'");
if ($result->num_rows == 0) {
    echo json_encode(["status" => "error", "message" => "البريد الإلكتروني غير مسجل"]);
    exit;
}

$sql_check_expiry = "SELECT otp_expiration FROM clients WHERE email='$email'";
$result_check_expiry = $conn->query($sql_check_expiry);
$row = $result_check_expiry->fetch_assoc();

if ($row) {
    $otp_expiry_time = strtotime($row['otp_expiration']);
    if (time() > $otp_expiry_time) {
        $delete_sql = "UPDATE clients SET otp_code=NULL, otp_expiration=NULL WHERE email='$email'";
        $conn->query($delete_sql);
    }
}

$sql = "UPDATE clients SET otp_code='$otp_code', otp_expiration='$otp_expiry' WHERE email='$email'";

if ($conn->query($sql) === TRUE) {
    $mail = new PHPMailer(true);

    try {
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'your-email@example.com';
        $mail->Password = 'YOUR_APP_PASSWORD';
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port = 587;

        $mail->SMTPDebug = 2;  
        $mail->Debugoutput = 'html';

        $mail->setFrom('servicehome237@gmail.com', 'HomeService');
        $mail->addAddress($email);

        $mail->isHTML(true);
        $mail->Subject = 'رمز التحقق الخاص بك';
        $mail->Body = "
            <p>مرحباً,</p>
            <p>تم طلب رمز التحقق لحسابك في خدمة <b>HomeService</b>.</p>
            <p>رمز التحقق الخاص بك هو: <b>$otp_code</b></p>
            <p>يرجى ملاحظة أن هذا الرمز صالح لمدة 10 دقائق فقط. بعد انتهاء الوقت، سيحتاجك إلى طلب رمز جديد.</p>
            <p>لحماية حسابك، تأكد من عدم مشاركة هذا الرمز مع أي شخص.</p>
            <p>إذا لم تكن قد طلبت هذا الرمز، يرجى تجاهل هذه الرسالة.</p>
            <p>إذا كانت لديك أي أسئلة أو احتجت إلى مساعدة، لا تتردد في الاتصال بنا.</p>
            <br>
            <p>تحياتنا,<br>
            فريق HomeService</p>
            <p><i>هذه الرسالة تم إرسالها تلقائيًا. يرجى عدم الرد عليها.</i></p>
        ";
        
        $mail->send();
        echo json_encode(["status" => "success", "message" => "OTP sent successfully"]);
    } catch (Exception $e) {
        echo json_encode(["status" => "error", "message" => "Mailer Error: {$mail->ErrorInfo}"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Failed to send OTP"]);
}

$conn->close();
?>
