package controller;

import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class EditProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentSessionUser = (User) session.getAttribute("user");

        // Security Check
        if (currentSessionUser == null || !"intern".equals(currentSessionUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Get Form Parameters
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        // Create a temporary User object for DB update
        User tempUser = new User();
        tempUser.setUserId(currentSessionUser.getUserId());
        tempUser.setUsername(username);
        tempUser.setPassword(password);
        tempUser.setFullName(fullName);

        // Safety check for date parsing
        if (startDate != null && !startDate.trim().isEmpty()) {
            tempUser.setInternshipStart(java.sql.Date.valueOf(startDate));
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            tempUser.setInternshipEnd(java.sql.Date.valueOf(endDate));
        }

        UserDAO dao = new UserDAO();
        boolean success = dao.updateUserProfile(tempUser);

        if (success) {
            // ONLY update session object after DB update succeeds
            currentSessionUser.setUsername(username);
            currentSessionUser.setFullName(fullName);
            currentSessionUser.setInternshipStart(tempUser.getInternshipStart());
            currentSessionUser.setInternshipEnd(tempUser.getInternshipEnd());

            if (password != null && !password.trim().isEmpty()) {
                currentSessionUser.setPassword(password);
            }

            session.setAttribute("user", currentSessionUser);

            response.sendRedirect("dashboard.jsp?success=profile_updated");
        } else {
            // Session user remains untouched on failure!
            response.sendRedirect("editAcc.jsp?error=update_failed");
        }
    }
}
