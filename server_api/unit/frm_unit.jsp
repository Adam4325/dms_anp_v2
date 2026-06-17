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
     * Deploy: {webapp}/trucking/mobile/api/unit/frm_unit.jsp
     *
     * GET method=list-row-unit&limit=10&offset=0&search=
     * GET method=update-unit&vhcid=&locid=&drvid=&userid=&status=
     */
    request.setCharacterEncoding("UTF-8");
    Gson gson = new Gson();
    DbHandler db = null;
    String method = request.getParameter("method");
    if (method == null) {
        method = "";
    }
    method = method.trim();

    try {
        db = new DbHandler();
        db.connectDefault();

        if ("list-row-unit".equalsIgnoreCase(method)) {
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
            String baseWhere = " FROM TBLVEHICLE WHERE CPYID='AN' AND VHCSTATUS='Active' ";
            String searchWhere = "";
            if (!search.isEmpty()) {
                searchWhere = " AND UPPER(VHCID) LIKE UPPER('%" + search + "%') ";
            }

            String sqlCount = "SELECT COUNT(*) AS CNT " + baseWhere + searchWhere;
            int total = queryCount(db, sqlCount);

            String whereClause = "CPYID='AN' AND VHCSTATUS='Active'" + searchWhere;
            String cols = "VHCID,VHCSTATUS,STATUS,LOCID,VHCKM,VHCNOTES,VHCDEFAULTDRIVER";
            String dataSql = "SELECT " + cols + " FROM TBLVEHICLE WHERE " + whereClause + " ORDER BY VHCID ASC";
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
            return;
        }

        if ("update-unit".equalsIgnoreCase(method)) {
            String vhcid = esc(request.getParameter("vhcid"));
            String locid = esc(request.getParameter("locid"));
            String drvid = esc(request.getParameter("drvid"));
            String userid = esc(request.getParameter("userid"));
            String status = esc(request.getParameter("status"));

            if (vhcid.isEmpty()) {
                throw new Exception("VHCID wajib diisi");
            }
            if (locid.isEmpty()) {
                throw new Exception("Default Location wajib diisi");
            }
            if (drvid.isEmpty()) {
                throw new Exception("Default Driver wajib diisi");
            }

            db.setAutoCommit(false);
            String sql = "UPDATE TBLVEHICLE SET LOCID='" + locid + "', VHCDEFAULTDRIVER='" + drvid + "'";
            if (!status.isEmpty()) {
                sql += ", STATUS='" + status + "'";
            }
            sql += " WHERE VHCID='" + vhcid + "' AND CPYID='AN' AND VHCSTATUS='Active'";
            int updated = db.exec(sql);
            if (updated <= 0) {
                throw new Exception("Gagal update unit " + vhcid);
            }
            db.commit();

            JsonObject root = new JsonObject();
            root.addProperty("status", "success");
            root.addProperty("status_code", 200);
            root.addProperty("message", "Data unit berhasil diupdate");
            root.addProperty("vhcid", vhcid);
            root.addProperty("locid", locid);
            root.addProperty("drvid", drvid);
            root.addProperty("userid", userid);
            root.addProperty("unit_status", status);
            out.print(gson.toJson(root));
            return;
        }

        throw new Exception("Method tidak dikenal: " + method);
    } catch (Exception ex) {
        ex.printStackTrace();
        try {
            if (db != null) {
                db.rollback();
            }
        } catch (Exception ignore) {
        }
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
