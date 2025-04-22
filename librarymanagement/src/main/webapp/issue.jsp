<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Issue Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow">
            <div class="container-fluid">
                <a class="navbar-brand" href="dashboard.jsp">Library Management</a>
            </div>
        </nav>
        <div class="container mt-5">
            <h2 class="text-center mb-4">Issue Management</h2>

            <div id="message"></div>

            <form id="issueForm" class="mb-4">
                <input type="hidden" id="issueId">
                <div class="row mb-3">
                    <div class="col">
                        <label for="bookId" class="form-label">Book ID</label>
                        <input type="number" id="bookId" class="form-control" required>
                    </div>
                    <div class="col">
                        <label for="memberId" class="form-label">Member ID</label>
                        <input type="number" id="memberId" class="form-control" required>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col">
                        <label for="issueDate" class="form-label">Issue Date</label>
                        <input type="date" id="issueDate" class="form-control" required>
                    </div>
                    <div class="col">
                        <label for="returnDate" class="form-label">Return Date</label>
                        <input type="date" id="returnDate" class="form-control">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Save Issue</button>
                <button type="reset" class="btn btn-secondary">Reset</button>
            </form>

            <table class="table table-bordered table-striped">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Book ID</th>
                        <th>Member ID</th>
                        <th>Issue Date</th>
                        <th>Return Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="issueTableBody"></tbody>
            </table>
        </div>

        <script>
            document.addEventListener("DOMContentLoaded", fetchIssues);

            document.getElementById("issueForm").addEventListener("submit", function (e) {
                e.preventDefault();

                let id = document.getElementById("issueId").value;
                let bookId = document.getElementById("bookId").value;
                let memberId = document.getElementById("memberId").value;
                let issueDate = document.getElementById("issueDate").value;
                let returnDate = document.getElementById("returnDate").value;

                let formData = new URLSearchParams();
                if (id)
                    formData.append("id", id);
                formData.append("book_id", bookId);
                formData.append("member_id", memberId);
                formData.append("issue_date", issueDate);
                formData.append("return_date", returnDate);
                formData.append("action", id ? "update" : "add");

                fetch("api/issue", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: formData.toString()
                })
                        .then(response => response.json())
                        .then(data => {
                            let message = document.getElementById("message");
                            message.innerHTML = "<div class='alert alert-" + (data.status === "success" ? "success" : "danger") + "'>" + data.message + "</div>";
                            document.getElementById("issueForm").reset();
                            fetchIssues();
                        });
            });

            function fetchIssues() {
                fetch("api/issue")
                        .then(response => response.json())
                        .then(data => {
                            let tableBody = document.getElementById("issueTableBody");
                            tableBody.innerHTML = "";
                            data.forEach(issue => {
                                tableBody.innerHTML += "<tr>" +
                                        "<td>" + issue.id + "</td>" +
                                        "<td>" + issue.bookId + "</td>" +
                                        "<td>" + issue.memberId + "</td>" +
                                        "<td>" + issue.issueDate + "</td>" +
                                        "<td>" + issue.returnDate + "</td>" +
                                        "<td><button class='btn btn-sm btn-warning me-2' onclick='editIssue(" + JSON.stringify(issue) + ")'>Edit</button>" +
                                        "<button class='btn btn-sm btn-danger' onclick='deleteIssue(" + issue.id + ")'>Delete</button></td>" +
                                        "</tr>";
                            });
                        });
            }

            function editIssue(issue) {
                issue = JSON.parse(issue);
                document.getElementById("issueId").value = issue.id;
                document.getElementById("bookId").value = issue.book_id;
                document.getElementById("memberId").value = issue.member_id;
                document.getElementById("issueDate").value = issue.issue_date;
                document.getElementById("returnDate").value = issue.return_date;
            }

            function deleteIssue(id) {
                let formData = new URLSearchParams();
                formData.append("id", id);
                formData.append("action", "delete");

                fetch("api/issue", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: formData.toString()
                })
                        .then(response => response.json())
                        .then(data => {
                            let message = document.getElementById("message");
                            message.innerHTML = "<div class='alert alert-" + (data.status === "success" ? "success" : "danger") + "'>" + data.message + "</div>";
                            fetchIssues();
                        });
            }
        </script>
    </body>
</html>
