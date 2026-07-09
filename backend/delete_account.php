<?php
header("Content-Type: application/json");
$host = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "homeservices";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $user_id = $_POST['user_id'];
    $password = $_POST['password'];  

    $sql = "SELECT password FROM clients WHERE id = :user_id";
    $stmt = $pdo->prepare($sql);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && password_verify($password, $user['password'])) {
        $sql_delete = "DELETE FROM clients WHERE id = :user_id";
        $stmt_delete = $pdo->prepare($sql_delete);
        $stmt_delete->bindParam(':user_id', $user_id, PDO::PARAM_INT);

        if ($stmt_delete->execute()) {
            echo json_encode(["success" => true, "message" => "Account deleted"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to delete"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Incorrect password"]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "DB Error: " . $e->getMessage()]);
}
?>
