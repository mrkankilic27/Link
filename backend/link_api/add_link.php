<?php
header('Content-Type: application/json');
require_once 'db.php';
require_once 'auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Geçersiz istek metodu.']);
    exit;
}

$userId = requireAuthUserId();
$baslik = $_POST['baslik'] ?? 'İsimsiz Eşleşme';
$notMetni = $_POST['not'] ?? '';
$receiptData = $_POST['receipt_data'] ?? '{}';

if (!is_string($baslik) || strlen($baslik) > 200 || !is_string($notMetni) || strlen($notMetni) > 5000 || !is_string($receiptData) || strlen($receiptData) > 20000 || json_decode($receiptData, true) === null) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Metin alanları geçersiz.']);
    exit;
}

$uploadDir = __DIR__ . DIRECTORY_SEPARATOR . 'uploads' . DIRECTORY_SEPARATOR;
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

$allowedTypes = [
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp',
];

$saveUpload = function (string $field) use ($allowedTypes, $uploadDir): string {
    if (!isset($_FILES[$field]) || $_FILES[$field]['error'] !== UPLOAD_ERR_OK) {
        throw new RuntimeException('Gerekli görsel yüklenemedi.');
    }
    if ($_FILES[$field]['size'] > 10 * 1024 * 1024) {
        throw new RuntimeException('Görsel boyutu 10 MB sınırını aşamaz.');
    }

    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $_FILES[$field]['tmp_name']);
    finfo_close($finfo);
    $extension = strtolower(pathinfo($_FILES[$field]['name'], PATHINFO_EXTENSION));
    if (!isset($allowedTypes[$mimeType]) || $extension !== $allowedTypes[$mimeType]) {
        throw new RuntimeException('Yalnızca JPG, PNG veya WEBP görseller kabul edilir.');
    }

    $fileName = bin2hex(random_bytes(16)) . '.' . $allowedTypes[$mimeType];
    $targetPath = $uploadDir . $fileName;
    if (!move_uploaded_file($_FILES[$field]['tmp_name'], $targetPath)) {
        throw new RuntimeException('Görsel sunucuya kaydedilemedi.');
    }
    return 'uploads/' . $fileName;
};

$kiyafetYolu = '';
$fisYolu = '';

try {
    $kiyafetYolu = $saveUpload('kiyafet');
    $fisYolu = $saveUpload('fis');
    $stmt = $pdo->prepare('INSERT INTO links (user_id, baslik, kiyafet_yolu, fis_yolu, not_metni, receipt_data, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())');
    $stmt->execute([$userId, $baslik, $kiyafetYolu, $fisYolu, $notMetni, $receiptData]);
    echo json_encode(['status' => 'success', 'message' => 'Kayıt başarıyla eklendi.']);
} catch (Throwable $e) {
    if ($kiyafetYolu !== '') @unlink(__DIR__ . DIRECTORY_SEPARATOR . $kiyafetYolu);
    if ($fisYolu !== '') @unlink(__DIR__ . DIRECTORY_SEPARATOR . $fisYolu);
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
