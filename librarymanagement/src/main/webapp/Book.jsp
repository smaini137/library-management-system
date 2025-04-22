<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="com.library.model.User" %>
<%
    HttpSession sessionObj = request.getSession(false);
    User user = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Book Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <style>
            body {
                background-color: #f0f2f5;
            }
            .card-custom {
                background-color: white;
                border-radius: 15px;
                padding: 25px;
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
            }
            .form-control, .form-select {
                border-radius: 10px;
            }
            .btn {
                border-radius: 10px;
            }
            .table thead {
                background-color: #343a40;
                color: #fff;
            }
        </style>
    </head>
    <body>
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow">
            <div class="container-fluid">
                <a class="navbar-brand" href="dashboard.jsp">Library Management</a>
            </div>
        </nav>

        <div class="container my-5">
            <div class="card card-custom">
                <h3 class="text-center mb-4">Book Management</h3>

                <form id="bookForm">
                    <input type="hidden" id="bookId">
                    <div class="row g-3 mb-4">
                        <div class="col-md-3">
                            <input type="text" id="title" class="form-control" placeholder="Book Title" required>
                        </div>
                        <div class="col-md-3">
                            <input type="text" id="author" class="form-control" placeholder="Author" required>
                        </div>
                        <div class="col-md-3">
                            <input type="text" id="category" class="form-control" placeholder="Category" required>
                        </div>
                        <div class="col-md-2">
                            <select id="available" class="form-select" required>
                                <option value="">Available?</option>
                                <option value="1">Yes</option>
                                <option value="0">No</option>
                            </select>
                        </div>
                        <div class="col-md-1 d-grid">
                            <button type="submit" class="btn btn-primary">Save</button>
                        </div>
                    </div>
                </form>

                <div class="table-responsive">
                    <table class="table table-hover table-bordered align-middle">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Category</th>
                                <th>Available</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="bookTable"></tbody>
                    </table>
                </div>
            </div>
        </div>

        <script>
            function fetchBooks() {
                fetch("api/book")
                    .then(response => response.json())
                    .then(data => {
                        var table = document.getElementById("bookTable");
                        table.innerHTML = "";
                        for (var i = 0; i < data.length; i++) {
                            var book = data[i];
                            var row = "<tr>" +
                                "<td>" + book.id + "</td>" +
                                "<td>" + book.title + "</td>" +
                                "<td>" + book.author + "</td>" +
                                "<td>" + book.category + "</td>" +
                                "<td>" + (book.available ? "Yes" : "No") + "</td>" +
                                "<td>" +
                                "<button class='btn btn-warning btn-sm me-1' onclick='editBook(" + JSON.stringify(book) + ")'>Edit</button>" +
                                "<button class='btn btn-danger btn-sm' onclick='deleteBook(" + book.id + ")'>Delete</button>" +
                                "</td>" +
                                "</tr>";
                            table.innerHTML += row;
                        }
                    })
                    .catch(error => {
                        console.error("Error fetching books:", error);
                    });
            }

            document.getElementById("bookForm").addEventListener("submit", function(event) {
                event.preventDefault();
                var id = document.getElementById("bookId").value;
                var title = document.getElementById("title").value;
                var author = document.getElementById("author").value;
                var category = document.getElementById("category").value;
                var available = document.getElementById("available").value;
                var action = id ? "update" : "add";

                var formBody = new URLSearchParams();
                formBody.append("id", id);
                formBody.append("title", title);
                formBody.append("author", author);
                formBody.append("category", category);
                formBody.append("status", available);
                formBody.append("action", action);

                fetch("api/book", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: formBody.toString()
                })
                .then(response => response.json())
                .then(() => {
                    fetchBooks();
                    document.getElementById("bookForm").reset();
                    document.getElementById("bookId").value = "";
                })
                .catch(error => {
                    console.error("Error saving book:", error);
                });
            });

            function editBook(book) {
                document.getElementById("bookId").value = book.id;
                document.getElementById("title").value = book.title;
                document.getElementById("author").value = book.author;
                document.getElementById("category").value = book.category;
                document.getElementById("available").value = book.available;
            }

            function deleteBook(id) {
                if (confirm("Are you sure you want to delete this book?")) {
                    var formBody = new URLSearchParams();
                    formBody.append("id", id);
                    formBody.append("action", "delete");

                    fetch("api/book", {
                        method: "POST",
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: formBody.toString()
                    })
                    .then(() => {
                        fetchBooks();
                    })
                    .catch(error => {
                        console.error("Error deleting book:", error);
                    });
                }
            }

            fetchBooks();
        </script>
    </body>
</html>
