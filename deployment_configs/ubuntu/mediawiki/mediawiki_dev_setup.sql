/* NOT FOR PRODUCTION! */
/* This is intended for local development setup purposes only since the password is 'password'. */

CREATE DATABASE `mediawiki`;
CREATE USER 'mediawiki'@'localhost' IDENTIFIED BY 'password';
GRANT USAGE ON `mediawiki`.* TO 'mediawiki'@'localhost' IDENTIFIED BY 'mediawiki';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `mediawiki`.* TO 'mediawiki'@'localhost';
SET PASSWORD FOR 'mediawiki'@'localhost' = PASSWORD('password');
FLUSH PRIVILEGES;
