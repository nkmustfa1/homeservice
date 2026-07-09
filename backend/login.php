<?php
header("Content-Type: application/json");
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

$host = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "homeservices";

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $data = json_decode(file_get_contents("php://input"), true);
    if (!$data) {
        $data = $_POST; 
    }

    $email = isset($data['email']) ? trim($data['email']) : '';
    $password = isset($data['password']) ? trim($data['password']) : '';

    if (empty($email) || empty($password)) {
        echo json_encode(["success" => false, "message" => "يجب تعبئه جميع الحقول"]);
        exit();
    }

    $stmt = $conn->prepare("SELECT * FROM clients WHERE email = :email");
    $stmt->bindParam(':email', $email);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo json_encode([
            "success" => false,
            "message" => "هذا الحساب غير موجود"
        ]);
        exit();
    }
    error_log("Stored Hash: " . $user['password']);
    error_log("Entered Password: " . $password);

    
    if ($user) {
        if ($user['acount_state'] === 0) {
            echo json_encode([
                "success" => false,
                "message" => "هذا الحساب محظور"
            ]);
            exit();
        } elseif (is_null($user['acount_state']) || $user['acount_state'] === '') {
            echo json_encode([
                "success" => false,
                "message" => "لم يتم التحقق من الحساب."
            ]);
            exit();
        }
        

        if (password_verify($password, $user['password'])) {
            echo json_encode([
                "success" => true,
                "message" => "Login successful.",
                "user_id" => $user['id'],     
                "name" => $user['client_name'] 
               
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "خطأ في كلمة السر ."
            ]);
        }
    } else {
        echo json_encode([
            "success" => false,
            "message" => "خطأ في كلمة السر او البريد."
        ]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
