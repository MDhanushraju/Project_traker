package com.taker.auth.dto;

public class ApiResponse<T> {

    private int statusCode;
    private boolean success;
    private String message;
    private T data;

    public ApiResponse() {}

    public ApiResponse(int statusCode, boolean success, String message, T data) {
        this.statusCode = statusCode;
        this.success = success;
        this.message = message;
        this.data = data;
    }

    public static <T> ApiResponse<T> success(int statusCode, String message, T data) {
        return new ApiResponse<>(statusCode, true, message, data);
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return success(200, message, data);
    }

    public static <T> ApiResponse<T> success(String message) {
        return success(200, message, null);
    }

    public static <T> ApiResponse<T> failure(int statusCode, String message) {
        return new ApiResponse<>(statusCode, false, message, null);
    }

    public static <T> ApiResponse<T> failure(int statusCode, String message, T errors) {
        return new ApiResponse<>(statusCode, false, message, errors);
    }

    public static <T> ApiResponse<T> failure(String message) {
        return failure(400, message);
    }

    public static <T> ApiResponse<T> failure(String message, T errors) {
        return failure(400, message, errors);
    }

    public int getStatusCode() { return statusCode; }
    public void setStatusCode(int statusCode) { this.statusCode = statusCode; }
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public T getData() { return data; }
    public void setData(T data) { this.data = data; }
}
