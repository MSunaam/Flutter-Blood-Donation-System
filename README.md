# Blood Donation Management System

Blood Donation Management System that allows blood banks to link with hospitals and potential donors. Hospitals can easily find the appropriate blood bank for a specific patient and link with a compatible donor. Donors and patients can view all their history. Blood Banks have inventory management built in.

## Getting Started

To get started with this project, follow the instructions below.

### Prerequisites

Before running the project, make sure you have the following prerequisites installed:

- Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
- XAMPP server: [Download and Installation Guide](https://www.apachefriends.org/index.html)


### Installation

1. Clone the repository to your local machine using the following command:
   ```shell
   https://github.com/MSunaam/DataBaseProject.git

2. Navigate to the project's root directory:
    ```shell
    cd your-repo
3. Install the project dependencies by running the following command:
   ```shell
   flutter pub get
4. Set up the database:

- Install and configure XAMPP on your local machine.
- Start the XAMPP server and ensure that the MySQL service is running.
- Open a web browser and navigate to http://localhost/phpmyadmin.
- Create a new database for the project.

5. Import the database schema:

- Open phpMyAdmin
- Import the MySQL script file from the root directory of the project.
- This will create the necessary tables and structures in your database.

6. Edit the MySQL connection details:

- Open the ```dbSql.dart``` file located in the project's ```lib/sql/dbSql.dart``` directory.
- Locate the configuration section for the MySQL connection.
- Update the following values to match your MySQL server configuration:
  - username: Your MySQL username.
  - password: Your MySQL password.
  - host: The hostname or IP address where your MySQL server is running.
  - port: The port number used by your MySQL server.
  - dbName: The name of the database you created in step 4.

### Running the project

To run the Flutter project, use the following command:

  ```shell
  flutter run
  ```

This command will launch the application on a connected device or emulator.

### Building an APK (Android)

To build an APK file for Android, use the following command:

```shell
flutter build apk
```

This command will generate an APK file in the ```build/app/outputs/apk``` directory. You can install this APK on Android devices.

### Building an IPA (iOS)

To build an IPA file for iOS, use the following command:

```shell
flutter build ios
```

This command will generate an IPA file in the ```build/ios/archive``` directory. You can distribute this IPA through the App Store or install it on iOS devices using Xcode.

### Contributing
Contributions are welcome! If you have any suggestions, bug reports, or feature requests, please open an issue or submit a pull request.









