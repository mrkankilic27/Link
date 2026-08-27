<?php
function jsonError(string $message, int $statusCode): void
{
    http_response_code($statusCode);
    echo json_encode(['status' => 'error', 'message' => $message]);
    exit;
}

function getBearerToken(): ?string
{
    $headers = function_exists('getallheaders') ? getallheaders() : [];
    $authorization = $headers['Authorization'] ?? $headers['authorization'] ?? ($_SERVER['HTTP_AUTHORIZATION'] ?? '');

    if (!preg_match('/^Bearer\s+(.+)$/i', $authorization, $matches)) {
        return null;
    }

    return trim($matches[1]);
}

function requireAuthUserId(): string
{
    $token = getBearerToken();
    if ($token === null) {
        jsonError('Kimlik doğrulaması gerekli.', 401);
    }

    $ch = curl_init('https://oauth2.googleapis.com/tokeninfo?id_token=' . rawurlencode($token));
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 10,
        CURLOPT_SSL_VERIFYPEER => true,
        CURLOPT_SSL_VERIFYHOST => 2,
    ]);
    $response = curl_exec($ch);
    $statusCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($response === false || $statusCode !== 200) {
        jsonError('Geçersiz veya süresi dolmuş kimlik doğrulama belirteci.', 401);
    }

    $claims = json_decode($response, true);
    $expiresAt = isset($claims['exp']) ? (int) $claims['exp'] : 0;
    if (
        !is_array($claims) ||
        ($claims['aud'] ?? '') !== 'linkapp-b258a' ||
        ($claims['iss'] ?? '') !== 'https://securetoken.google.com/linkapp-b258a' ||
        empty($claims['sub']) ||
        $expiresAt <= time()
    ) {
        jsonError('Geçersiz Firebase kimliği.', 401);
    }

    return (string) $claims['sub'];
}
?>
