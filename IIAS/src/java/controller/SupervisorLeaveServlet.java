package controller;

import dao.LeaveDAO;
import model.LeaveApplication;
import model.User;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

public class SupervisorLeaveServlet extends HttpServlet {

    private LeaveDAO leaveDAO;

    @Override
    public void init() {
        leaveDAO = new LeaveDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"supervisor".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("approve".equals(action)) {
            int leaveId = Integer.parseInt(request.getParameter("leaveId"));
            leaveDAO.approveLeave(leaveId);
            response.sendRedirect("SupervisorLeaveServlet?success=approved");
            return;
        } else if ("reject".equals(action)) {
            int leaveId = Integer.parseInt(request.getParameter("leaveId"));
            leaveDAO.rejectLeave(leaveId);
            response.sendRedirect("SupervisorLeaveServlet?success=rejected");
            return;
        }

        // Default action: Show all leave applications
        List<LeaveApplication> leaveList = leaveDAO.getAllLeavesForSupervisor();
        request.setAttribute("leaveList", leaveList);
        request.getRequestDispatcher("supervisorLeave.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}