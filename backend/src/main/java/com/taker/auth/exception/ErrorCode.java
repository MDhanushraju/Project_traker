package com.taker.auth.exception;

/**
 * Error codes to identify exactly where a request failed.
 * Use in API error responses so clients can show clean messages and know the failure location.
 */
public enum ErrorCode {

    // Auth
    AUTH_LOGIN_FAILED("auth.login_failed", "Login failed. Check email and password."),
    AUTH_SIGNUP_FAILED("auth.signup_failed", "Sign up failed."),
    AUTH_SIGNUP_EMAIL_EXISTS("auth.signup_email_exists", "Email already registered."),
    AUTH_SIGNUP_VALIDATION("auth.signup_validation", "Invalid signup data."),
    AUTH_LOGIN_WITH_ROLE_FAILED("auth.login_with_role_failed", "No user found for the given role."),
    AUTH_FORGOT_PASSWORD("auth.forgot_password", "Forgot password request failed."),
    AUTH_VERIFY_CAPTCHA("auth.verify_captcha", "Captcha verification failed."),
    AUTH_RESET_PASSWORD("auth.reset_password", "Password reset failed."),
    AUTH_UNAUTHORIZED("auth.unauthorized", "Not authorized."),

    // Validation
    VALIDATION_FAILED("validation.failed", "Validation failed. Check the fields."),
    VALIDATION_REQUEST_BODY("validation.request_body", "Invalid request body. Check JSON format and required fields."),
    WRONG_PATH("validation.wrong_path", "Wrong API path. Check the URL."),

    // Data / integrity
    DATA_EMAIL_EXISTS("data.email_exists", "Email already registered."),
    DATA_INVALID("data.invalid", "Invalid data. Please check your input."),

    // Forbidden
    FORBIDDEN("forbidden", "You are not allowed to perform this action."),

    // Not found
    USER_NOT_FOUND("user.not_found", "User not found."),
    TASK_NOT_FOUND("task.not_found", "Task not found."),
    PROJECT_NOT_FOUND("project.not_found", "Project not found."),

    // Generic
    INTERNAL_ERROR("internal.error", "An unexpected error occurred. Please try again.");

    private final String code;
    private final String defaultMessage;

    ErrorCode(String code, String defaultMessage) {
        this.code = code;
        this.defaultMessage = defaultMessage;
    }

    public String getCode() {
        return code;
    }

    public String getDefaultMessage() {
        return defaultMessage;
    }
}
