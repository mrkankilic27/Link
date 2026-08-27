<?php
header('Content-Type: application/json');
require_once 'db.php';
require_once 'auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_POST['id'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Geçersiz istek.']);
    exit;
}

$userId = requireAuthUserId();
$id = filter_var($_POST['id'], FILTER_VALIDATE_INT);
if ($id === false || $id < 1) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Geçersiz kayıt ID.']);
    exit;
}

try {
    $stmt = $pdo->prepare('SELECT kiyafet_yolu, fis_yolu FROM links WHERE id = ? AND user_id = ?');
    $stmt->execute([$id, $userId]);
    $link = $stmt->fetch();
    if (!$link) {
        http_response_code(404);
        echo json_encode(['status' => 'error', 'message' => 'Kayıt bulunamadı.']);
        exit;
    }

    foreach ([$link['kiyafet_yolu'], $link['fis_yolu']] as $relativePath) {
        $filePath = __DIR__ . DIRECTORY_SEPARATOR . ltrim((string) $relativePath, '/\\');
        if (is_file($filePath)) {
            unlink($filePath);
        }
    }

    $deleteStmt = $pdo->prepare('DELETE FROM links WHERE id = ? AND user_id = ?');
    $deleteStmt->execute([$id, $userId]);
    echo json_encode(['status' => 'success', 'message' => 'Kayıt başarıyla silindi.']);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Kayıt silinemedi.']);
}
?>
