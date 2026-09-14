package controller;

import dao.UserDAO;
import dao.AttendanceDAO;
import model.User;
import model.Attendance;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SupervisorInternManagementServlet")
public class SupervisorInternManagementServlet extends HttpServlet {

    private UserDAO userDAO;
    private AttendanceDAO attendanceDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
        attendanceDAO = new AttendanceDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verify supervisor session
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"supervisor".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("viewHistory".equals(action)) {
            viewAttendanceHistory(request, response);
        } else if ("delete".equals(action)) {
            deleteIntern(request, response);
        } else if ("archive".equals(action)) {
            archiveIntern(request, response);
        } else if ("update".equals(action)) {
            updateIntern(request, response);
        } else {
            // Default: Show all interns
            showAllInterns(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Display all active interns
     */
    private void showAllInterns(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> internsList = userDAO.getAllActiveInterns();
        request.setAttribute("internsList", internsList);
        request.setAttribute("activeMenu", "interns");
        request.getRequestDispatcher("supervisorInternManagement.jsp").forward(request, response);
    }

    /**
     * View attendance history for a specific intern
     */
    private void viewAttendanceHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            
            User intern = userDAO.getUserById(userId);
            List<Attendance> attendanceHistory = attendanceDAO.getAttendanceHistory(userId);

            request.setAttribute("intern", intern);
            request.setAttribute("attendanceHistory", attendanceHistory);
            request.setAttribute("activeMenu", "interns");
            request.getRequestDispatcher("supervisorInternHistory.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("SupervisorInternManagementServlet?error=invalid");
        }
    }

    /**
     * Archive an intern account (set account_status to 'archived')
     */
    private void archiveIntern(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            boolean success = userDAO.archiveUser(userId);

            if (success) {
                response.sendRedirect("SupervisorInternManagementServlet?success=archived");
            } else {
                response.sendRedirect("SupervisorInternManagementServlet?error=archive_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("SupervisorInternManagementServlet?error=invalid");
        }
    }

    /**
     * Delete an intern account (permanent deletion)
     */
    private void deleteIntern(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            boolean success = userDAO.deleteUser(userId);

            if (success) {
                response.sendRedirect("SupervisorInternManagementServlet?success=deleted");
            } else {
                response.sendRedirect("SupervisorInternManagementServlet?error=delete_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("SupervisorInternManagementServlet?error=invalid");
        }
    }

    /**
     * Update intern information
     */
    private void updateIntern(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String fullName = request.getParameter("fullName");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            int leaveRemaining = Integer.parseInt(request.getParameter("leaveRemaining"));

            // Create user object with updates
            User updatedUser = new User();
            updatedUser.setUserId(userId);
            updatedUser.setFullName(fullName);
            updatedUser.setUsername(username);
            
            // Only set password if provided
            if (password != null && !password.trim().isEmpty()) {
                updatedUser.setPassword(password);
            }
            
            updatedUser.setInternshipStart(Date.valueOf(startDateStr));
            updatedUser.setInternshipEnd(Date.valueOf(endDateStr));
            updatedUser.setPersonalLeaveRemaining(leaveRemaining);

            // Update user profile
            boolean success = userDAO.updateUserProfile(updatedUser);

            if (success) {
                response.sendRedirect("SupervisorInternManagementServlet?success=updated");
            } else {
                response.sendRedirect("supervisorInternEdit.jsp?userId=" + userId + "&error=update_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("SupervisorInternManagementServlet?error=invalid");
        }
    }
}
