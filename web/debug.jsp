<%-- 
    Document   : debug
    Created on : 10 Jun 2026, 10:35:38 pm
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
         <%
            String debug = (String) request.getAttribute("debug");

            if (debug != null) {
        %>

            <p class="error"><%= debug %>test</p>

        <% } %>
    </body>
</html>
