class ApiConstants {
  static const String baseUrl = "http://10.0.2.2/HomeServices";

  static const String login = "$baseUrl/login.php";
  static const String signup = "$baseUrl/signup.php";
  static const String sendOtp = "$baseUrl/send_otp.php";
  static const String checkEmail = "$baseUrl/check_email.php";
  static const String getNotifications = "$baseUrl/get_notifications.php";

  static const String fetchAppNotifications =
      "$baseUrl/fetch_app_notifications.php";

  static const String respondNotification = "$baseUrl/respond_notification.php";
  static const resetPassword = "$baseUrl/reset_password.php";
  static const verifyOtp = "$baseUrl/verify_otp_email.php";
}
