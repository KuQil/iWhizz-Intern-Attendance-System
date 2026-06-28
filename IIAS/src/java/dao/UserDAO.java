/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import model.User;

import util.DatabaseConnection;

public class UserDAO {

    public User login(String username, String password) {

        User user = null;

        try {

            Connection connection = DatabaseConnection.getConnection();

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
            }

            connection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    public boolean addUser(User user) {

        try {

            Connection conn
                    = DatabaseConnection.getConnection();

            String sql
                    = "INSERT INTO users "
                    + "(username, password, full_name, role, "
                    + "internship_start, internship_end, personal_leave_remaining) "
                    + "VALUES (?,?,?,?,?,?,?)";

            PreparedStatement ps
                    = conn.prepareStatement(sql);

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

            conn.close();

            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
