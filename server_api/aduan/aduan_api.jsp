<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"
%><%@ page import="java.sql.*,javax.servlet.http.*,javax.servlet.jsp.*,com.othree.common.Common,java.net.*,java.io.*,java.util.regex.*,java.util.Base64,java.nio.charset.StandardCharsets,java.nio.file.Files,java.nio.file.Paths,java.security.*,java.security.spec.*"
%><%
  /**
   * Salin ke: {webapp}/trucking/mobile/api/aduan/aduan_api.jsp
   * Tabel: dms_aduan_maxdb.sql — isi DMS_ADUAN_STAFF_NOTIFY (user staf) agar notifikasi & handler berjalan.
   *
   * method: aduan-create | aduan-list-open | aduan-list-mine | aduan-close |
   *         aduan-notif-list | aduan-notif-read | aduan-notif-count
   */
  request.setCharacterEncoding("UTF-8");
  String method = nvl(request.getParameter("method"));
  Connection con = null;
  try {
    Class.forName(Common.getProp("db.driver"));
    con = DriverManager.getConnection(
        Common.getProp("db.url"),
        Common.getProp("db.user"),
        Common.getProp("db.pwd"));
    con.setAutoCommit(true);

    if ("aduan-create".equals(method)) {
      doCreate(request, con, out);
    } else if ("aduan-list-open".equals(method)) {
      doListOpen(request, con, out);
    } else if ("aduan-list-mine".equals(method)) {
      doListMine(request, con, out);
    } else if ("aduan-close".equals(method)) {
      doClose(request, con, out);
    } else if ("aduan-notif-list".equals(method)) {
      doNotifList(request, con, out);
    } else if ("aduan-notif-read".equals(method)) {
      doNotifRead(request, con, out);
    } else if ("aduan-notif-count".equals(method)) {
      doNotifCount(request, con, out);
    } else {
      out.print(jsonErr(100, "unknown method"));
    }
  } catch (Exception ex) {
    ex.printStackTrace();
    out.print(jsonErr(500, esc(ex.toString())));
  } finally {
    if (con != null) {
      try { con.close(); } catch (SQLException e) { }
    }
  }
%>
<%!
  String nvl(String s) { return s == null ? "" : s; }

  String jsonErr(int code, String msg) {
    return "{\"status_code\":" + code + ",\"message\":\"" + esc(msg) + "\",\"data\":[]}";
  }

  String jsonOk(String dataJson) {
    return "{\"status_code\":200,\"message\":\"OK\",\"data\":" + dataJson + "}";
  }

  String esc(String s) {
    if (s == null) {
      return "";
    }
    return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", " ").replace("\n", " ");
  }

  boolean isHandler(Connection con, String username) throws SQLException {
    if (username == null || username.trim().isEmpty()) {
      return false;
    }
    if ("ADMIN".equalsIgnoreCase(username.trim())) {
      return true;
    }
    String sql = "SELECT 1 FROM DMS_ADUAN_STAFF_NOTIFY WHERE UPPER(USERNAME) = UPPER(?)";
    try (PreparedStatement ps = con.prepareStatement(sql)) {
      ps.setString(1, username.trim());
      try (ResultSet rs = ps.executeQuery()) {
        return rs.next();
      }
    }
  }

  int resolveAduanIdAfterInsert(Connection con) throws SQLException {
    try (Statement st = con.createStatement();
         ResultSet rs = st.executeQuery("SELECT MAX(ID) AS M FROM DMS_ADUAN")) {
      if (rs.next()) {
        return rs.getInt(1);
      }
    }
    return 0;
  }

  void doCreate(HttpServletRequest request, Connection con, JspWriter out) throws Exception {
    String statusK = nvl(request.getParameter("status_karyawan")).trim();
    String u = nvl(request.getParameter("username")).trim();
    String drvid = nvl(request.getParameter("drvid")).trim();
    String kryid = nvl(request.getParameter("kryid")).trim();
    String loginname = nvl(request.getParameter("loginname")).trim();
    String pesan = nvl(request.getParameter("pesan"));
    if (u.isEmpty() || pesan.isEmpty()) {
      out.print(jsonErr(100, "username and pesan required"));
      return;
    }
    String su = statusK.toUpperCase();
    if (!"DRIVER".equals(su) && !"KARYAWAN".equals(su)) {
      out.print(jsonErr(100, "only DRIVER or KARYAWAN can create"));
      return;
    }
    String sDrv = null;
    String sKry = null;
    if ("DRIVER".equals(su)) {
      if (drvid.isEmpty()) {
        out.print(jsonErr(100, "drvid required for DRIVER"));
        return;
      }
      sDrv = drvid;
    } else {
      if (kryid.isEmpty()) {
        out.print(jsonErr(100, "kryid required for KARYAWAN"));
        return;
      }
      sKry = kryid;
    }
    String ins = "INSERT INTO DMS_ADUAN (SUBMITTER_DRVID, SUBMITTER_KRYID, SUBMITTER_USERNAME, SUBMITTER_LOGINNAME, PESAN, STATUS, CREATED_AT) VALUES (?, ?, ?, ?, ?, 'OPEN', CURRENT_TIMESTAMP)";
    try (PreparedStatement ps = con.prepareStatement(ins)) {
      ps.setString(1, sDrv);
      ps.setString(2, sKry);
      ps.setString(3, u);
      ps.setString(4, loginname);
      ps.setString(5, pesan);
      ps.executeUpdate();
    }
    int aduanId = resolveAduanIdAfterInsert(con);
    if (aduanId > 0) {
      String inNotif = "INSERT INTO DMS_ADUAN_NOTIF (ADUAN_ID, TARGET_USERNAME, IS_READ, CREATED_AT) " +
          "SELECT ?, UPPER(USERNAME), '0', CURRENT_TIMESTAMP FROM DMS_ADUAN_STAFF_NOTIFY";
      try (PreparedStatement p2 = con.prepareStatement(inNotif)) {
        p2.setInt(1, aduanId);
        p2.executeUpdate();
      } catch (SQLException ex) {
        ex.printStackTrace();
      }
      // Push FCM ke handler (HR/HD/ADMIN) berbasis token aktif.
      sendFcmAduanToHandlers(con, aduanId, u, pesan);
    }
    out.print(jsonOk("[{\"id\":" + aduanId + "}]"));
  }

  void doListOpen(HttpServletRequest request, Connection con, JspWriter out) throws Exception {
    String u = nvl(request.getParameter("username")).trim();
    if (!isHandler(con, u)) {
      out.print(jsonErr(403, "forbidden"));
      return;
    }
    String q = "SELECT ID, SUBMITTER_DRVID, SUBMITTER_KRYID, SUBMITTER_USERNAME, SUBMITTER_LOGINNAME, " +
        "STATUS, PESAN, CREATED_AT, CLOSED_AT, CLOSED_BY_USERNAME " +
        "FROM DMS_ADUAN WHERE UPPER(STATUS) = 'OPEN' ORDER BY CREATED_AT DESC";
    try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(q)) {
      StringBuilder arr = new StringBuilder("[");
      boolean first = true;
      while (rs.next()) {
        if (!first) {
          arr.append(",");
        }
        first = false;
        arr.append("{\"id\":").append(rs.getInt(1));
        arr.append(",\"submitter_drvid\":\"").append(esc(nvl(rs.getString(2)))).append("\"");
        arr.append(",\"submitter_kryid\":\"").append(esc(nvl(rs.getString(3)))).append("\"");
        arr.append(",\"submitter_username\":\"").append(esc(nvl(rs.getString(4)))).append("\"");
        arr.append(",\"submitter_loginname\":\"").append(esc(nvl(rs.getString(5)))).append("\"");
        arr.append(",\"status\":\"").append(esc(nvl(rs.getString(6)))).append("\"");
        arr.append(",\"pesan\":\"").append(esc(nvl(rs.getString(7)))).append("\"");
        if (rs.getTimestamp(8) != null) {
          arr.append(",\"created_at\":\"").append(esc(String.valueOf(rs.getTimestamp(8)))).append("\"");
        } else {
          arr.append(",\"created_at\":\"\"");
        }
        if (rs.getTimestamp(9) != null) {
          arr.append(",\"closed_at\":\"").append(esc(String.valueOf(rs.getTimestamp(9)))).append("\"");
        } else {
          arr.append(",\"closed_at\":\"\"");
        }
        arr.append(",\"closed_by_username\":\"").append(esc(nvl(rs.getString(10)))).append("\"");
        arr.append("}");
      }
      arr.append("]");
      out.print(jsonOk(arr.toString()));
    }
  }

  void doListMine(HttpServletRequest request, Connection con, JspWriter out) throws Exception {
    String u = nvl(request.getParameter("username")).trim();
    String sk = nvl(request.getParameter("status_karyawan")).trim();
    String drvid = nvl(request.getParameter("drvid")).trim();
    String kryid = nvl(request.getParameter("kryid")).trim();
    if (u.isEmpty()) {
      out.print(jsonErr(100, "username required"));
      return;
    }
    String su = sk.toUpperCase();
    if (!"DRIVER".equals(su) && !"KARYAWAN".equals(su)) {
      out.print(jsonErr(100, "only DRIVER or KARYAWAN"));
      return;
    }
    String q;
    if ("DRIVER".equals(su)) {
      if (drvid.isEmpty()) {
        out.print(jsonErr(100, "drvid required"));
        return;
      }
      q = "SELECT ID, SUBMITTER_DRVID, SUBMITTER_KRYID, SUBMITTER_USERNAME, SUBMITTER_LOGINNAME, " +
          "STATUS, PESAN, CREATED_AT, CLOSED_AT, CLOSED_BY_USERNAME " +
          "FROM DMS_ADUAN WHERE UPPER(SUBMITTER_USERNAME) = UPPER(?) AND (SUBMITTER_DRVID = ?) " +
          "AND UPPER(STATUS) = 'OPEN' ORDER BY CREATED_AT DESC";
    } else {
      if (kryid.isEmpty()) {
        out.print(jsonErr(100, "kryid required"));
        return;
      }
      q = "SELECT ID, SUBMITTER_DRVID, SUBMITTER_KRYID, SUBMITTER_USERNAME, SUBMITTER_LOGINNAME, " +
          "STATUS, PESAN, CREATED_AT, CLOSED_AT, CLOSED_BY_USERNAME " +
          "FROM DMS_ADUAN WHERE UPPER(SUBMITTER_USERNAME) = UPPER(?) AND (SUBMITTER_KRYID = ?) " +
          "AND UPPER(STATUS) = 'OPEN' ORDER BY CREATED_AT DESC";
    }
    try (PreparedStatement ps = con.prepareStatement(q)) {
      ps.setString(1, u);
      if ("DRIVER".equals(su)) {
        ps.setString(2, drvid);
      } else {
        ps.setString(2, kryid);
      }
      try (ResultSet rs = ps.executeQuery()) {
        StringBuilder arr = new StringBuilder("[");
        boolean first = true;
        while (rs.next()) {
          if (!first) {
            arr.append(",");
          }
          first = false;
          arr.append("{\"id\":").append(rs.getInt(1));
          arr.append(",\"submitter_drvid\":\"").append(esc(nvl(rs.getString(2)))).append("\"");
          arr.append(",\"submitter_kryid\":\"").append(esc(nvl(rs.getString(3)))).append("\"");
          arr.append(",\"submitter_username\":\"").append(esc(nvl(rs.getString(4)))).append("\"");
          arr.append(",\"submitter_loginname\":\"").append(esc(nvl(rs.getString(5)))).append("\"");
          arr.append(",\"status\":\"").append(esc(nvl(rs.getString(6)))).append("\"");
          arr.append(",\"pesan\":\"").append(esc(nvl(rs.getString(7)))).append("\"");
          if (rs.getTimestamp(8) != null) {
            arr.append(",\"created_at\":\"").append(esc(String.valueOf(rs.getTimestamp(8)))).append("\"");
          } else {
            arr.append(",\"created_at\":\"\"");
          }
          if (rs.getTimestamp(9) != null) {
            arr.append(",\"closed_at\":\"").append(esc(String.valueOf(rs.getTimestamp(9)))).append("\"");
          } else {
            arr.append(",\"closed_at\":\"\"");
          }
          arr.append(",\"closed_by_username\":\"").append(esc(nvl(rs.getString(10)))).append("\"");
          arr.append("}");
        }
        arr.append("]");
        out.print(jsonOk(arr.toString()));
      }
    }
  }

  void doClose(HttpServletRequest request, Connection con, JspWriter out) throws Exception {
    String u = nvl(request.getParameter("username")).trim();
    if (!isHandler(con, u)) {
      out.print(jsonErr(403, "forbidden"));
      return;
    }
    String idStr = nvl(request.getParameter("id"));
    if (idStr.isEmpty()) {
      out.print(jsonErr(100, "id required"));
      return;
    }
    int id = Integer.parseInt(idStr);
    String up = "UPDATE DMS_ADUAN SET STATUS = 'CLOSE', CLOSED_AT = CURRENT_TIMESTAMP, CLOSED_BY_USERNAME = ? WHERE ID = ? AND UPPER(STATUS) = 'OPEN'";
    int n;
    try (PreparedStatement ps = con.prepareStatement(up)) {
      ps.setString(1, u);
      ps.setInt(2, id);
      n = ps.executeUpdate();
    }
    if (n == 0) {
      out.print(jsonErr(100, "not found or already closed"));
      return;
    }
    try (PreparedStatement p2 = con.prepareStatement("DELETE FROM DMS_ADUAN_NOTIF WHERE ADUAN_ID = ?")) {
      p2.setInt(1, id);
      p2.executeUpdate();
    } catch (SQLException ex) { }
    out.print(jsonOk("[{\"updated\":" + n + "}]"));
  }

  void doNotifList(HttpServletRequest request, Connection con, JspWriter out) throws Exception {
    String u = nvl(request.getParameter("username")).trim();
    if (!isHandler(con, u)) {
      out.print(jsonErr(403, "forbidden"));
      return;
    }
    String q = "SELECT n.ID, n.ADUAN_ID, a.PESAN, a.SUBMITTER_USERNAME, a.CREATED_AT, n.IS_READ, n.CREATED_AT " +
        "FROM DMS_ADUAN_NOTIF n JOIN DMS_ADUAN a ON a.ID = n.ADUAN_ID " +
        "WHERE UPPER(n.TARGET_USERNAME) = UPPER(?) AND UPPER(a.STATUS) = 'OPEN' " +
        "ORDER BY n.CREATED_AT DESC";
    try (PreparedStatement ps = con.prepareStatement(q)) {
      ps.setString(1, u);
      try (ResultSet rs = ps.executeQuery()) {
        StringBuilder arr = new StringBuilder("[");
        boolean first = true;
        while (rs.next()) {
          if (!first) {
            arr.append(",");
          }
          first = false;
          arr.append("{\"id\":").append(rs.getInt(1));
          arr.append(",\"aduan_id\":").append(rs.getInt(2));
          arr.append(",\"pesan\":\"").append(esc(nvl(rs.getString(3)))).append("\"");
          arr.append(",\"submitter_username\":\"").append(esc(nvl(rs.getString(4)))).append("\"");
          if (rs.getTimestamp(5) != null) {
            arr.append(",\"aduan_created_at\":\"").append(esc(String.valueOf(rs.getTimestamp(5)))).append("\"");
          } else {
            arr.append(",\"aduan_created_at\":\"\"");
          }
          arr.append(",\"is_read\":\"").append(esc(nvl(rs.getString(6)))).append("\"");
          if (rs.getTimestamp(7) != null) {
            arr.append(",\"notif_created_at\":\"").append(esc(String.valueOf(rs.getTimestamp(7)))).append("\"");
          } else {
            arr.append(",\"notif_created_at\":\"\"");
          }
          arr.append("}");
        }
        arr.append("]");
        out.print(jsonOk(arr.toString()));
      }
    }
  }

  void doNotifRead(HttpServletRequest request, Connection con, JspWriter out) throws Exception {
    String u = nvl(request.getParameter("username")).trim();
    if (!isHandler(con, u)) {
      out.print(jsonErr(403, "forbidden"));
      return;
    }
    String nid = nvl(request.getParameter("notif_id"));
    if (nid.isEmpty()) {
      out.print(jsonErr(100, "notif_id required"));
      return;
    }
    String up = "UPDATE DMS_ADUAN_NOTIF SET IS_READ = '1' WHERE ID = ? AND UPPER(TARGET_USERNAME) = UPPER(?)";
    int n;
    try (PreparedStatement ps = con.prepareStatement(up)) {
      ps.setInt(1, Integer.parseInt(nid));
      ps.setString(2, u);
      n = ps.executeUpdate();
    }
    out.print(jsonOk("[{\"updated\":" + n + "}]"));
  }

  void doNotifCount(HttpServletRequest request, Connection con, JspWriter out) throws Exception {
    String u = nvl(request.getParameter("username")).trim();
    if (!isHandler(con, u)) {
      out.print(jsonErr(403, "forbidden"));
      return;
    }
    String q = "SELECT COUNT(1) FROM DMS_ADUAN_NOTIF WHERE UPPER(TARGET_USERNAME) = UPPER(?) AND (IS_READ IS NULL OR IS_READ = '0')";
    int c = 0;
    try (PreparedStatement ps = con.prepareStatement(q)) {
      ps.setString(1, u);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          c = rs.getInt(1);
        }
      }
    }
    out.print(jsonOk("[{\"unread\":" + c + "}]"));
  }

  String parseJsonField(String json, String key) {
    Pattern p = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*\"(.*?)\"", Pattern.DOTALL);
    Matcher m = p.matcher(json);
    if (!m.find()) {
      return "";
    }
    String v = m.group(1);
    return v.replace("\\n", "\n").replace("\\\"", "\"").replace("\\\\", "\\");
  }

  String base64Url(byte[] data) {
    return Base64.getUrlEncoder().withoutPadding().encodeToString(data);
  }

  String buildServiceAccountJwt(String clientEmail, String privateKeyPem, String tokenUri) throws Exception {
    long now = System.currentTimeMillis() / 1000L;
    long exp = now + 3600L;
    String headerJson = "{\"alg\":\"RS256\",\"typ\":\"JWT\"}";
    String claimJson = "{"
        + "\"iss\":\"" + esc(clientEmail) + "\","
        + "\"scope\":\"https://www.googleapis.com/auth/firebase.messaging\","
        + "\"aud\":\"" + esc(tokenUri) + "\","
        + "\"iat\":" + now + ","
        + "\"exp\":" + exp
        + "}";
    String header = base64Url(headerJson.getBytes(StandardCharsets.UTF_8));
    String payload = base64Url(claimJson.getBytes(StandardCharsets.UTF_8));
    String signingInput = header + "." + payload;

    String cleanPem = privateKeyPem
        .replace("-----BEGIN PRIVATE KEY-----", "")
        .replace("-----END PRIVATE KEY-----", "")
        .replaceAll("\\s", "");
    byte[] keyBytes = Base64.getDecoder().decode(cleanPem);
    PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
    KeyFactory kf = KeyFactory.getInstance("RSA");
    PrivateKey pk = kf.generatePrivate(spec);
    Signature sig = Signature.getInstance("SHA256withRSA");
    sig.initSign(pk);
    sig.update(signingInput.getBytes(StandardCharsets.UTF_8));
    String signature = base64Url(sig.sign());
    return signingInput + "." + signature;
  }

  String getAccessTokenFromServiceAccount() {
    HttpURLConnection conn = null;
    try {
      String saPath = nvl(Common.getProp("fcm.sa.path")).trim();
      if (saPath.isEmpty()) {
        return "";
      }
      String json = new String(Files.readAllBytes(Paths.get(saPath)), StandardCharsets.UTF_8);
      String clientEmail = parseJsonField(json, "client_email");
      String privateKey = parseJsonField(json, "private_key");
      String tokenUri = parseJsonField(json, "token_uri");
      if (clientEmail.isEmpty() || privateKey.isEmpty() || tokenUri.isEmpty()) {
        return "";
      }

      String jwt = buildServiceAccountJwt(clientEmail, privateKey, tokenUri);
      String form = "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=" +
          URLEncoder.encode(jwt, "UTF-8");

      URL url = new URL(tokenUri);
      conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("POST");
      conn.setDoOutput(true);
      conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
      try (OutputStream os = conn.getOutputStream()) {
        os.write(form.getBytes(StandardCharsets.UTF_8));
      }

      InputStream is = conn.getResponseCode() >= 400 ? conn.getErrorStream() : conn.getInputStream();
      if (is == null) {
        return "";
      }
      StringBuilder sb = new StringBuilder();
      try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
        String line;
        while ((line = br.readLine()) != null) {
          sb.append(line);
        }
      }
      String body = sb.toString();
      Matcher m = Pattern.compile("\"access_token\"\\s*:\\s*\"([^\"]+)\"").matcher(body);
      if (m.find()) {
        return m.group(1);
      }
      return "";
    } catch (Exception ex) {
      ex.printStackTrace();
      return "";
    } finally {
      if (conn != null) {
        conn.disconnect();
      }
    }
  }

  void sendFcmAduanToHandlers(Connection con, int aduanId, String submitterUsername, String pesan) {
    String accessToken = getAccessTokenFromServiceAccount();
    if (accessToken.isEmpty()) {
      return;
    }
    String projectId = nvl(Common.getProp("fcm.project.id")).trim();
    if (projectId.isEmpty()) {
      projectId = "notif-driver";
    }
    String sql =
        "SELECT DISTINCT t.TOKEN " +
        "FROM DMS_USER_FCM_TOKEN t " +
        "WHERE t.IS_ACTIVE='1' AND (" +
        "UPPER(t.USERNAME) IN (SELECT UPPER(USERNAME) FROM DMS_ADUAN_STAFF_NOTIFY) " +
        "OR UPPER(t.LOGINNAME)='ADMIN')";
    try (Statement st = con.createStatement();
         ResultSet rs = st.executeQuery(sql)) {
      while (rs.next()) {
        String token = nvl(rs.getString(1)).trim();
        if (!token.isEmpty()) {
          pushFcmV1(accessToken, projectId, token, aduanId, submitterUsername, pesan);
        }
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }

  void pushFcmV1(String accessToken, String projectId, String token, int aduanId, String submitterUsername, String pesan) {
    HttpURLConnection conn = null;
    try {
      URL url = new URL("https://fcm.googleapis.com/v1/projects/" + URLEncoder.encode(projectId, "UTF-8") + "/messages:send");
      conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("POST");
      conn.setDoOutput(true);
      conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
      conn.setRequestProperty("Authorization", "Bearer " + accessToken);

      String safeBody = esc(pesan);
      if (safeBody.length() > 120) {
        safeBody = safeBody.substring(0, 120) + "...";
      }

      String payload = "{"
          + "\"message\":{"
            + "\"token\":\"" + esc(token) + "\","
            + "\"notification\":{"
              + "\"title\":\"Aduan Baru\","
              + "\"body\":\"" + esc(submitterUsername) + ": " + safeBody + "\""
            + "},"
            + "\"data\":{"
              + "\"type\":\"aduan\","
              + "\"screen\":\"aduan\","
              + "\"aduan_id\":\"" + aduanId + "\""
            + "},"
            + "\"android\":{"
              + "\"priority\":\"HIGH\""
            + "}"
          + "}"
      + "}";

      try (OutputStream os = conn.getOutputStream()) {
        os.write(payload.getBytes(StandardCharsets.UTF_8));
      }

      int code = conn.getResponseCode();
      if (code >= 400) {
        InputStream es = conn.getErrorStream();
        if (es != null) {
          try (BufferedReader br = new BufferedReader(new InputStreamReader(es, StandardCharsets.UTF_8))) {
            while (br.readLine() != null) { }
          }
        }
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    } finally {
      if (conn != null) {
        conn.disconnect();
      }
    }
  }
%>
