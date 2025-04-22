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
import com.library.model.Member;
import com.library.utils.DatabaseConnection;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/member")
public class MemberApi extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Member> members = new ArrayList<>();

        try (Connection con = DatabaseConnection.getConnection(); Statement stmt = con.createStatement(); ResultSet rs = stmt.executeQuery("SELECT * FROM members")) {

            while (rs.next()) {
                Member member = new Member(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email")
                );
                members.add(member);
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try (PrintWriter writer = response.getWriter()) {
                writer.write(gson.toJson(members));
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
        String email = request.getParameter("email");
        String name = request.getParameter("name");
        String action = request.getParameter("action");

        if (("update".equals(action) || "add".equals(action))
                && (email == null || name == null)) {
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
                try (Connection con = DatabaseConnection.getConnection(); PreparedStatement ps = con.prepareStatement("UPDATE members SET email=?, name=? WHERE id=?")) {

                    ps.setString(1, email);
                    ps.setString(2, name);
                    ps.setInt(3, Integer.parseInt(id));

                    boolean success = ps.executeUpdate() > 0;
                    response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\": \"" + (success ? "success" : "error") + "\"}");

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
                try (Connection con = DatabaseConnection.getConnection(); PreparedStatement ps = con.prepareStatement("DELETE FROM members WHERE id=?")) {

                    ps.setInt(1, Integer.parseInt(id));
                    boolean success = ps.executeUpdate() > 0;
                    response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\": \"" + (success ? "success" : "error") + "\"}");

                } catch (Exception e) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Database error\"}");
                }
                break;

            default:
                try (Connection con = DatabaseConnection.getConnection(); PreparedStatement ps = con.prepareStatement("INSERT INTO members (email, name) VALUES (?, ?)")) {

                    ps.setString(1, email);
                    ps.setString(2, name);

                    boolean success = ps.executeUpdate() > 0;
                    response.setStatus(success ? HttpServletResponse.SC_CREATED : HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"status\": \"" + (success ? "success" : "error") + "\"}");

                } catch (Exception e) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Database error\"}");
                }
                break;
        }
    }

}
