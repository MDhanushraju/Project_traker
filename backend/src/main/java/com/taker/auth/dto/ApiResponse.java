package com.taker.auth.dto;

import com.taker.auth.exception.ErrorCode;

public class ApiResponse<T> {

    private int statusCode;
    private boolean success;
    private String message;
    private T data;
    /** Error code (e.g. auth.login_failed) so client knows exactly where it failed. */
    private String errorCode;
    /** Request path that failed (e.g. /api/auth/login). */
    private String path;

    public ApiResponse() {}

    public ApiResponse(int statusCode, boolean success, String message, T data) {
        this(statusCode, success, message, data, null, null);
    }

    public ApiResponse(int statusCode, boolean success, String message, T data, String errorCode, String path) {
        this.statusCode = statusCode;
        this.success = success;
        this.message = message;
        this.data = data;
        this.errorCode = errorCode;
        this.path = path;
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
        return new ApiResponse<>(statusCode, false, message, null, null, null);
    }

    public static <T> ApiResponse<T> failure(int statusCode, String message, T errors) {
        return new ApiResponse<>(statusCode, false, message, errors, null, null);
    }

    /** Failure with error code and path so client sees exactly where it failed. */
    public static <T> ApiResponse<T> failure(int statusCode, ErrorCode errorCode, String message, String path) {
        return new ApiResponse<>(statusCode, false, message, null,
                errorCode != null ? errorCode.getCode() : null, path);
    }

    public static <T> ApiResponse<T> failure(int statusCode, ErrorCode errorCode, String message, String path, T errors) {
        return new ApiResponse<>(statusCode, false, message, errors,
                errorCode != null ? errorCode.getCode() : null, path);
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
    public String getErrorCode() { return errorCode; }
    public void setErrorCode(String errorCode) { this.errorCode = errorCode; }
    public String getPath() { return path; }
    public void setPath(String path) { this.path = path; }
}
