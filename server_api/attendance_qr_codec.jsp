<%@page import="com.google.gson.JsonElement"%>
<%@page import="com.google.gson.JsonObject"%>
<%@page import="com.google.gson.JsonParser"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.security.SecureRandom"%>
<%@page import="java.time.Instant"%>
<%@page import="java.util.Base64"%>
<%@page import="javax.servlet.http.HttpSession"%>
<%@page import="javax.crypto.Cipher"%>
<%@page import="javax.crypto.Mac"%>
<%@page import="javax.crypto.spec.IvParameterSpec"%>
<%@page import="javax.crypto.spec.SecretKeySpec"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    private static final String QR_TYPE = "DMS_ANP_ATTENDANCE_QR";
    private static final String PREFIX = "DMSANPQR2.";

    /*
     * Android calls this JSP to create and validate QR data, so the secret stays
     * on the web server. Put this value in server config/env for production.
     */
    private static final String SHARED_SECRET =
            "DMS_ANP_ATTENDANCE_QR_SECRET_2026_CHANGE_ME";

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private static String createQrData(String issuer, String role, int ttlSeconds) throws Exception {
        Instant issuedAt = Instant.now();
        Instant expiresAt = issuedAt.plusSeconds(ttlSeconds);

        JsonObject payload = new JsonObject();
        payload.addProperty("type", QR_TYPE);
        payload.addProperty("issuer", safeUpper(issuer));
        payload.addProperty("role", safeUpper(role));
        payload.addProperty("issued_at", issuedAt.toString());
        payload.addProperty("expires_at", expiresAt.toString());
        payload.addProperty("nonce", issuedAt.toEpochMilli() + "-" + base64Url(randomBytes(12)));

        return encodePayload(payload);
    }

    private static String encodePayload(JsonObject payload) throws Exception {
        byte[] iv = randomBytes(16);
        byte[] encrypted = encrypt(payload.toString().getBytes(StandardCharsets.UTF_8), iv);

        String ivText = base64Url(iv);
        String dataText = base64Url(encrypted);
        String macText = mac(ivText, dataText);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("iv", ivText);
        envelope.addProperty("data", dataText);
        envelope.addProperty("mac", macText);

        return PREFIX + base64Url(envelope.toString().getBytes(StandardCharsets.UTF_8));
    }

    private static JsonObject decodePayload(String qrData) throws Exception {
        if (qrData == null || !qrData.trim().startsWith(PREFIX)) {
            throw new Exception("Invalid QR prefix");
        }

        String envelopeText = new String(
                base64UrlDecode(qrData.trim().substring(PREFIX.length())),
                StandardCharsets.UTF_8
        );
        JsonObject envelope = JsonParser.parseString(envelopeText).getAsJsonObject();
        String ivText = getString(envelope, "iv");
        String dataText = getString(envelope, "data");
        String macText = getString(envelope, "mac");

        if (ivText.isEmpty() || dataText.isEmpty() || macText.isEmpty()) {
            throw new Exception("Invalid QR envelope");
        }
        if (!constantTimeEquals(macText, mac(ivText, dataText))) {
            throw new Exception("Invalid QR signature");
        }

        byte[] decrypted = decrypt(base64UrlDecode(dataText), base64UrlDecode(ivText));
        JsonObject payload = JsonParser.parseString(
                new String(decrypted, StandardCharsets.UTF_8)
        ).getAsJsonObject();

        if (!QR_TYPE.equals(getString(payload, "type"))) {
            throw new Exception("Invalid QR type");
        }
        if (getString(payload, "issuer").isEmpty() || getString(payload, "nonce").isEmpty()) {
            throw new Exception("Invalid QR payload");
        }
        return payload;
    }

    private static byte[] encrypt(byte[] plainBytes, byte[] iv) throws Exception {
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, aesKey(), new IvParameterSpec(iv));
        return cipher.doFinal(plainBytes);
    }

    private static byte[] decrypt(byte[] encryptedBytes, byte[] iv) throws Exception {
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, aesKey(), new IvParameterSpec(iv));
        return cipher.doFinal(encryptedBytes);
    }

    private static SecretKeySpec aesKey() throws Exception {
        return new SecretKeySpec(sha256(SHARED_SECRET + ":enc"), "AES");
    }

    private static String mac(String ivText, String dataText) throws Exception {
        Mac hmac = Mac.getInstance("HmacSHA256");
        hmac.init(new SecretKeySpec(sha256(SHARED_SECRET + ":mac"), "HmacSHA256"));
        return base64Url(hmac.doFinal((ivText + "." + dataText).getBytes(StandardCharsets.UTF_8)));
    }

    private static byte[] sha256(String value) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        return digest.digest(value.getBytes(StandardCharsets.UTF_8));
    }

    private static byte[] randomBytes(int length) {
        byte[] bytes = new byte[length];
        SECURE_RANDOM.nextBytes(bytes);
        return bytes;
    }

    private static String base64Url(byte[] bytes) {
        return Base64.getUrlEncoder().encodeToString(bytes);
    }

    private static byte[] base64UrlDecode(String value) {
        return Base64.getUrlDecoder().decode(value);
    }

    private static boolean constantTimeEquals(String a, String b) {
        byte[] aBytes = a.getBytes(StandardCharsets.UTF_8);
        byte[] bBytes = b.getBytes(StandardCharsets.UTF_8);
        if (aBytes.length != bBytes.length) {
            return false;
        }
        int diff = 0;
        for (int i = 0; i < aBytes.length; i++) {
            diff |= aBytes[i] ^ bBytes[i];
        }
        return diff == 0;
    }

    private static boolean isExpired(JsonObject payload) {
        String expiresAt = getString(payload, "expires_at");
        return expiresAt.isEmpty() || Instant.now().isAfter(Instant.parse(expiresAt));
    }

    private static String getString(JsonObject object, String key) {
        JsonElement element = object.get(key);
        return element == null || element.isJsonNull() ? "" : element.getAsString();
    }

    private static String safeUpper(String value) {
        return value == null ? "" : value.trim().toUpperCase();
    }

    private static int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (Exception ignored) {
            return fallback;
        }
    }

    private static String html(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private static boolean isWebQrAllowed(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object useridObj = session.getAttribute("USERID");
        Object divisiObj = session.getAttribute("DIVISI");
        String userid = useridObj == null ? "" : useridObj.toString().trim();
        String divisi = divisiObj == null ? "" : divisiObj.toString().trim();
        return "ADMIN".equalsIgnoreCase(userid) || "OP".equalsIgnoreCase(divisi);
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    Gson gson = new Gson();
    JsonObject root = new JsonObject();
    String method = request.getParameter("method");
    if (method == null) {
        method = "";
    }
    method = method.trim();

    if (method.isEmpty() || "ui".equalsIgnoreCase(method)) {
        response.setContentType("text/html; charset=UTF-8");
        if (!isWebQrAllowed(session)) {
%>
<!doctype html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied</title>
    <style>
        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: Arial, Helvetica, sans-serif;
            background: #f8fafc;
            color: #1f2937;
            padding: 20px;
        }
        .box {
            max-width: 420px;
            width: 100%;
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 16px 36px rgba(15, 23, 42, 0.12);
            padding: 24px;
            text-align: center;
        }
        h1 { margin: 0 0 8px; font-size: 22px; color: #b91c1c; }
        p { margin: 0; color: #6b7280; line-height: 1.5; }
    </style>
</head>
<body>
<div class="box">
    <h1>Access Denied</h1>
    <p>QR Attendance hanya bisa diakses oleh USERID ADMIN atau DIVISI OP.</p>
</div>
</body>
</html>
<%
            return;
        }
        String uiIssuer = "WEB";
        String uiRole = "WEB";
%>
<!doctype html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DMS ANP QR Attendance</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: Arial, Helvetica, sans-serif;
            background: linear-gradient(135deg, #eaf7ff 0%, #fff3e8 100%);
            color: #263238;
            padding: 18px;
        }
        .card {
            width: 100%;
            max-width: 430px;
            background: #ffffff;
            border-radius: 28px;
            box-shadow: 0 20px 45px rgba(28, 80, 110, 0.18);
            padding: 24px;
            text-align: center;
        }
        .brand {
            display: inline-flex;
            width: 76px;
            height: 76px;
            align-items: center;
            justify-content: center;
            border-radius: 24px;
            background: #eaf7ff;
            box-shadow:
                0 10px 0 rgba(61, 186, 242, 0.14),
                0 14px 24px rgba(0, 0, 0, 0.16);
            margin-top: -6px;
        }
        .brand-inner {
            width: 62px;
            height: 62px;
            border-radius: 20px;
            background: linear-gradient(135deg, #56c7f7, #1ea7e1);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: 800;
        }
        h1 {
            margin: 18px 0 4px;
            font-size: 23px;
        }
        .subtitle {
            margin: 0 0 18px;
            color: #6b7280;
            font-size: 13px;
        }
        .qr-wrap {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 286px;
            border-radius: 24px;
            background: #f7fbff;
            border: 1px solid #d8eefb;
            padding: 18px;
            overflow: hidden;
        }
        .qr-wrap.expired #qrcode {
            opacity: 0.22;
            filter: grayscale(1);
        }
        #qrcode {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 12px;
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 12px 28px rgba(0, 0, 0, 0.08);
            transition: opacity 180ms ease;
        }
        #qrcode img, #qrcode canvas {
            width: 240px !important;
            height: 240px !important;
        }
        .expired-badge {
            display: none;
            position: absolute;
            padding: 10px 18px;
            border-radius: 999px;
            background: #ef4444;
            color: #fff;
            font-weight: 800;
            letter-spacing: 0.5px;
            box-shadow: 0 12px 24px rgba(239, 68, 68, 0.28);
        }
        .qr-wrap.expired .expired-badge { display: block; }
        .status {
            margin: 16px auto 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 15px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 700;
            background: #dcfce7;
            color: #15803d;
        }
        .status.expired {
            background: #fee2e2;
            color: #b91c1c;
        }
        .actions {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        button {
            border: 0;
            border-radius: 14px;
            padding: 12px 14px;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
        }
        .primary {
            color: #fff;
            background: linear-gradient(135deg, #56c7f7, #1ea7e1);
            box-shadow: 0 10px 18px rgba(30, 167, 225, 0.25);
        }
        .secondary {
            color: #1f2937;
            background: #eef5f9;
        }
        .message {
            min-height: 20px;
            margin-top: 13px;
            color: #6b7280;
            font-size: 12px;
            word-break: break-word;
        }
        @media (max-width: 420px) { .actions { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<main class="card">
    <div class="brand"><div class="brand-inner">QR</div></div>
    <h1>QRIS Attendance</h1>
    <p class="subtitle">ADMIN/OP generate QR untuk driver Check IN / Check OUT</p>

    <section id="qrWrap" class="qr-wrap">
        <div id="qrcode"></div>
        <div class="expired-badge">EXPIRED</div>
    </section>

    <div id="status" class="status">Generate QR...</div>

    <div class="actions">
        <button class="primary" onclick="generateQr()">Refresh QR Code</button>
        <button class="secondary" onclick="copyQr()">Copy QR Data</button>
    </div>
    <div id="message" class="message"></div>
</main>

<script>
    let qrData = "";
    let expiresAt = null;
    let timer = null;
    const UI_ISSUER = "<%= html(uiIssuer) %>";
    const UI_ROLE = "<%= html(uiRole) %>";
    const TTL_SECONDS = "60";

    function setMessage(text) {
        document.getElementById("message").textContent = text || "";
    }

    function setStatus(text, expired) {
        const status = document.getElementById("status");
        const wrap = document.getElementById("qrWrap");
        status.textContent = text;
        status.classList.toggle("expired", !!expired);
        wrap.classList.toggle("expired", !!expired);
    }

    function renderQr(data) {
        const target = document.getElementById("qrcode");
        target.innerHTML = "";
        if (typeof QRCode === "undefined") {
            setMessage("QRCode JS gagal load. Pastikan browser bisa akses cdnjs.cloudflare.com.");
            return;
        }
        new QRCode(target, {
            text: data,
            width: 240,
            height: 240,
            colorDark: "#111827",
            colorLight: "#ffffff",
            correctLevel: QRCode.CorrectLevel.M
        });
    }

    function startCountdown() {
        if (timer) {
            clearInterval(timer);
        }
        const tick = () => {
            if (!expiresAt) {
                setStatus("QR belum tersedia", true);
                return;
            }
            const remaining = Math.max(0, Math.floor((expiresAt.getTime() - Date.now()) / 1000));
            if (remaining <= 0) {
                setStatus("Expired - refresh QR Code", true);
                clearInterval(timer);
                return;
            }
            setStatus("Expired dalam " + remaining + "s", false);
        };
        tick();
        timer = setInterval(tick, 1000);
    }

    async function generateQr() {
        try {
            setMessage("");
            setStatus("Generate QR...", false);
            const params = new URLSearchParams({
                method: "create",
                source: "web",
                issuer: UI_ISSUER,
                role: UI_ROLE,
                ttl_seconds: TTL_SECONDS
            });
            const response = await fetch(window.location.pathname + "?" + params.toString(), {
                headers: { "Accept": "application/json" }
            });
            const body = await response.json();
            if (body.status_code !== 200 || !body.qr_data || !body.payload) {
                throw new Error(body.message || "Gagal generate QR Code");
            }
            qrData = body.qr_data;
            expiresAt = new Date(body.payload.expires_at);
            renderQr(qrData);
            startCountdown();
            setMessage("QR aktif 60 detik.");
        } catch (err) {
            setStatus("Gagal generate QR", true);
            setMessage(err.message || String(err));
        }
    }

    async function copyQr() {
        if (!qrData) {
            setMessage("QR data belum tersedia.");
            return;
        }
        try {
            await navigator.clipboard.writeText(qrData);
            setMessage("QR data copied.");
        } catch (err) {
            setMessage(qrData);
        }
    }

    generateQr();
</script>
</body>
</html>
<%
        return;
    }

    try {
        if ("encrypt".equalsIgnoreCase(method) || "create".equalsIgnoreCase(method)) {
            response.setContentType("application/json; charset=UTF-8");
            String source = request.getParameter("source");
            if ("web".equalsIgnoreCase(source) && !isWebQrAllowed(session)) {
                root.addProperty("status", "error");
                root.addProperty("status_code", 403);
                root.addProperty("message", "Access denied");
                out.print(gson.toJson(root));
                return;
            }
            String issuer = request.getParameter("issuer");
            String role = request.getParameter("role");
            int ttlSeconds = 60;

            String qrData = createQrData(issuer, role, ttlSeconds);
            JsonObject payload = decodePayload(qrData);

            root.addProperty("status", "success");
            root.addProperty("status_code", 200);
            root.addProperty("message", "OK");
            root.addProperty("qr_data", qrData);
            root.add("payload", payload);
            out.print(gson.toJson(root));
            return;
        }

        if ("decrypt".equalsIgnoreCase(method) || "validate".equalsIgnoreCase(method)) {
            response.setContentType("application/json; charset=UTF-8");
            String qrData = request.getParameter("qr_data");
            JsonObject payload = decodePayload(qrData);
            boolean expired = isExpired(payload);

            root.addProperty("status", expired ? "expired" : "success");
            root.addProperty("status_code", expired ? 410 : 200);
            root.addProperty("message", expired ? "QR Code expired" : "OK");
            root.addProperty("valid", !expired);
            root.addProperty("expired", expired);
            root.add("payload", payload);
            out.print(gson.toJson(root));
            return;
        }

        response.setContentType("application/json; charset=UTF-8");
        root.addProperty("status", "error");
        root.addProperty("status_code", 400);
        root.addProperty("message", "Unsupported method");
        out.print(gson.toJson(root));
    } catch (Exception e) {
        response.setContentType("application/json; charset=UTF-8");
        root.addProperty("status", "error");
        root.addProperty("status_code", 500);
        root.addProperty("message", e.getMessage());
        out.print(gson.toJson(root));
    }
%>
