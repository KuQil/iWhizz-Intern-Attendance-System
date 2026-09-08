package controller;

import dao.LeaveDAO;
import model.LeaveApplication;
import model.User;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10
)
public class LeaveServlet extends HttpServlet {

    private LeaveDAO leaveDAO;
    private Cloudinary cloudinary;

    @Override
    public void init() {
        leaveDAO = new LeaveDAO();
        // Reads API credentials set in Render Environment Variables
        cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", System.getenv("CLOUDINARY_CLOUD_NAME"),
                "api_key", System.getenv("CLOUDINARY_API_KEY"),
                "api_secret", System.getenv("CLOUDINARY_API_SECRET")
        ));
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "history";
        }

        switch (action) {

            case "history":
                showHistory(request, response);
                break;

            case "approve":
                approveLeave(request, response);
                break;

            case "reject":
                rejectLeave(request, response);
                break;

            default:
                response.sendRedirect("login.jsp");

        }

    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("apply".equals(action)) {

            applyLeave(request, response);

        } else {

            doGet(request, response);

        }

    }

    /*
     * ==========================================
     * APPLY LEAVE
     * ==========================================
     */
    private void applyLeave(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException, ServletException {

        HttpSession session = request.getSession(false);

        User user = (User) session.getAttribute("user");

        if (user == null) {

            response.sendRedirect("login.jsp");
            return;

        }

        String leaveType = request.getParameter("leaveType");

        LocalDate start = LocalDate.parse(request.getParameter("startDate"));

        LocalDate end = LocalDate.parse(request.getParameter("endDate"));

        String reason = request.getParameter("reason");

        int totalDays = (int) ChronoUnit.DAYS.between(start, end) + 1;

        LeaveApplication leave = new LeaveApplication();

        leave.setUserId(user.getUserId());
        leave.setLeaveType(leaveType);
        leave.setStartDate(Date.valueOf(start));
        leave.setEndDate(Date.valueOf(end));
        leave.setTotalDays(totalDays);
        leave.setReason(reason);

        //Supporting Documnet Upload
        
        Part part = request.getPart("docs");
        
        Map docpath = cloudinary.uploader().upload(part, ObjectUtils.emptyMap());

        if (part != null && part.getSize() > 0) {

            String uploadFolder = (String) docpath.get("secure_url");
            
            leave.setDocs(uploadFolder);
        }

        //Personal Leave Validation
        if ("Personal".equalsIgnoreCase(leaveType)) {

            int remaining
                    = leaveDAO.getRemainingPersonalLeave(
                            user.getUserId());

            if (totalDays > remaining) {
                response.sendRedirect("leave.jsp?error=insufficient");
                return;
            }
        }

        boolean success = leaveDAO.applyLeave(leave);

        if (success) {
            response.sendRedirect("LeaveServlet?action=history");
        } else {
            response.sendRedirect("leave.jsp?error=failed");
        }

    }

    /*
     * ==========================================
     * LEAVE HISTORY
     * ==========================================
     */
    private void showHistory(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User user = (User) session.getAttribute("user");

        request.setAttribute("leaveHistory",leaveDAO.getLeaveHistory(user.getUserId()));

        request.setAttribute("remainingLeave",leaveDAO.getRemainingPersonalLeave(user.getUserId()));

        request.getRequestDispatcher("leaveHistory.jsp").forward(request, response);

    }

    /*
     * ==========================================
     * APPROVE
     * ==========================================
     */
    private void approveLeave(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int leaveId= Integer.parseInt(request.getParameter("leaveId"));

        leaveDAO.approveLeave(leaveId);

        response.sendRedirect("SupervisorLeaveServlet");

    }

    /*
     * ==========================================
     * REJECT
     * ==========================================
     */
    private void rejectLeave(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int leaveId = Integer.parseInt(request.getParameter("leaveId"));

        leaveDAO.rejectLeave(leaveId);

        response.sendRedirect("SupervisorLeaveServlet");

    }

}
