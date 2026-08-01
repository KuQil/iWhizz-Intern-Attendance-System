package dao;

import model.LeaveApplication;
import util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.DayOfWeek;
import java.util.ArrayList;
import java.util.List;

public class LeaveDAO {

    /*
     * Apply Leave
     */
    public boolean applyLeave(LeaveApplication leave) {

        String sql
                = "INSERT INTO leave_application "
                + "(user_id, leave_type, start_date, end_date, "
                + "total_days, reason, docs) "
                + "VALUES (?,?,?,?,?,?,?)";

        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, leave.getUserId());
            ps.setString(2, leave.getLeaveType());
            ps.setDate(3, leave.getStartDate());
            ps.setDate(4, leave.getEndDate());
            ps.setInt(5, leave.getTotalDays());
            ps.setString(6, leave.getReason());
            ps.setString(7, leave.getDocs());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    /*
     * Intern Leave History
     */
    public List<LeaveApplication> getLeaveHistory(int userId) {

        List<LeaveApplication> list
                = new ArrayList<>();

        String sql
                = "SELECT * FROM leave_application "
                + "WHERE user_id=? "
                + "ORDER BY applied_date DESC";

        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                LeaveApplication leave = new LeaveApplication();
                leave.setLeaveId(rs.getInt("leave_id"));
                leave.setUserId(rs.getInt("user_id"));
                leave.setLeaveType(rs.getString("leave_type"));
                leave.setStartDate(rs.getDate("start_date"));
                leave.setEndDate(rs.getDate("end_date"));
                leave.setTotalDays(rs.getInt("total_days"));
                leave.setReason(rs.getString("reason"));
                leave.setDocs(rs.getString("docs"));
                leave.setStatus(rs.getString("status"));
                leave.setAppliedDate(rs.getTimestamp("applied_date"));
                leave.setReviewedDate(rs.getTimestamp("reviewed_date"));
                list.add(leave);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /*
     * Supervisor Pending Leave List
     */
    public List<LeaveApplication> getPendingLeaves() {

        List<LeaveApplication> list = new ArrayList<>();

        String sql
                = "SELECT l.*, u.full_name "
                + "FROM leave_application l "
                + "JOIN users u "
                + "ON l.user_id=u.user_id "
                + "WHERE l.status='Pending' "
                + "ORDER BY l.applied_date ASC";

        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                LeaveApplication leave = new LeaveApplication();
                leave.setLeaveId(rs.getInt("leave_id"));
                leave.setUserId(rs.getInt("user_id"));
                leave.setInternName(rs.getString("full_name"));
                leave.setLeaveType(rs.getString("leave_type"));
                leave.setStartDate(rs.getDate("start_date"));
                leave.setEndDate(rs.getDate("end_date"));
                leave.setTotalDays(rs.getInt("total_days"));
                leave.setReason(rs.getString("reason"));
                leave.setDocs(rs.getString("docs"));
                leave.setStatus(rs.getString("status"));
                leave.setAppliedDate(rs.getTimestamp("applied_date"));
                list.add(leave);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    //Remaining Personal Leave
    public int getRemainingPersonalLeave(int userId) {
        int totalEntitlement = 0;
        int daysUsed = 0;

        String sql = "SELECT "
                + "  (SELECT personal_leave_remaining FROM users WHERE user_id = ?) AS entitlement, "
                + "  (SELECT COUNT(*) FROM attendance WHERE user_id = ? AND attendance_status = 'Personal') AS used";

        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalEntitlement = rs.getInt("entitlement");
                    daysUsed = rs.getInt("used");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return totalEntitlement - daysUsed;
    }

    public boolean approveLeave(int leaveId) {
        String selectSql = "SELECT * FROM leave_application WHERE leave_id = ?";
        String updateLeaveSql = "UPDATE leave_application SET status = 'Approved', reviewed_date = NOW() WHERE leave_id = ?";
        String insertAttendanceSql = "INSERT INTO attendance (user_id, attendance_date, attendance_status) VALUES (?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE attendance_status = 'On Leave'";

        Connection conn = null;

        try {
            conn = DatabaseConnection.getConnection();

            // 1. Fetch leave details
            int userId = 0;
            Date startDate = null;
            Date endDate = null;
            String type = null;

            try (PreparedStatement psSelect = conn.prepareStatement(selectSql)) {
                psSelect.setInt(1, leaveId);
                try (ResultSet rs = psSelect.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                        startDate = rs.getDate("start_date");
                        endDate = rs.getDate("end_date");
                        type = rs.getString("leave_type");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            // 2. Update leave status to Approved
            try (PreparedStatement psUpdate = conn.prepareStatement(updateLeaveSql)) {
                psUpdate.setInt(1, leaveId);
                psUpdate.executeUpdate();
            }

            // 3. Generate attendance inputs for each date in the leave duration
            LocalDate start = startDate.toLocalDate();
            LocalDate end = endDate.toLocalDate();

            try (PreparedStatement psAttendance = conn.prepareStatement(insertAttendanceSql)) {
                for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {

                    if (date.getDayOfWeek() == DayOfWeek.FRIDAY) {
                        continue;
                    }

                    psAttendance.setInt(1, userId);
                    psAttendance.setDate(2, Date.valueOf(date));
                    psAttendance.setString(3, type);
                    psAttendance.addBatch();
                }
                psAttendance.executeBatch();
            }

            return true;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        return false;
    }

    /**
     * Reject Leave Application
     */
    public boolean rejectLeave(int leaveId) {
        String sql = "UPDATE leave_application SET status = 'Rejected', reviewed_date = NOW() WHERE leave_id = ?";

        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, leaveId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Fetch ALL Leave Applications for Supervisor (Pending, Approved, Rejected)
     */
    public List<LeaveApplication> getAllLeavesForSupervisor() {
        List<LeaveApplication> list = new ArrayList<>();

        String sql = "SELECT l.*, u.full_name "
                + "FROM leave_application l "
                + "JOIN users u ON l.user_id = u.user_id "
                + "ORDER BY CASE WHEN l.status = 'Pending' THEN 1 ELSE 2 END, l.applied_date DESC";

        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                LeaveApplication leave = new LeaveApplication();
                leave.setLeaveId(rs.getInt("leave_id"));
                leave.setUserId(rs.getInt("user_id"));
                leave.setInternName(rs.getString("full_name"));
                leave.setLeaveType(rs.getString("leave_type"));
                leave.setStartDate(rs.getDate("start_date"));
                leave.setEndDate(rs.getDate("end_date"));
                leave.setTotalDays(rs.getInt("total_days"));
                leave.setReason(rs.getString("reason"));
                leave.setDocs(rs.getString("docs"));
                leave.setStatus(rs.getString("status"));
                leave.setAppliedDate(rs.getTimestamp("applied_date"));
                leave.setReviewedDate(rs.getTimestamp("reviewed_date"));

                list.add(leave);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

}
