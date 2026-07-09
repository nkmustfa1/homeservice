<?php
header('Content-Type: application/json');

$servername = "127.0.0.1";
$username   = "root";
$password   = "";
$dbname     = "homeservices";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Database connection failed"
    ]));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = isset($_POST['action']) ? trim($_POST['action']) : 'forgot';

    if ($action === 'change') {
        
        $user_id = isset($_POST['user_id']) ? trim($_POST['user_id']) : '';
        $old_password = isset($_POST['old_password']) ? trim($_POST['old_password']) : '';
        $new_password = isset($_POST['new_password']) ? trim($_POST['new_password']) : '';
        $confirm_password = isset($_POST['confirm_password']) ? trim($_POST['confirm_password']) : '';

        if (empty($user_id) || empty($old_password) || empty($new_password) || empty($confirm_password)) {
            echo json_encode([
                'success' => false,
                'message' => 'جميع الحقول مطلوبة (معرّف المستخدم، كلمة المرور الحالية، الجديدة، والتأكيد)'
            ]);
            exit;
        }

        if ($new_password !== $confirm_password) {
            echo json_encode([
                'success' => false,
                'message' => 'كلمتا المرور الجديدة غير متطابقتين'
            ]);
            exit;
        }

        $stmt_check_old_password = $conn->prepare("SELECT password FROM clients WHERE id = ?");
        if (!$stmt_check_old_password) {
            echo json_encode([
                'success' => false,
                'message' => 'خطأ في الإتصال بقاعدة البيانات'
            ]);
            exit;
        }
        $stmt_check_old_password->bind_param("s", $user_id);
        $stmt_check_old_password->execute();
        $result = $stmt_check_old_password->get_result();
        
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $hashed_password_db = $row['password'];

if (!password_verify($old_password, $hashed_password_db)) {
    echo json_encode([
        'success' => false,
        'message' => 'كلمة المرور الحالية غير صحيحة'
    ]);
    exit;
}

if (password_verify($new_password, $hashed_password_db)) {
    echo json_encode([
        'success' => false,
        'message' => 'كلمة السر الجديدة هي نفسها كلمة السر السابقة'
    ]);
    exit;
}
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'لم يتم العثور على مستخدم بهذا المعرّف'
            ]);
            exit;
        }
        $stmt_check_old_password->close();

        $hashed_new_password = password_hash($new_password, PASSWORD_DEFAULT);
        $stmt_update = $conn->prepare("UPDATE clients SET password = ? WHERE id = ?");
        if (!$stmt_update) {
            echo json_encode([
                'success' => false,
                'message' => 'خطأ في الإتصال بقاعدة البيانات'
            ]);
            exit;
        }
        $stmt_update->bind_param("ss", $hashed_new_password, $user_id);

        if ($stmt_update->execute()) {
            if ($stmt_update->affected_rows > 0) {
                echo json_encode([
                    'success' => true,
                    'message' => 'تم تغيير كلمة المرور بنجاح'
                ]);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'لم يتم العثور على مستخدم بهذا المعرّف'
                ]);
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'حدث خطأ أثناء تحديث كلمة المرور'
            ]);
        }
        $stmt_update->close();
    } else {

        $email = isset($_POST['email']) ? trim($_POST['email']) : '';
        $new_password = isset($_POST['new_password']) ? trim($_POST['new_password']) : '';

        if (empty($email) || empty($new_password)) {
            echo json_encode([
                'success' => false,
                'message' => 'البريد الإلكتروني وكلمة المرور الجديدة مطلوبان'
            ]);
            exit;
        }

        $stmt_check_old_password = $conn->prepare("SELECT password FROM clients WHERE email = ?");
        if (!$stmt_check_old_password) {
            echo json_encode([
                'success' => false,
                'message' => 'خطأ في الإتصال بقاعدة البيانات'
            ]);
            exit;
        }
        $stmt_check_old_password->bind_param("s", $email);
        $stmt_check_old_password->execute();
        $result = $stmt_check_old_password->get_result();
        
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $hashed_password_db = $row['password'];

            if (password_verify($new_password, $hashed_password_db)) {
                echo json_encode([
                    'success' => false,
                    'message' => 'كلمة السر الجديدة هي نفسها كلمة السر السابقة'
                ]);
                exit;
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني'
            ]);
            exit;
        }
        $stmt_check_old_password->close();

        $hashed_new_password = password_hash($new_password, PASSWORD_DEFAULT);

        $stmt_update = $conn->prepare("UPDATE clients SET password = ? WHERE email = ?");
        if (!$stmt_update) {
            echo json_encode([
                'success' => false,
                'message' => 'خطأ في الإتصال بقاعدة البيانات'
            ]);
            exit;
        }
        $stmt_update->bind_param("ss", $hashed_new_password, $email);

        if ($stmt_update->execute()) {
            if ($stmt_update->affected_rows > 0) {
                echo json_encode([
                    'success' => true,
                    'message' => 'تم تحديث كلمة المرور بنجاح'
                ]);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني'
                ]);
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'حدث خطأ أثناء تحديث كلمة المرور'
            ]);
        }
        $stmt_update->close();
    }

} else {
    echo json_encode([
        'success' => false,
        'message' => 'طريقة الطلب غير صالحة'
    ]);
}

$conn->close();
?>
