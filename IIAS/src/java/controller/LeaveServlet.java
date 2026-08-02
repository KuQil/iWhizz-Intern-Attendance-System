package controller;

import dao.LeaveDAO;
import model.LeaveApplication;
import model.User;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

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

    @Override
    public void init() {
        leaveDAO = new LeaveDAO();
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
        String docpath = "C:/Users/Win10/Desktop/WebDev/IIAS/uploads/docs";

        Part part = request.getPart("docs");

        if (part != null && part.getSize() > 0) {

            String fileName = System.currentTimeMillis() + "_" + part.getSubmittedFileName();

            String uploadFolder = docpath;

            File folder = new File(uploadFolder);

            if (!folder.exists()) {
                folder.mkdirs();
            }

            File file = new File(folder, fileName);

            try (InputStream input = part.getInputStream()) {
                Files.copy(input, file.toPath());
            }

            docpath = "uploads/docs/" + fileName;
            
            leave.setDocs(docpath);
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
