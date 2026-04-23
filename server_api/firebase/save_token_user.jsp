<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"
%><%@ page import="java.sql.*,com.othree.common.Common"
%><%
  request.setCharacterEncoding("UTF-8");
  String method = nvl(request.getParameter("method"));
  if (!"save-token-user-v1".equals(method)) {
    out.print(jsonErr(100, "unknown method"));
    return;
  }

  String username = nvl(request.getParameter("username")).trim();
  String loginname = nvl(request.getParameter("loginname")).trim();
  String token = nvl(request.getParameter("token")).trim();
  String platform = nvl(request.getParameter("platform")).trim();
  if (username.isEmpty() || token.isEmpty()) {
    out.print(jsonErr(100, "username and token required"));
    return;
  }
  if (platform.isEmpty()) {
    platform = "android";
  }

  Connection con = null;
  try {
    Class.forName(Common.getProp("db.driver"));
    con = DriverManager.getConnection(
        Common.getProp("db.url"),
        Common.getProp("db.user"),
        Common.getProp("db.pwd"));
    con.setAutoCommit(true);

    String deactivateSql =
        "UPDATE DMS_USER_FCM_TOKEN SET IS_ACTIVE='0', UPDATED_AT=CURRENT_TIMESTAMP " +
        "WHERE UPPER(USERNAME)=UPPER(?) AND TOKEN<>?";
    try (PreparedStatement ps = con.prepareStatement(deactivateSql)) {
      ps.setString(1, username);
      ps.setString(2, token);
      ps.executeUpdate();
    }

    String updateSql =
        "UPDATE DMS_USER_FCM_TOKEN SET LOGINNAME=?, PLATFORM=?, IS_ACTIVE='1', UPDATED_AT=CURRENT_TIMESTAMP " +
        "WHERE UPPER(USERNAME)=UPPER(?) AND TOKEN=?";
    int updated;
    try (PreparedStatement ps = con.prepareStatement(updateSql)) {
      ps.setString(1, loginname);
      ps.setString(2, platform);
      ps.setString(3, username);
      ps.setString(4, token);
      updated = ps.executeUpdate();
    }

    if (updated == 0) {
      String insertSql =
          "INSERT INTO DMS_USER_FCM_TOKEN (USERNAME, LOGINNAME, TOKEN, PLATFORM, IS_ACTIVE, UPDATED_AT) " +
          "VALUES (?, ?, ?, ?, '1', CURRENT_TIMESTAMP)";
      try (PreparedStatement ps = con.prepareStatement(insertSql)) {
        ps.setString(1, username);
        ps.setString(2, loginname);
        ps.setString(3, token);
        ps.setString(4, platform);
        ps.executeUpdate();
      }
    }
    out.print(jsonOk("[{\"saved\":1}]"));
  } catch (Exception ex) {
    ex.printStackTrace();
    out.print(jsonErr(500, ex.toString()));
  } finally {
    if (con != null) {
      try { con.close(); } catch (SQLException e) {}
    }
  }
%>
<%!
  String nvl(String s) { return s == null ? "" : s; }
  String esc(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\").replace("\"", "\\\"");
  }
  String jsonErr(int code, String msg) {
    return "{\"status_code\":" + code + ",\"message\":\"" + esc(msg) + "\",\"data\":[]}";
  }
  String jsonOk(String dataJson) {
    return "{\"status_code\":200,\"message\":\"OK\",\"data\":" + dataJson + "}";
  }
%>

