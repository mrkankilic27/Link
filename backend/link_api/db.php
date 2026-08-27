<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Authorization, Content-Type');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$host = getenv('LINK_DB_HOST') ?: 'localhost';
$db = getenv('LINK_DB_NAME') ?: 'link_db';
$user = getenv('LINK_DB_USER') ?: 'root';
$pass = getenv('LINK_DB_PASSWORD') ?: '';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
    $column = $pdo->query("SHOW COLUMNS FROM links LIKE 'user_id'")->fetch();
    if (!$column) {
        $pdo->exec("ALTER TABLE links ADD COLUMN user_id VARCHAR(128) NULL, ADD INDEX idx_links_user_id (user_id)");
    }
    $receiptColumn = $pdo->query("SHOW COLUMNS FROM links LIKE 'receipt_data'")->fetch();
    if (!$receiptColumn) {
        $pdo->exec("ALTER TABLE links ADD COLUMN receipt_data JSON NULL");
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Veritabanı bağlantı hatası']);
    exit;
}
?>
