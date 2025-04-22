<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Library Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: #f8f9fa;
        }
        .dashboard-card {
            transition: transform 0.2s ease;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <div class="text-center mb-5">
            <h1 class="display-4 fw-bold text-primary">Library Dashboard</h1>
            <p class="lead text-secondary">Manage your library resources efficiently</p>
        </div>

        <div class="row justify-content-center g-4">
            <div class="col-md-3">
                <div class="card text-white bg-success dashboard-card">
                    <div class="card-body text-center">
                        <h5 class="card-title">Books</h5>
                        <p class="card-text">View and manage books</p>
                        <a href="Book.jsp" class="btn btn-light btn-sm">Go</a>
                    </div>
                </div>
            </div>

            <div class="col-md-3">
                <div class="card text-white bg-info dashboard-card">
                    <div class="card-body text-center">
                        <h5 class="card-title">Members</h5>
                        <p class="card-text">Manage library members</p>
                        <a href="member.jsp" class="btn btn-light btn-sm">Go</a>
                    </div>
                </div>
            </div>

            <div class="col-md-3">
                <div class="card text-dark bg-warning dashboard-card">
                    <div class="card-body text-center">
                        <h5 class="card-title">Issue Book</h5>
                        <p class="card-text">Issue or return books</p>
                        <a href="issueBook.jsp" class="btn btn-dark btn-sm">Go</a>
                    </div>
                </div>
            </div>

            <div class="col-md-3">
                <div class="card text-white bg-danger dashboard-card">
                    <div class="card-body text-center">
                        <h5 class="card-title">Logout</h5>
                        <p class="card-text">Sign out of your account</p>
                        <a href="logout.jsp" class="btn btn-light btn-sm">Logout</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
