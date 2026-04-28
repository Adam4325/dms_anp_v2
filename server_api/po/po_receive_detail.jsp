<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"
%><%@ page import="java.util.*,java.util.Map,javax.servlet.http.*,com.google.gson.*,com.othree.DbHandler"
%><%
    /**
     * Deploy: {webapp}/trucking/mobile/api/po/po_receive_detail.jsp
     * Jika compile error DbHandler: sesuaikan import ke package DbHandler proyek Anda.
     *
     * GET ?itxinvtrannbr=... (wajib)
     */
    request.setCharacterEncoding("UTF-8");
    Gson gson = new Gson();
    DbHandler db = null;
    try {
        String trx = request.getParameter("itxinvtrannbr");
        if (trx == null || trx.trim().isEmpty()) {
            JsonObject err = new JsonObject();
            err.addProperty("status_code", 400);
            err.addProperty("message", "itxinvtrannbr required");
            err.add("data", new JsonArray());
            out.print(gson.toJson(err));
            return;
        }
        trx = trx.trim().replace("'", "''");

        db = new DbHandler();
        db.connectDefault();
        db.setAutoCommit(false);

        String sql = "SELECT ITXINVTRANNBR, ITXINVTRANDATE, ITDITEMID, PARTNAME, IDTYPE, IDACCESS, ITDQTY, UOMID, TOWAREHOUSE, NOTANUMBER, PONBR, CREATED_USER, TYPEPO, MERK, GENUINENO, PBNBR, ITDLINENBR, ITEMSIZE, VHTID "
                   + "FROM V_PORECEIVE_DETAILDMS WHERE ITXINVTRANNBR = '" + trx + "'";

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
