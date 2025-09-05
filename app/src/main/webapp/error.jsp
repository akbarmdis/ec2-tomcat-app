<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Tomcat Web Application</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
            color: #333;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            max-width: 600px;
            padding: 40px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            text-align: center;
        }
        h1 {
            color: #e74c3c;
            font-size: 4em;
            margin: 0;
        }
        h2 {
            color: #2c3e50;
            margin: 20px 0;
        }
        .error-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #e74c3c;
            text-align: left;
        }
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
            margin: 10px;
        }
        .btn:hover {
            background: #0056b3;
        }
        .icon {
            font-size: 5em;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">🚨</div>
        <h1><%= request.getAttribute("javax.servlet.error.status_code") != null ? 
                request.getAttribute("javax.servlet.error.status_code") : "Error" %></h1>
        <h2>Oops! Something went wrong</h2>
        
        <div class="error-info">
            <% 
            Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
            String errorMessage = (String) request.getAttribute("javax.servlet.error.message");
            String requestUri = (String) request.getAttribute("javax.servlet.error.request_uri");
            
            if (statusCode != null) {
                switch (statusCode) {
                    case 404:
                        out.println("<p><strong>Error:</strong> Page Not Found</p>");
                        out.println("<p>The requested page could not be found on this server.</p>");
                        break;
                    case 500:
                        out.println("<p><strong>Error:</strong> Internal Server Error</p>");
                        out.println("<p>The server encountered an internal error that prevented it from fulfilling your request.</p>");
                        break;
                    default:
                        out.println("<p><strong>Error Code:</strong> " + statusCode + "</p>");
                        if (errorMessage != null) {
                            out.println("<p><strong>Message:</strong> " + errorMessage + "</p>");
                        }
                        break;
                }
            } else {
                out.println("<p>An unexpected error occurred while processing your request.</p>");
            }
            
            if (requestUri != null) {
                out.println("<p><strong>Requested URI:</strong> " + requestUri + "</p>");
            }
            %>
        </div>
        
        <p>Don't worry! Here are some things you can try:</p>
        <ul style="text-align: left; display: inline-block;">
            <li>Check the URL for typos</li>
            <li>Go back to the previous page</li>
            <li>Return to the home page</li>
            <li>Contact support if the problem persists</li>
        </ul>
        
        <div>
            <a href="javascript:history.back()" class="btn">← Go Back</a>
            <a href="index.jsp" class="btn">🏠 Home Page</a>
        </div>
        
        <div style="margin-top: 30px; font-size: 0.9em; color: #6c757d;">
            <p>Error occurred at: <%= new java.util.Date() %></p>
        </div>
    </div>
</body>
</html>
