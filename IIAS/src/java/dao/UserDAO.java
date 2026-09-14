/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import model.User;

import util.DatabaseConnection;

public class UserDAO {
    
    private Connection connection;
    
    public UserDAO(){
        connection = DatabaseConnection.getConnection();
    }

    public User login(String username, String password) {

        User user = null;

        try {

            String sql = "SELECT * FROM users WHERE username=? AND password=? AND account_status='active'";

            PreparedStatement statement = connection.prepareStatement(sql);

            statement.setString(1, username);
            statement.setString(2, password);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {

                user = new User();

                user.setUserId(resultSet.getInt("user_id"));
                user.setUsername(resultSet.getString("username"));
                user.setFullName(resultSet.getString("full_name"));
                user.setRole(resultSet.getString("role"));
                user.setOnField(resultSet.getBoolean("is_onfield"));
                user.setInternshipStart(resultSet.getDate("internship_start"));
                user.setInternshipEnd(resultSet.getDate("internship_end"));
                user.setPersonalLeaveRemaining(resultSet.getInt("personal_leave_remaining"));
            }

            connection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    public boolean addUser(User user) {

        try {

            String sql
                    = "INSERT INTO users "
                    + "(username, password, full_name, role, "
                    + "internship_start, internship_end, personal_leave_remaining) "
                    + "VALUES (?,?,?,?,?,?,?)";

            PreparedStatement ps
                    = connection.prepareStatement(sql);

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, "intern");
            ps.setDate(5, user.getInternshipStart());
            ps.setDate(6, user.getInternshipEnd());

            // 1 leave per month
            int months
                    = (user.getInternshipEnd().getMonth()
                    - user.getInternshipStart().getMonth()) + 1;

            ps.setInt(7, months);

            int result = ps.executeUpdate();

            connection.close();

            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateUserProfile(User user) {

        // If password is provided, update it; otherwise keep current password
        boolean updatePassword = (user.getPassword() != null && !user.getPassword().trim().isEmpty());

        StringBuilder sql = new StringBuilder("UPDATE users SET username = ?, full_name = ?, internship_start = ?, internship_end = ? ");
        if (updatePassword) {
            sql.append(", password = ? ");
        }
        
        sql.append("WHERE user_id = ?");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getFullName());
            ps.setDate(3, user.getInternshipStart());
            ps.setDate(4, user.getInternshipEnd());

            if (updatePassword) {
                ps.setString(5, user.getPassword());
                ps.setInt(6, user.getUserId());
            } else {
                ps.setInt(5, user.getUserId());
            }

            int rowsUpdated = ps.executeUpdate();
            return rowsUpdated > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Get all active interns (for supervisor management)
     */
    public List<User> getAllActiveInterns() {
        List<User> internsList = new ArrayList<>();

        try {
            String sql = "SELECT * FROM users WHERE role = 'intern' AND account_status = 'active' ORDER BY full_name ASC";
            
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                User intern = new User();
                intern.setUserId(rs.getInt("user_id"));
                intern.setUsername(rs.getString("username"));
                intern.setFullName(rs.getString("full_name"));
                intern.setRole(rs.getString("role"));
                intern.setOnField(rs.getBoolean("is_onfield"));
                intern.setInternshipStart(rs.getDate("internship_start"));
                intern.setInternshipEnd(rs.getDate("internship_end"));
                intern.setPersonalLeaveRemaining(rs.getInt("personal_leave_remaining"));
                intern.setAccountStatus(rs.getString("account_status"));
                
                internsList.add(intern);
            }

            connection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return internsList;
    }

    /**
     * Get a specific user by ID
     */
    public User getUserById(int userId) {
        User user = null;

        try {
            String sql = "SELECT * FROM users WHERE user_id = ?";
            
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, userId);
            
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("full_name"));
                user.setRole(rs.getString("role"));
                user.setOnField(rs.getBoolean("is_onfield"));
                user.setInternshipStart(rs.getDate("internship_start"));
                user.setInternshipEnd(rs.getDate("internship_end"));
                user.setPersonalLeaveRemaining(rs.getInt("personal_leave_remaining"));
                user.setAccountStatus(rs.getString("account_status"));
            }

            connection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    /**
     * Archive a user account (set account_status to 'archived')
     */
    public boolean archiveUser(int userId) {
        try {
            String sql = "UPDATE users SET account_status = 'archived' WHERE user_id = ?";
            
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, userId);
            
            int result = ps.executeUpdate();
            connection.close();
            
            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Delete a user account permanently
     */
    public boolean deleteUser(int userId) {
        try {
            String sql = "DELETE FROM users WHERE user_id = ? AND role = 'intern'";
            
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, userId);
            
            int result = ps.executeUpdate();
            connection.close();
            
            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
