/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.library.api;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import com.library.model.Book;
import com.library.utils.DatabaseConnection;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/book")
public class BookApi extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Book> books = new ArrayList<>();
        try {
            Connection con = DatabaseConnection.getConnection();
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM books");

            while (rs.next()) {
                Book book = new Book(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getString("author"),
                        rs.getString("category"),
                        rs.getString("available")
                );
                books.add(book);
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            try (PrintWriter writer = response.getWriter()) {
                writer.write(gson.toJson(books));
            }
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String id = request.getParameter("id");
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String category = request.getParameter("category");
        String available = request.getParameter("status");
        String action = request.getParameter("action");

        if (("update".equals(action) || "add".equals(action)) && (title == null || author == null || category == null || available == null)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Missing parameters\"}");
            return;
        }

        switch (action) {
            case "update":
                if (id == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Missing id parameter\"}");
                    return;
                }
                try (Connection con = DatabaseConnection.getConnection(); PreparedStatement ps = con.prepareStatement("UPDATE books SET title=?, author=?, category=?, available=? WHERE id=?")) {

                    ps.setString(1, title);
                    ps.setString(2, author);
                    ps.setString(3, category);
                    ps.setString(4, available);
                    ps.setInt(5, Integer.parseInt(id));

                    boolean success = ps.executeUpdate() > 0;

                    response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
                    PrintWriter writer = response.getWriter();
                    writer.write("{\"status\": \"" + (success ? "success" : "error") + "\"}");
                    writer.close();
                } catch (Exception e) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write(e.getMessage());
                }
                break;
            case "delete":
                if (id == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Missing id parameter\"}");
                    return;
                }
                try (Connection con = DatabaseConnection.getConnection(); PreparedStatement ps = con.prepareStatement("DELETE FROM books WHERE id=?")) {

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
                try (Connection con = DatabaseConnection.getConnection(); PreparedStatement ps = con.prepareStatement("INSERT INTO books (title, author, category, available) VALUES (?, ?, ?, ?)")) {

                    ps.setString(1, title);
                    ps.setString(2, author);
                    ps.setString(3, category);
                    ps.setString(4, available);

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
