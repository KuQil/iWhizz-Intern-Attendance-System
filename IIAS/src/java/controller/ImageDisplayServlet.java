package controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/uploads/*")
public class ImageDisplayServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo(); // captures "/selfies/filename.jpg"
        
        // Match this path with where the files are actually being written on your disk
        File file = new File("C:/Users/Win10/Desktop/WebDev/IIAS/uploads", pathInfo);

        if (file.exists() && file.isFile()) {
            String mimeType = getServletContext().getMimeType(file.getName());
            if (mimeType == null) {
                mimeType = "image/jpeg";
            }
            response.setContentType(mimeType);
            Files.copy(file.toPath(), response.getOutputStream());
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}