<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$host = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "homeservices";

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $e->getMessage()
    ]));
}

$input = file_get_contents("php://input");
$data  = json_decode($input, true);

$response = [
    'success' => false,
    'message' => 'Something went wrong!'
];

if (!isset($data['id']) || empty($data['id'])) {
    $response['message'] = 'Missing user ID';
    echo json_encode($response);
    exit;
}

$id          = $data['id'];
$client_name = isset($data['name'])   ? $data['name']   : '';
$telphone    = isset($data['telphone'])  ? $data['telphone']  : '';
$address     = isset($data['address'])? $data['address']: '';
$image_base64 = isset($data['image']) ? $data['image'] : null;  
$coordinates = isset($data['coordinates']) ? $data['coordinates'] : null;

if (empty($image_base64)) {
    if ($coordinates) {
        $sql = "UPDATE clients
                SET client_name = :client_name,
                    telphone    = :telphone,
                    address     = :address,
                    coordinates = ST_GeomFromText(:coordinates)
                WHERE id = :id";
        
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':client_name', $client_name);
        $stmt->bindParam(':telphone', $telphone);
        $stmt->bindParam(':address', $address);
        $stmt->bindParam(':coordinates', $coordinates);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    } else {
        $sql = "UPDATE clients
                SET client_name = :client_name,
                    telphone    = :telphone,
                    address     = :address
                WHERE id = :id";
        
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':client_name', $client_name);
        $stmt->bindParam(':telphone', $telphone);
        $stmt->bindParam(':address', $address);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    }
} else {
    if ($coordinates) {
        $sql = "UPDATE clients
                SET client_name = :client_name,
                    telphone    = :telphone,
                    address     = :address,
                    image       = :image,
                    coordinates = ST_GeomFromText(:coordinates)
                WHERE id = :id";

        $stmt = $conn->prepare($sql);
        
        $image_data = base64_decode($image_base64);
        if ($image_data === false) {
            $response['message'] = 'خطأ في فك تشفير الصورة';
            echo json_encode($response);
            exit;
        }
        
        $stmt->bindParam(':client_name', $client_name);
        $stmt->bindParam(':telphone', $telphone);
        $stmt->bindParam(':address', $address);
        $stmt->bindParam(':image', $image_data, PDO::PARAM_LOB);
        $stmt->bindParam(':coordinates', $coordinates);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    } else {
        $sql = "UPDATE clients
                SET client_name = :client_name,
                    telphone    = :telphone,
                    address     = :address,
                    image       = :image
                WHERE id = :id";

        $stmt = $conn->prepare($sql);
        
        $image_data = base64_decode($image_base64);
        if ($image_data === false) {
            $response['message'] = 'خطأ في فك تشفير الصورة';
            echo json_encode($response);
            exit;
        }
        
        $stmt->bindParam(':client_name', $client_name);
        $stmt->bindParam(':telphone', $telphone);
        $stmt->bindParam(':address', $address);
        $stmt->bindParam(':image', $image_data, PDO::PARAM_LOB);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    }
}

if (!$stmt) {
    $response['message'] = 'Prepare failed: ' . $conn->errorInfo()[2];
    echo json_encode($response);
    exit;
}

try {
    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = 'تم تحديث البيانات بنجاح';
    } else {
        $response['message'] = 'فشل التحديث: ' . $conn->errorInfo()[2];
    }
} catch (PDOException $e) {
    $response['message'] = 'Error executing query: ' . $e->getMessage();
    error_log('Error: ' . $e->getMessage());
}

echo json_encode($response);

$stmt = null;
$conn = null;
?>
