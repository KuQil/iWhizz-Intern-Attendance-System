/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.AttendanceDAO;
import model.Attendance;
import model.User;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AttendanceHistoryServlet")
public class AttendanceHistory
        extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session
                = request.getSession(false);

        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user
                = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        AttendanceDAO dao
                = new AttendanceDAO();

        List<Attendance> attendanceList
                = dao.getAttendanceHistory(
                        user.getUserId());

        request.setAttribute(
                "attendanceList",
                attendanceList);

        request.getRequestDispatcher(
                "viewRecord.jsp")
                .forward(request, response);
    }
}
