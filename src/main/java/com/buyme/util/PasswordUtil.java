package com.buyme.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordUtil {

    // SHA-256 hash → hex string
    public static String hashPassword(String password) {
        if (password == null) return null;

        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(password.getBytes(StandardCharsets.UTF_8));

            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }

    // Check a raw password against the stored hash
    public static boolean checkPassword(String rawPassword, String storedHash) {
        if (storedHash == null) return false;
        String hashed = hashPassword(rawPassword);
        return storedHash.equals(hashed);
    }
}
