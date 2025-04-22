<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Library Management - Login</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <style>
            body {
                background-color: #f8f9fa;
            }
            .login-box {
                margin-top: 100px;
                max-width: 400px;
                margin-left: auto;
                margin-right: auto;
            }
            .card {
                border-radius: 12px;
                box-shadow: 0 0 15px rgba(0,0,0,0.1);
            }
        </style>
    </head>
    <body>

        <div class="container login-box">
            <div class="card">
                <div class="card-header bg-primary text-white text-center">
                    <h4>Library Login</h4>
                </div>
                <div class="card-body">
                    <div id="loginMessage"></div>
                    <form id="loginForm">
                        <div class="mb-3">
                            <label for="username" class="form-label">Username</label>
                            <input type="text" class="form-control" id="username" name="username" required>
                        </div>
                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">Login</button>
                    </form>
                </div>
            </div>
        </div>

        <script>
            document.getElementById("loginForm").addEventListener("submit", function (event) {
                event.preventDefault();

                let username = document.getElementById("username").value;
                let password = document.getElementById("password").value;

                let formBody = new URLSearchParams();
                formBody.append("username", username);
                formBody.append("password", password);

                fetch("api/login?action=login", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: formBody.toString()
                })
                        .then(response => response.json())
                        .then(data => {
                            let messageDiv = document.getElementById("loginMessage");
                            if (data.status === "success") {
                                messageDiv.innerHTML = '<div class="alert alert-success">' + data.message + '</div>';
                                setTimeout(() => {
                                    window.location.href = "dashboard.jsp";
                                }, 1000);
                            } else {
                                messageDiv.innerHTML = '<div class="alert alert-danger">' + data.message + '</div>';
                            }
                        });
            });
        </script>

    </body>
</html>
