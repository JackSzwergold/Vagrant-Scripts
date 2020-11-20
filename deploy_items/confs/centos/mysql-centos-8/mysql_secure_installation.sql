/* This script does the equivalent of 'mysql_secure_installation'. */

UPDATE mysql.user SET plugin='' WHERE User='root';
-- UPDATE mysql.user SET Password = PASSWORD('root') WHERE User = 'root';
-- UPDATE mysql.user SET Password = CONCAT('*', UPPER(SHA1(UNHEX(SHA1('root'))))) WHERE User = 'root';
-- ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
