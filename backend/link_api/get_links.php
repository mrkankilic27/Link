<?php
header('Content-Type: application/json');
require_once 'db.php';
require_once 'auth.php';

try {
    $userId = requireAuthUserId();
    $stmt = $pdo->prepare('SELECT * FROM links WHERE user_id = ? ORDER BY id DESC');
    $stmt->execute([$userId]);
    echo json_encode(['status' => 'success', 'data' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Kayıtlar alınamadı.']);
}
?>
