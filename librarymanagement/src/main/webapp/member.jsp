<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Library Members</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow">
            <div class="container-fluid">
                <a class="navbar-brand" href="dashboard.jsp">Library Management</a>
            </div>
        </nav>
        <div class="container mt-5">
            <h2 class="text-center mb-4">Library Members</h2>
            <div id="memberMessage"></div>
            <form id="memberForm" class="mb-4">
                <input type="hidden" id="memberId">
                <div class="mb-3">
                    <label for="memberName" class="form-label">Name</label>
                    <input type="text" class="form-control" id="memberName" name="name" required>
                </div>
                <div class="mb-3">
                    <label for="memberEmail" class="form-label">Email</label>
                    <input type="email" class="form-control" id="memberEmail" name="email" required>
                </div>
                <button type="submit" class="btn btn-primary">Save Member</button>
            </form>

            <table class="table table-bordered">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="memberTableBody">
                    <!-- Filled dynamically -->
                </tbody>
            </table>
        </div>

        <script>
            document.addEventListener("DOMContentLoaded", fetchMembers);

            function fetchMembers() {
                fetch("api/member")
                        .then(response => response.json())
                        .then(data => {
                            const tbody = document.getElementById("memberTableBody");
                            tbody.innerHTML = "";
                            data.forEach(member => {
                                tbody.innerHTML += `
                                <tr>
                                    <td>` + member.id + `</td>
                                    <td>` + member.name + `</td>
                                    <td>` + member.email + `</td>
                                    <td>
                                        <button class="btn btn-sm btn-primary me-2" onclick='editMember(` + JSON.stringify(member) + `)'>Edit</button>
                                        <button class="btn btn-sm btn-danger" onclick="deleteMember(` + member.id + `)">Delete</button>
                                    </td>
                                </tr>
                            `;
                            });
                        });
            }

            function editMember(member) {
                if (typeof member === "string") {
                    member = JSON.parse(member);
                }
                document.getElementById("memberId").value = member.id;
                document.getElementById("memberName").value = member.name;
                document.getElementById("memberEmail").value = member.email;
            }

            function deleteMember(id) {
                let formBody = new URLSearchParams();
                formBody.append("id", id);
                formBody.append("action", "delete");

                fetch("api/member", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: formBody.toString()
                })
                        .then(response => response.json())
                        .then(data => {
                            document.getElementById("memberForm").reset();
                            fetchMembers();
                        });
            }

            document.getElementById("memberForm").addEventListener("submit", function (event) {
                event.preventDefault();
                let id = document.getElementById("memberId").value;
                let name = document.getElementById("memberName").value;
                let email = document.getElementById("memberEmail").value;
                let action = id ? "update" : "add";

                let formBody = new URLSearchParams();
                formBody.append("id", id);
                formBody.append("name", name);
                formBody.append("email", email);
                formBody.append("action", action);

                fetch("api/member", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: formBody.toString()
                })
                        .then(response => response.json())
                        .then(data => {
                            document.getElementById("memberId").value = null;
                            document.getElementById("memberForm").reset();
                            fetchMembers();
                            document.getElementById("memberMessage").innerHTML = '<div class="alert alert-success">' + data.message + '</div>';
                        });
            });
        </script>
    </body>
</html>
