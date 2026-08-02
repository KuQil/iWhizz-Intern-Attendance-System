package controller;

import dao.AttendanceDAO;
import model.Attendance;
import model.User;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class ViewAllRecordsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null || !"supervisor".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        AttendanceDAO dao = new AttendanceDAO();
        List<Attendance> allRecordsList = dao.getAllSystemAttendance();

        request.setAttribute("allRecordsList", allRecordsList);
        request.getRequestDispatcher("viewAllRecords.jsp").forward(request, response);
    }
}
