#!/bin/bash
# Create sql folder
mkdir -p ./sql/

# Append this SQL code to the file sql/init_db.sql
echo "
CREATE DATABASE "$1" CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '"$2"'@'%' IDENTIFIED WITH mysql_native_password BY '"$3"';
GRANT ALL ON "$1".* TO '"$2"'@'%';

/* Make sure the privileges are installed */
FLUSH PRIVILEGES;

" >> sql/init_db.sql