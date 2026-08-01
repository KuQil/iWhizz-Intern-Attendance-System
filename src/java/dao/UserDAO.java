/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.sql.Date;

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
}
