/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    String host = System.getenv("DB_HOST");
    String port = System.getenv("DB_PORT");
    String dbName = System.getenv("DB_NAME");
    String user = System.getenv("DB_USER");
    String pass = System.getenv("DB_PASS");

    private static final String URL = "jdbc:mysql://" + host + ":" + port + "/" + dbName + "?useSSL=true&trustServerCertificate=true";

    public static Connection getConnection() {

        Connection connection = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            connection = DriverManager.getConnection(
                    URL,
                    user,
                    pass
            );

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }

        return connection;
    }
}
