# Test login credentials

Use these in the **Login** screen to verify the app.

| Field | Value | Notes |
|-------|--------|--------|
| **Email** | `mdhanushraju03@gmail.com` | Required |
| **Password** | `Dhanush@03` | Required |
| **ID Card Number** | `2003` | Optional – only use if you set this when you signed up. Leave blank otherwise. |

- **User / display name:** dhanu (for reference; not a login field – the app uses email + password to log in).

**How to test**

1. Open the app and go to the Login screen (after choosing a role if your app has a role selection step).
2. Enter **Email:** `mdhanushraju03@gmail.com`
3. Enter **Password:** `Dhanush@03`
4. **ID Card:**  
   - If you signed up with ID card `2003`, enter `2003`.  
   - If you did not set an ID card at signup, leave it blank.
5. Tap **Log In**.

If the account exists (created via Sign up) with that email and password (and ID card if you use it), you should be logged in and taken to the dashboard. If you see “Invalid email or password” or “Invalid email or ID Card Number”, either the account does not exist yet (sign up first) or the ID card does not match the one used at signup (try leaving ID card blank).
