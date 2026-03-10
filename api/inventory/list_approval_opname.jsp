<%@page import="com.othree.common.db.DbHandler"%>
<%@ page import="java.util.Vector" %>
<%
    request.setCharacterEncoding("UTF-8");
    String _method = request.getParameter("method");
    String pageParam = request.getParameter("page");
    String limitParam = request.getParameter("limit");
    String search = request.getParameter("search");
    String idHeader = request.getParameter("id_header");
    String wonumber = request.getParameter("wonumber");
    if (search == null) search = "";
    int pages = 1;
    try { pages = Integer.parseInt(pageParam); } catch (Exception e) { }
    if (pages < 1) pages = 1;
    int limit = 10;
    try { limit = Integer.parseInt(limitParam); } catch (Exception e) { }
    if (limit < 1) limit = 10;
    if (limit > 100) limit = 100;
    int offset = (pages - 1) * limit;

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    if ("list-approval-opname-detail".equals(_method) && wonumber != null && !wonumber.trim().isEmpty()) {
        String queryDetail = ""
            + " SELECT OD.ID, OD.PARTNAME, OD.QTY, WO.WODNOTES "
            + " FROM tbl_opname_sr_detail OD "
            + " JOIN tbl_opname_sr_header OH ON OD.ID_HEADER = OH.ID "
            + " JOIN tblitemnew IT ON OD.ITEMID = IT.ITMITEMID "
            + " JOIN tblworkorder WO ON WO.WODWONBR = OH.WONUMBER AND WO.wodstatus LIKE 'ONGOING' "
            + " WHERE OD.IS_DELETED = 0 AND IT.PARENTITEMID = '1' AND OH.WONUMBER = '" + wonumber.trim().replace("'", "''") + "' "
            + " ORDER BY OD.ID ";
        Vector detailResult = new DbHandler().getQueryResult(queryDetail);
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        if (detailResult != null && detailResult.size() > 0) {
            for (int i = 0; i < detailResult.size(); i++) {
                Vector row = (Vector) detailResult.get(i);
                String id = row.get(0) != null ? row.get(0).toString() : "";
                String partname = row.get(1) != null ? row.get(1).toString().replace("\\", "\\\\").replace("\"", "\\\"") : "";
                String qty = row.get(2) != null ? row.get(2).toString() : "0";
                String wodnotes = row.get(3) != null ? row.get(3).toString().replace("\\", "\\\\").replace("\"", "\\\"") : "";
                if (i > 0) sb.append(",");
                sb.append("{\"_id\":\"").append(id).append("\",\"_partname\":\"").append(partname).append("\",\"_qty\":\"").append(qty).append("\",\"_wodnotes\":\"").append(wodnotes).append("\"}");
            }
        }
        sb.append("]");
        out.println(sb.toString());
        return;
    }

    if ("list-approval-opname".equals(_method)) {
        String baseWhere = ""
            + " FROM tbl_opname_sr_detail OD "
            + " JOIN tbl_opname_sr_header OH ON OD.ID_HEADER = OH.ID "
            + " JOIN tblitemnew IT ON OD.ITEMID = IT.ITMITEMID "
            + " JOIN tblworkorder WO ON WO.WODWONBR = OH.WONUMBER AND WO.wodstatus LIKE 'ONGOING' "
            + " WHERE OD.IS_DELETED = 0 AND IT.PARENTITEMID = '1' ";
        if (search != null && !search.trim().isEmpty()) {
            baseWhere += " AND (OH.WONUMBER LIKE '%" + search.trim().replace("'", "''") + "%' OR OD.PARTNAME LIKE '%" + search.trim().replace("'", "''") + "%' OR OH.VHCID LIKE '%" + search.trim().replace("'", "''") + "%') ";
        }

        String countQuery = " SELECT COUNT(*) FROM ( SELECT DISTINCT OH.WONUMBER " + baseWhere + " ) T ";
        Vector countResult = new DbHandler().getQueryResult(countQuery);
        int total = 0;
        if (countResult != null && countResult.size() > 0) {
            Vector countRow = (Vector) countResult.get(0);
            try { total = Integer.parseInt(countRow.get(0).toString()); } catch (Exception e) { }
        }

        String queryString = " SELECT DISTINCT OH.WONUMBER, OH.VHCID, WO.WODNOTES " + baseWhere
            + " ORDER BY OH.WONUMBER "
            + " LIMIT " + offset + " , " + limit;

        Vector queryResult = new DbHandler().getQueryResult(queryString);
        if (queryResult != null && queryResult.size() > 0) {
            StringBuilder sb = new StringBuilder();
            sb.append("[{\"total\":").append(total).append("},[");
            for (int i = 0; i < queryResult.size(); i++) {
                Vector row = (Vector) queryResult.get(i);
                String wonum = row.get(0) != null ? row.get(0).toString().replace("\\", "\\\\").replace("\"", "\\\"") : "";
                String vhcid = row.get(1) != null ? row.get(1).toString().replace("\\", "\\\\").replace("\"", "\\\"") : "";
                String wodnotesVal = row.get(2) != null ? row.get(2).toString().replace("\\", "\\\\").replace("\"", "\\\"") : "";

                if (i > 0) sb.append(",");
                sb.append("{")
                    .append("\"_trx_no\":\"").append(wonum).append("\",")
                    .append("\"_vhcid\":\"").append(vhcid).append("\",")
                    .append("\"_wodnotes\":\"").append(wodnotesVal).append("\"")
                    .append("}");
            }
            sb.append("]]");
            out.println(sb.toString());
        } else {
            out.println("[{\"total\":0},[]]");
        }
    } else {
        out.println("[{\"total\":0},[]]");
    }
%>
