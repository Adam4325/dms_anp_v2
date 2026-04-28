<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"
%><%@ page import="java.util.*,java.util.Map,javax.servlet.http.*,com.google.gson.*,com.othree.DbHandler"
%><%
    /**
     * Deploy: {webapp}/trucking/mobile/api/po/po_receive_header.jsp
     * Jika compile error DbHandler: sesuaikan import ke package DbHandler proyek Anda.
     *
     * GET ?search= (opsional) filter ITXINVTRANNBR / PONBR / VENDOR / NOTANUMBER
     */
    request.setCharacterEncoding("UTF-8");
    Gson gson = new Gson();
    DbHandler db = null;
    try {
        String search = request.getParameter("search");
        if (search == null) {
            search = "";
        }
        search = search.trim().replace("'", "''");

        db = new DbHandler();
        db.connectDefault();
        db.setAutoCommit(false);

        String sql = "SELECT ITXINVTRANNBR, ITXINVTRANDATE, TOWAREHOUSE, NOTANUMBER, PONBR, VENDOR, CREATED_USER FROM V_PORECEIVE_HEADERDMS";
        if (!search.isEmpty()) {
            sql += " WHERE UPPER(COALESCE(ITXINVTRANNBR,'')) LIKE UPPER('%" + search + "%')"
                + " OR UPPER(COALESCE(PONBR,'')) LIKE UPPER('%" + search + "%')"
                + " OR UPPER(COALESCE(VENDOR,'')) LIKE UPPER('%" + search + "%')"
                + " OR UPPER(COALESCE(NOTANUMBER,'')) LIKE UPPER('%" + search + "%')";
        }

        Vector rows = db.getQueryResult(sql);
        db.commit();

        JsonArray data = vectorToJsonArray(rows);

        JsonObject root = new JsonObject();
        root.addProperty("status_code", 200);
        root.addProperty("message", "OK");
        root.add("data", data);
        out.print(gson.toJson(root));
    } catch (Exception ex) {
        ex.printStackTrace();
        try {
            if (db != null) {
                db.rollback();
            }
        } catch (Exception ignore) {
        }
        JsonObject err = new JsonObject();
        err.addProperty("status_code", 500);
        err.addProperty("message", ex.getMessage() == null ? "error" : ex.getMessage());
        err.add("data", new JsonArray());
        out.print(gson.toJson(err));
    } finally {
        try {
            if (db != null) {
                db.close();
            }
        } catch (Exception ignore) {
        }
    }
%>
<%!
    @SuppressWarnings("unchecked")
    JsonArray vectorToJsonArray(Vector rows) {
        JsonArray arr = new JsonArray();
        if (rows == null) {
            return arr;
        }
        for (Object r : rows) {
            if (r instanceof Map) {
                Map m = (Map) r;
                JsonObject o = new JsonObject();
                for (Object kObj : m.keySet()) {
                    String key = kObj == null ? "col" : String.valueOf(kObj);
                    Object val = m.get(kObj);
                    o.addProperty(key, val == null ? "" : String.valueOf(val));
                }
                arr.add(o);
            }
        }
        return arr;
    }
%>
