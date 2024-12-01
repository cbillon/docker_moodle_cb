
CREATE DATABASE moodle CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'admin'@'%' IDENTIFIED WITH mysql_native_password BY 'Se$ame';
GRANT ALL ON moodle.* TO 'admin'@'%';

/* Make sure the privileges are installed */
FLUSH PRIVILEGES;


