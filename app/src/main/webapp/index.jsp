<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tomcat Web Application</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 20px;
            background: white;
            margin-top: 50px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        h1 {
            color: #2c3e50;
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
        }
        .welcome {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
            border-left: 4px solid #007bff;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .feature {
            background: #ffffff;
            border: 1px solid #dee2e6;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            transition: transform 0.3s;
        }
        .feature:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .feature h3 {
            color: #495057;
            margin-bottom: 10px;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
            margin: 5px;
        }
        .btn:hover {
            background: #0056b3;
        }
        .info {
            background: #e9ecef;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #dee2e6;
            color: #6c757d;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Tomcat Web Application</h1>
        
        <div class="welcome">
            <h2>Welcome to your Apache Tomcat application!</h2>
            <p>This application is running on AWS EC2 with Apache Tomcat. It demonstrates a complete deployment pipeline using Terraform for infrastructure and Maven for application build.</p>
        </div>

        <div class="features">
            <div class="feature">
                <h3>📊 Server Status</h3>
                <p>Application is running successfully</p>
                <div class="info">
                    <strong>Server Time:</strong><br>
                    <%= LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) %>
                </div>
            </div>

            <div class="feature">
                <h3>🔧 Server Info</h3>
                <div class="info">
                    <strong>Server:</strong><br>
                    <%= application.getServerInfo() %><br><br>
                    <strong>Java Version:</strong><br>
                    <%= System.getProperty("java.version") %>
                </div>
            </div>

            <div class="feature">
                <h3>🌐 Session Info</h3>
                <div class="info">
                    <strong>Session ID:</strong><br>
                    <%= session.getId() %><br><br>
                    <strong>Creation Time:</strong><br>
                    <%= new java.util.Date(session.getCreationTime()) %>
                </div>
            </div>
        </div>

        <div class="welcome">
            <h3>🎯 Test the Application</h3>
            <p>Try out the different features of this web application:</p>
            <a href="hello" class="btn">Hello Servlet</a>
            <a href="hello?name=Developer" class="btn">Personalized Greeting</a>
            <a href="/manager" class="btn" onclick="alert('Manager app requires authentication'); return false;">Manager App</a>
        </div>

        <div class="info">
            <h4>📋 Application Features:</h4>
            <ul>
                <li>✅ Java Servlet API integration</li>
                <li>✅ JSP (JavaServer Pages) support</li>
                <li>✅ Session management</li>
                <li>✅ Error handling</li>
                <li>✅ Responsive design</li>
                <li>✅ AWS EC2 deployment ready</li>
            </ul>
        </div>

        <div class="footer">
            <p>&copy; 2024 Tomcat Web Application. Deployed on AWS EC2 with ❤️</p>
            <p><small>Built with Java, Maven, and deployed using Terraform</small></p>
        </div>
    </div>
</body>
</html>
