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


public class SupervisorDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Guard check: Verify session and role
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null || !"supervisor".equalsIgnoreCase(user.getRole())) { 
            // Ensures regular interns can't access this dashboard
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Fetch today's records
        AttendanceDAO dao = new AttendanceDAO();
        // Make sure you implement getTodayAttendance() in your DAO to fetch current date records
        List<Attendance> todayAttendanceList = dao.getTodayAttendance(); 

        // 3. Bind data to request scope
        request.setAttribute("todayAttendanceList", todayAttendanceList);

        // 4. Safely handoff rendering down to your updated clean JSP
        request.getRequestDispatcher("supervisorDashboard.jsp").forward(request, response);
    }
}