/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Attendance;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AttendanceDAO {

    private Connection connection;

    public AttendanceDAO() {
        connection = DatabaseConnection.getConnection();
    }

    /*
        CHECK IF USER HAS AN ATTENDANCE RECORD TODAY
     */
    public Attendance getTodayAttendance(int userId) {

        Attendance attendance = null;

        try {

            String sql
                    = "SELECT * FROM attendance "
                    + "WHERE user_id=? "
                    + "AND attendance_date=CURDATE()";

            PreparedStatement ps
                    = connection.prepareStatement(sql);

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                attendance = new Attendance();

                attendance.setAttendanceId(rs.getInt("attendance_id"));
                attendance.setUserId(rs.getInt("user_id"));
                attendance.setClockOut(rs.getTimestamp("clock_out"));
                attendance.setClockIn(rs.getTimestamp("clock_in"));
                attendance.setAttendanceStatus(rs.getString("attendance_status"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return attendance;
    }

    /*
        CLOCK IN
     */
    public boolean clockIn(
            int userId,
            String status,
            String selfiePathIn,
            String commentIn
    ) {
        String sql = "UPDATE attendance "
                + "SET clock_in = NOW(), "
                + "    attendance_status = ?, "
                + "    selfie_path_in = ?, "
                + "    comm = ? " 
                + "WHERE user_id = ? "
                + "  AND attendance_date = CURDATE()";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, selfiePathIn);
            ps.setString(3, commentIn);
            ps.setInt(4, userId);

            int result = ps.executeUpdate();
            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    //   CLOCK OUT
    public boolean clockOut(String selfiePathOut, int attID) {

        try {

            String sql
                    = "UPDATE attendance "
                    + "SET clock_out=NOW(), "
                    + "selfie_path_out=? "
                    + "WHERE attendance_id=? "
                    + "AND clock_out IS NULL "
                    + "AND clock_in IS NOT NULL";

            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setString(1, selfiePathOut);
            ps.setInt(2, attID);

            int result = ps.executeUpdate();

            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    //  GET ATTENDANCE HISTORY
    public List<Attendance> getAttendanceHistory(int userId) {

        List<Attendance> list = new ArrayList<>();

        try {
            String sql
                    = "SELECT * FROM attendance "
                    + "WHERE user_id=? "
                    + "AND DATE(attendance_date) <= CURDATE() + 1 "
                    + "ORDER BY attendance_date DESC";

            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Attendance attendance = new Attendance();
                attendance.setAttendanceId(rs.getInt("attendance_id"));
                attendance.setUserId(rs.getInt("user_id"));
                attendance.setAttendanceDate(rs.getDate("attendance_date"));
                attendance.setClockIn(rs.getTimestamp("clock_in"));
                attendance.setClockOut(rs.getTimestamp("clock_out"));
                attendance.setAttendanceStatus(rs.getString("attendance_status"));
                attendance.setSelfiePathIn(rs.getString("selfie_path_in"));
                attendance.setSelfiePathOut(rs.getString("selfie_path_out"));
                attendance.setComment(rs.getString("comm"));
                list.add(attendance);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    //   SUPERVISOR VIEW ALL ATTENDANCE
    public List<Attendance> getAllSystemAttendance() {
        List<Attendance> attendanceList = new ArrayList<>();

        String sql = "SELECT a.*, u.full_name AS name FROM attendance a "
                + "INNER JOIN users u ON a.user_id = u.user_id "
                + "WHERE DATE(attendance_date) <= CURDATE() + 1 "
                + "ORDER BY a.attendance_date DESC, a.clock_in DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Attendance attendance = new Attendance();
                attendance.setAttendanceId(rs.getInt("attendance_id"));
                attendance.setUserId(rs.getInt("user_id"));
                attendance.setUserName(rs.getString("name"));
                attendance.setAttendanceDate(rs.getDate("attendance_date"));
                attendance.setClockIn(rs.getTimestamp("clock_in"));
                attendance.setClockOut(rs.getTimestamp("clock_out"));
                attendance.setAttendanceStatus(rs.getString("attendance_status"));
                attendance.setSelfiePathIn(rs.getString("selfie_path_in"));
                attendance.setSelfiePathOut(rs.getString("selfie_path_out"));
                attendance.setComment(rs.getString("comm"));
                attendanceList.add(attendance);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return attendanceList;
    }

    public List<Attendance> getTodayAttendance() {
        List<Attendance> attendanceList = new ArrayList<>();

        // JOIN alignment: Adjust "users", "user_id", and "name" to match your actual database column names
        String sql = "SELECT a.*, u.full_name AS name FROM attendance a "
                + "INNER JOIN users u ON a.user_id = u.user_id "
                + "WHERE a.attendance_date = CURRENT_DATE "
                + "ORDER BY a.clock_in DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Attendance attendance = new Attendance();
                attendance.setAttendanceId(rs.getInt("attendance_id"));
                attendance.setUserId(rs.getInt("user_id"));
                attendance.setUserName(rs.getString("name")); // Maps the joined username string
                attendance.setAttendanceDate(rs.getDate("attendance_date"));
                attendance.setClockIn(rs.getTimestamp("clock_in"));
                attendance.setClockOut(rs.getTimestamp("clock_out"));
                attendance.setAttendanceStatus(rs.getString("attendance_status"));
                attendance.setSelfiePathIn(rs.getString("selfie_path_in"));
                attendance.setSelfiePathOut(rs.getString("selfie_path_out"));
                attendance.setComment(rs.getString("comm"));
                attendanceList.add(attendance);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return attendanceList;
    }

    public Attendance clockOutCheck(int userId) {
        // Select the necessary columns (or *) directly
        String sql = "SELECT * FROM attendance "
                + "WHERE user_id = ? "
                + "  AND DATE(attendance_date) < CURDATE() "
                + "  AND clock_out IS NULL "
                + "  AND clock_in IS NOT NULL "
                + "  AND attendance_status <> 'On Leave'"
                + "ORDER BY attendance_date DESC "
                + "LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                // If a record exists with no clock_out, populate and return the Attendance object
                if (rs.next()) {
                    Attendance attendance = new Attendance();
                    attendance.setAttendanceId(rs.getInt("attendance_id"));
                    attendance.setClockIn(rs.getTimestamp("clock_in"));
                    attendance.setClockOut(rs.getTimestamp("clock_out"));
                    
                    return attendance;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Returns null if no unclosed past attendance record is found
        return null;
    }

}
