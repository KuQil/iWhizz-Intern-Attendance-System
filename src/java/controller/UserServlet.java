/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDAO;
import model.User;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author ASUS
 */
public class UserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addUser(request, response);
        }
    }

    private void addUser(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        try {

            String username = request.getParameter("username");

            String password = request.getParameter("password");

            String fullName = request.getParameter("fullName");

            String startDate = request.getParameter("startDate");

            String endDate = request.getParameter("endDate");

            User user = new User();

            user.setUsername(username);
            user.setPassword(password);
            user.setFullName(fullName);
            user.setRole("intern");

            user.setInternshipStart(java.sql.Date.valueOf(startDate));

            user.setInternshipEnd(java.sql.Date.valueOf(endDate));

            UserDAO dao = new UserDAO();

            boolean success = dao.addUser(user);

            if (success) {
                response.sendRedirect("addUser.jsp?msg=added");
            } else {
                response.sendRedirect("addUser.jsp?error=fail");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    
    }

}
