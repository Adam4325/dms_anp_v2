<%@page import="com.google.gson.JsonArray"%>
<%@page import="com.google.gson.JsonObject"%>
<%@page import="com.google.gson.Gson"%>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"
%><%@ page language="java"
         import="java.util.*,
         java.sql.*,
         com.othree.common.db.DbHandler" %>
<%
    /**
     * Deploy: {webapp}/trucking/mobile/api/unit/eff_location.jsp
     * GET method=list-location&limit=10&offset=0&search=
     */
    request.setCharacterEncoding("UTF-8");
    Gson gson = new Gson();
    DbHandler db = null;
    String method = request.getParameter("method");
    if (method == null) {
        method = "list-location";
    }

    try {
        db = new DbHandler();
        db.connectDefault();

        if (!"list-location".equalsIgnoreCase(method)) {
            throw new Exception("Method tidak dikenal: " + method);
        }

        int limit = parseIntParam(request.getParameter("limit"), 10);
        int offset = parseIntParam(request.getParameter("offset"), 0);
        if (limit < 1) {
            limit = 10;
        }
        if (limit > 100) {
            limit = 100;
        }
        if (offset < 0) {
            offset = 0;
        }

        String search = esc(request.getParameter("search"));
        String whereClause = "STATUS='Active' AND LOCCOMPANY='AN'";
        if (!search.isEmpty()) {
            whereClause = whereClause + " AND UPPER(LOCID) LIKE UPPER('%" + search + "%')";
        }

        String sqlCount = "SELECT COUNT(*) AS CNT FROM TBLLOCATION WHERE " + whereClause;
        int total = queryCount(db, sqlCount);

        String cols = "LOCID AS title, LOCID AS value";
        String dataSql = "SELECT " + cols + " FROM TBLLOCATION WHERE " + whereClause + " ORDER BY LOCID ASC";
        JsonArray data = queryPagedRows(db, dataSql, limit, offset);

        JsonObject root = new JsonObject();
        root.addProperty("status", "success");
        root.addProperty("status_code", 200);
        root.addProperty("message", "OK");
        root.addProperty("total", total);
        root.addProperty("limit", limit);
        root.addProperty("offset", offset);
        root.add("data", data);
        out.print(gson.toJson(root));
    } catch (Exception ex) {
        ex.printStackTrace();
        JsonObject err = new JsonObject();
        err.addProperty("status", "error");
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
    String esc(String s) {
        return s == null ? "" : s.trim().replace("'", "''");
    }

    int parseIntParam(String s, int def) {
        if (s == null || s.trim().isEmpty()) {
            return def;
        }
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    int queryCount(DbHandler db, String sql) throws SQLException {
        ResultSet rs = null;
        try {
            rs = db.query(sql);
            if (rs.next()) {
                Object val = rs.getObject(1);
                if (val == null) {
                    return 0;
                }
                return Integer.parseInt(String.valueOf(val));
            }
            return 0;
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (Exception ignore) {
                }
            }
        }
    }

    JsonArray queryPagedRows(DbHandler db, String sql, int limit, int offset) throws SQLException {
        ResultSet rs = null;
        try {
            rs = db.query(sql);
            JsonArray arr = new JsonArray();
            ResultSetMetaData md = rs.getMetaData();
            int colCount = md.getColumnCount();
            int rowNum = 0;
            while (rs.next()) {
                rowNum++;
                if (rowNum <= offset) {
                    continue;
                }
                if (rowNum > offset + limit) {
                    break;
                }
                JsonObject o = new JsonObject();
                for (int col = 1; col <= colCount; col++) {
                    String key = md.getColumnLabel(col);
                    if (key == null || key.trim().isEmpty()) {
                        key = md.getColumnName(col);
                    }
                    Object val = rs.getObject(col);
                    o.addProperty(key, val == null ? "" : String.valueOf(val));
                }
                arr.add(o);
            }
            return arr;
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (Exception ignore) {
                }
            }
        }
    }
%>
