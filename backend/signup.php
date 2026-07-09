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
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $data = json_decode(file_get_contents("php://input"), true);
    if (!$data) {
        $data = $_POST; 
    }

    if (!isset($data['name'], $data['email'], $data['telphone'], $data['address'], $data['password'], $data['confirm_password'], $data['agree_terms'])) {
        echo json_encode(["success" => false, "message" => "الحقول المطلوبة مفقودة."]);
        exit;
    }

    $name       = trim($data['name']);
    $email      = trim($data['email']);
    $telphone   = trim($data['telphone']);
    $address    = trim($data['address']);
    $password   = trim($data['password']);
    $confirmPwd = trim($data['confirm_password']);
    $agreeTerms = $data['agree_terms'];

    if (!preg_match('/^7\d{8}$/', $telphone)) {
        echo json_encode(["success" => false, "message" => "رقم الهاتف يجب أن يبدأ بـ 7 ويتكون من 9 أرقام."]);
        exit;
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(["success" => false, "message" => "البريد الإلكتروني غير صالح."]);
        exit;
    }

    if (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$/', $password)) {
        echo json_encode(["success" => false, "message" => "كلمة المرور يجب أن تحتوي على حرف كبير، حرف صغير، رقم ورمز خاص."]);
        exit;
    }

    if ($password !== $confirmPwd) {
        echo json_encode(["success" => false, "message" => "كلمات المرور لا تتطابق."]);
        exit;
    }

    if (!$agreeTerms) {
        echo json_encode(["success" => false, "message" => "يجب الموافقة على الشروط."]);
        exit;
    }

    $coordinates = isset($data['coordinates']) ? $data['coordinates'] : null;
    if ($coordinates) {
        if (!preg_match('/^POINT\(\s*-?\d+(\.\d+)?\s*-?\d+(\.\d+)?\s*\)$/', $coordinates)) {
            echo json_encode(["success" => false, "message" => "تنسيق الإحداثيات غير صحيح."]);
            exit;
        }
    }

    $stmt = $conn->prepare("SELECT COUNT(*) FROM clients WHERE email = :email");
    $stmt->bindParam(':email', $email);
    $stmt->execute();
    $emailExists = $stmt->fetchColumn();

    if ($emailExists > 0) {
        $stmt = $conn->prepare("SELECT COUNT(*) FROM clients WHERE email = :email AND telphone = :telphone");
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':telphone', $telphone);
        $stmt->execute();
        $phoneMatches = $stmt->fetchColumn();

        if ($phoneMatches == 0) {
            echo json_encode(["success" => false, "message" => "هذا البريد الإلكتروني مستخدم بالفعل."]);
            exit;
        }
    }

    if ($emailExists > 0) {
        $stmt = $conn->prepare("UPDATE clients SET client_name = :name, address = :address, password = :password, coordinates = ST_GeomFromText(:coordinates), image = :image WHERE email = :email AND telphone = :telphone");

        if (isset($data['image']) && !empty($data['image'])) {
            $imageData = base64_decode($data['image']);
            $stmt->bindParam(':image', $imageData, PDO::PARAM_LOB);  
        } else {
            $stmt->bindValue(':image', null, PDO::PARAM_NULL); 
        }

        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':address', $address);
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $stmt->bindParam(':password', $hashedPassword);
        
        if ($coordinates) {
            $stmt->bindParam(':coordinates', $coordinates); 
        } else {
            $stmt->bindValue(':coordinates', null, PDO::PARAM_NULL); 
        }
        
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':telphone', $telphone);

        $stmt->execute();

        echo json_encode(["success" => true, "message" => "تم تحديث بيانات المستخدم بنجاح."]);
    } else {
        $stmt = $conn->prepare("INSERT INTO clients (client_name, email, telphone, address, password, image, coordinates) 
                                VALUES (:name, :email, :telphone, :address, :password, :image, ST_GeomFromText(:coordinates))");

        if (isset($data['image']) && !empty($data['image'])) {
            $imageData = base64_decode($data['image']);
            $stmt->bindParam(':image', $imageData, PDO::PARAM_LOB); 
        } else {
            $stmt->bindValue(':image', null, PDO::PARAM_NULL); 
        }

        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':telphone', $telphone);
        $stmt->bindParam(':address', $address);
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $stmt->bindParam(':password', $hashedPassword);
        
        if ($coordinates) {
            $stmt->bindParam(':coordinates', $coordinates);
        } else {
            $stmt->bindValue(':coordinates', null, PDO::PARAM_NULL);
        }

        $stmt->execute();

        echo json_encode(["success" => true, "message" => "تم تسجيل المستخدم بنجاح."]);
    }

} catch (PDOException $e) {
    error_log("Database Error: " . $e->getMessage());
    echo json_encode(["success" => false, "message" => "خطأ في قاعدة البيانات: " . $e->getMessage()]);
}
?>
