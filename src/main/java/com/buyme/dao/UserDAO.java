package com.buyme.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.buyme.model.User;
import com.buyme.util.DBUtil;  // adjust to your actual util class

public class UserDAO {

    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection(); // adjust if needed
    }

    // Used by LoginServlet: find user by username/password
    public User findByUsernameAndPassword(String username, String passwordHash) {
        String sql = "SELECT * FROM users WHERE username = ? AND password_hash = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, passwordHash);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Create a customer rep and log it in create_account
   // Create a new customer rep user + log which admin created them
public int createCustomerRep(User rep, int adminId, String notes) throws SQLException {

    // 1) Insert into users as role 'cust_rep'
    String insertUserSql = """
        INSERT INTO users
            (full_name, username, email, password_hash, phone, address, role)
        VALUES
            (?, ?, ?, ?, ?, ?, 'cust_rep')
        """;

    // 2) Log which admin created this rep
    // NOTE: use admin_id here to match your DB schema
    String insertLogSql = """
        INSERT INTO create_account
            (user_id, admin_id, notes)
        VALUES
            (?, ?, ?)
        """;

    int newUserId = -1;

    try (Connection conn = getConnection()) {
        conn.setAutoCommit(false);

        try (PreparedStatement psUser =
                     conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS);
             PreparedStatement psLog =
                     conn.prepareStatement(insertLogSql)) {

            // ----- Insert into users -----
            psUser.setString(1, rep.getFullName());
            psUser.setString(2, rep.getUsername());
            psUser.setString(3, rep.getEmail());
            psUser.setString(4, rep.getPasswordHash()); // already hashed in servlet
            psUser.setString(5, rep.getPhone());
            psUser.setString(6, rep.getAddress());

            psUser.executeUpdate();

            try (ResultSet rs = psUser.getGeneratedKeys()) {
                if (rs.next()) {
                    newUserId = rs.getInt(1);
                } else {
                    throw new SQLException("Failed to obtain generated user_id for new rep.");
                }
            }

            // ----- Insert into create_account log -----
            psLog.setInt(1, newUserId);  // user_id (the new rep)
            psLog.setInt(2, adminId);    // admin_id (who created them)
            psLog.setString(3, notes);   // optional notes
            psLog.executeUpdate();

            conn.commit();
            return newUserId;

        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }
}


    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY user_id";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> searchUsers(String query) {
        List<User> list = new ArrayList<>();
        String like = "%" + query + "%";
        String sql = "SELECT * FROM users WHERE username LIKE ? OR email LIKE ? ORDER BY user_id";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, like);
            ps.setString(2, like);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToUser(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Update profile fields + log each change into edit_account
    public void updateUserProfile(User newUser, int repId) {
        // Get current values
        User current = getUserById(newUser.getUserId());
        if (current == null) return;

        String updateSql = "UPDATE users SET username = ?, email = ?, phone = ?, address = ? WHERE user_id = ?";
        String insertEditSql =
                "INSERT INTO edit_account (rep_id, edited_user_id, field_changed, old_value, new_value) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            // UPDATE users
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newUser.getUsername());
                ps.setString(2, newUser.getEmail());
                ps.setString(3, newUser.getPhone());
                ps.setString(4, newUser.getAddress());
                ps.setInt(5, newUser.getUserId());
                ps.executeUpdate();
            }

            // INSERT logs
            try (PreparedStatement psLog = conn.prepareStatement(insertEditSql)) {

                // username
                if (!safeEquals(current.getUsername(), newUser.getUsername())) {
                    psLog.setInt(1, repId);
                    psLog.setInt(2, newUser.getUserId());
                    psLog.setString(3, "username");
                    psLog.setString(4, current.getUsername());
                    psLog.setString(5, newUser.getUsername());
                    psLog.addBatch();
                }
                // email
                if (!safeEquals(current.getEmail(), newUser.getEmail())) {
                    psLog.setInt(1, repId);
                    psLog.setInt(2, newUser.getUserId());
                    psLog.setString(3, "email");
                    psLog.setString(4, current.getEmail());
                    psLog.setString(5, newUser.getEmail());
                    psLog.addBatch();
                }
                // phone
                if (!safeEquals(current.getPhone(), newUser.getPhone())) {
                    psLog.setInt(1, repId);
                    psLog.setInt(2, newUser.getUserId());
                    psLog.setString(3, "phone");
                    psLog.setString(4, current.getPhone());
                    psLog.setString(5, newUser.getPhone());
                    psLog.addBatch();
                }
                // address
                if (!safeEquals(current.getAddress(), newUser.getAddress())) {
                    psLog.setInt(1, repId);
                    psLog.setInt(2, newUser.getUserId());
                    psLog.setString(3, "address");
                    psLog.setString(4, current.getAddress());
                    psLog.setString(5, newUser.getAddress());
                    psLog.addBatch();
                }

                psLog.executeBatch();
            }

            conn.commit();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateUserPassword(int userId, String newPasswordHash, int repId) {
        String getSql = "SELECT password_hash FROM users WHERE user_id = ?";
        String updateSql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        String insertEditSql =
                "INSERT INTO edit_account (rep_id, edited_user_id, field_changed, old_value, new_value) " +
                        "VALUES (?, ?, 'password', ?, ?)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            String oldHash = null;

            try (PreparedStatement psGet = conn.prepareStatement(getSql)) {
                psGet.setInt(1, userId);
                try (ResultSet rs = psGet.executeQuery()) {
                    if (rs.next()) {
                        oldHash = rs.getString("password_hash");
                    }
                }
            }

            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psUpdate.setString(1, newPasswordHash);
                psUpdate.setInt(2, userId);
                psUpdate.executeUpdate();
            }

            try (PreparedStatement psLog = conn.prepareStatement(insertEditSql)) {
                psLog.setInt(1, repId);
                psLog.setInt(2, userId);
                psLog.setString(3, oldHash);
                psLog.setString(4, newPasswordHash);
                psLog.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private User mapRowToUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setRole(rs.getString("role"));
        u.setJoinDate(rs.getTimestamp("join_date"));
        return u;
    }

    private boolean safeEquals(String a, String b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return a.equals(b);
    }
}
