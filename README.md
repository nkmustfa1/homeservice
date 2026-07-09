# HomeService

HomeService is a mobile application developed with Flutter that connects clients with home service providers such as electricians, plumbers, cleaners, carpenters, painters, and more.

This repository contains:

- Flutter Mobile Application
- PHP Backend API
- MySQL Database

---

## Technologies Used

### Mobile
- Flutter
- Dart

### Backend
- PHP
- MySQL
- PHPMailer

### Database
- MySQL

---

## Project Structure

```
HomeService/
│
├── flutter_app/      # Flutter application
├── backend/          # PHP API
├── database/         # MySQL database
└── README.md
```

---

## Features

- User Authentication
- Email OTP Verification
- Password Reset
- Browse Service Categories
- View Service Providers
- Search Providers
- Book Home Services
- Notifications
- User Profile
- Reviews & Ratings
- Favorites
- Google Maps Integration

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/nkmustfa1/HomeService.git
```

---

### 2. Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

---

### 3. Backend

- Install XAMPP or any PHP server.
- Copy the backend folder into your server directory.
- Configure the database connection in:

```
backend/config/db_connect.php
```

- Configure SMTP credentials if email verification is required.

---

### 4. Database

Import:

```
database/homeservices.sql
```

using phpMyAdmin.

---

## Requirements

- Flutter SDK
- Dart SDK
- PHP 8+
- MySQL
- Composer
- XAMPP (or equivalent)

---

## Notes

SMTP credentials are intentionally omitted from this repository for security reasons.

Replace them with your own credentials before running the email verification feature.

---

## Author

Nada Mohammed Khalil

Graduation Project
Computer Science