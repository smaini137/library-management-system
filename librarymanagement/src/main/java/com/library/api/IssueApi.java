/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.library.api;

import com.google.gson.Gson;
import com.library.model.Issue;
import com.library.utils.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/issue")
public class IssueApi extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Issue> issues = new ArrayList<>();
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM issues");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Issue issue = new Issue(
                        rs.getInt("id"),
                        rs.getInt("book_id"),
                        rs.getInt("member_id"),
                        rs.getDate("issue_date"),
                        rs.getDate("return_date")
                );
                issues.add(issue);
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(issues));
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String id = request.getParameter("id");
        String bookId = request.getParameter("book_id");
        String memberId = request.getParameter("member_id");
        String issueDate = request.getParameter("issue_date");
        String returnDate = request.getParameter("return_date");
        String action = request.getParameter("action");

        switch (action != null ? action : "add") {
            case "update":
                if (id == null || bookId == null || memberId == null || issueDate == null || returnDate == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Missing parameters\"}");
                    return;
                }
                try (Connection con = DatabaseConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement("UPDATE issues SET book_id=?, member_id=?, issue_date=?, return_date=? WHERE id=?")) {

                    ps.setInt(1, Integer.parseInt(bookId));
                    ps.setInt(2, Integer.parseInt(memberId));
                    ps.setString(3, issueDate);
                    ps.setString(4, returnDate);
                    ps.setInt(5, Integer.parseInt(id));

                    boolean success = ps.executeUpdate() > 0;

                    response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
                    PrintWriter writer = response.getWriter();
                    writer.write("{\"status\": \"" + (success ? "success" : "error") + "\"}");
                    writer.close();
                } catch (Exception e) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Database error\"}");
                }
                break;

            case "delete":
                if (id == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Missing id parameter\"}");
                    return;
                }
                try (Connection con = DatabaseConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement("DELETE FROM issues WHERE id=?")) {

                    ps.setInt(1, Integer.parseInt(id));
                    boolean success = ps.executeUpdate() > 0;

                    response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
                    PrintWriter writer = response.getWriter();
                    writer.write("{\"status\": \"" + (success ? "success" : "error") + "\"}");
                    writer.close();
                } catch (Exception e) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Database error\"}");
                }
                break;

            default:
                if (bookId == null || memberId == null || issueDate == null || returnDate == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Missing parameters\"}");
                    return;
                }
                try (Connection con = DatabaseConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement("INSERT INTO issues (book_id, member_id, issue_date, return_date) VALUES (?, ?, ?, ?)")) {

                    ps.setInt(1, Integer.parseInt(bookId));
                    ps.setInt(2, Integer.parseInt(memberId));
                    ps.setString(3, issueDate);
                    ps.setString(4, returnDate);

                    boolean success = ps.executeUpdate() > 0;

                    response.setStatus(success ? HttpServletResponse.SC_CREATED : HttpServletResponse.SC_BAD_REQUEST);
                    PrintWriter writer = response.getWriter();
                    writer.write("{\"status\": \"" + (success ? "success" : "error") + "\"}");
                    writer.close();
                } catch (Exception e) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Database error\"}");
                }
                break;
        }
    }
}
