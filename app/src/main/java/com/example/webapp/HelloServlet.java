package com.example.webapp;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Sample servlet that demonstrates basic servlet functionality
 */
@WebServlet("/hello")
public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        String name = request.getParameter("name");
        if (name == null || name.trim().isEmpty()) {
            name = "World";
        }
        
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Hello Servlet</title>");
            out.println("<style>");
            out.println("body { font-family: Arial, sans-serif; margin: 40px; }");
            out.println(".container { max-width: 800px; margin: 0 auto; }");
            out.println("h1 { color: #2c3e50; }");
            out.println(".info { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; }");
            out.println("</style>");
            out.println("</head>");
            out.println("<body>");
            out.println("<div class='container'>");
            out.println("<h1>Hello, " + name + "!</h1>");
            out.println("<div class='info'>");
            out.println("<p><strong>Current Time:</strong> " + 
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            out.println("</p>");
            out.println("<p><strong>Server Info:</strong> " + getServletContext().getServerInfo() + "</p>");
            out.println("<p><strong>Servlet Name:</strong> " + getServletName() + "</p>");
            out.println("<p><strong>Request Method:</strong> " + request.getMethod() + "</p>");
            out.println("<p><strong>Request URI:</strong> " + request.getRequestURI() + "</p>");
            out.println("</div>");
            out.println("<p>Try adding <code>?name=YourName</code> to the URL to personalize the greeting!</p>");
            out.println("<p><a href='index.jsp'>Back to Home</a></p>");
            out.println("</div>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
