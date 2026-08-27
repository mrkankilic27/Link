<?php
require_once 'db.php';

if (isset($_POST['sil_id'])) {
    $id = filter_var($_POST['sil_id'], FILTER_VALIDATE_INT);
    if ($id !== false && $id > 0) {
        $stmt = $pdo->prepare('SELECT kiyafet_yolu, fis_yolu FROM links WHERE id = ?');
        $stmt->execute([$id]);
        $link = $stmt->fetch();
        if ($link) {
            foreach ([$link['kiyafet_yolu'], $link['fis_yolu']] as $relativePath) {
                $filePath = __DIR__ . DIRECTORY_SEPARATOR . ltrim((string) $relativePath, '/\\');
                if (is_file($filePath)) {
                    unlink($filePath);
                }
            }
        }
        $del = $pdo->prepare('DELETE FROM links WHERE id = ?');
        $del->execute([$id]);
    }
    header('Location: index.php');
    exit;
}

$links = $pdo->query('SELECT * FROM links ORDER BY id DESC')->fetchAll();
function e(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>Link Yönetim Paneli</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f7f6; margin: 0; padding: 20px; }
        .container { max-width: 1100px; margin: auto; background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        h2 { color: #00796b; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; border-bottom: 1px solid #ddd; text-align: left; vertical-align: middle; }
        th { background-color: #00796b; color: white; }
        img { width: 80px; height: 80px; object-fit: cover; border-radius: 8px; border: 1px solid #ccc; }
        .not-kutusu { font-size: 13px; color: #555; max-width: 250px; }
        .btn-sil { background-color: #e53935; color: white; border: none; padding: 8px 12px; border-radius: 6px; cursor: pointer; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Kıyafet ve Fiş Eşleşmeleri Yönetim Paneli</h2>
        <table>
            <thead><tr><th>ID</th><th>Başlık</th><th>Kıyafet</th><th>Fiş</th><th>OCR Notu</th><th>Kayıt Tarihi</th><th>İşlem</th></tr></thead>
            <tbody>
                <?php if (empty($links)): ?>
                    <tr><td colspan="7" style="text-align:center;">Henüz kayıt bulunmuyor.</td></tr>
                <?php else: foreach ($links as $row): ?>
                    <tr>
                        <td><?= (int) $row['id'] ?></td>
                        <td><strong><?= e((string) $row['baslik']) ?></strong></td>
                        <td><img src="<?= e((string) $row['kiyafet_yolu']) ?>" alt="Kıyafet"></td>
                        <td><img src="<?= e((string) $row['fis_yolu']) ?>" alt="Fiş"></td>
                        <td class="not-kutusu"><?= e((string) $row['not_metni']) ?></td>
                        <td><?= e((string) $row['created_at']) ?></td>
                        <td><form method="POST" onsubmit="return confirm('Bu kaydı silmek istediğinize emin misiniz?');"><input type="hidden" name="sil_id" value="<?= (int) $row['id'] ?>"><button type="submit" class="btn-sil">Sil</button></form></td>
                    </tr>
                <?php endforeach; endif; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
