<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="com.othree.common.db.DbHandler"%>
<%@page import="com.google.gson.Gson"%>
<%
    request.setCharacterEncoding("UTF-8");
    Map<String, Object> json = new HashMap<String, Object>();

    try {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String method = request.getParameter("method");
        String id = request.getParameter("id");
        String itemid = request.getParameter("itemid");
        String apvUser = request.getParameter("apv_user");
        if (apvUser == null) apvUser = request.getParameter("username");

        if (method != null && "approve-opname-detail".equals(method) && id != null && !id.trim().isEmpty()) {
            String apvUserSafe = (apvUser != null && !apvUser.isEmpty()) ? apvUser.trim().replace("'", "''") : "";
            String idSafe = id.trim().replace("'", "''");

            StringBuilder updateQuery = new StringBuilder();
            updateQuery.append("UPDATE tbl_opname_sr_detail SET APV_USER='").append(apvUserSafe).append("', APV_DATETIME=NOW() WHERE ID='").append(idSafe).append("'");
            if (itemid != null && !itemid.trim().isEmpty()) {
                updateQuery.append(" AND ITEMID='").append(itemid.trim().replace("'", "''")).append("'");
            }

            DbHandler db = new DbHandler();
            db.connectDefault();
            int affected = db.exec(updateQuery.toString());

            if (affected > 0) {
                json.put("status", "success");
                json.put("message", "Approved success");
            } else {
                json.put("status", "failed");
                json.put("message", "Approved failed");
            }
        } else {
            json.put("status", "failed");
            json.put("message", "Invalid method or id");
        }
    } catch (Exception e) {
        json.put("status", "error");
        json.put("message", e.toString());
    }

    Gson gson = new Gson();
    out.print(gson.toJson(json));
%>
