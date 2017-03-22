<?php

echo $_SERVER['SERVER_NAME'];
echo '<br />';
echo $_SERVER['SERVER_ADDR'];
echo '<br />';
phpinfo();

# Test to ensure that the server is creating files with correct permissions.
# touch('zzz_test.txt');

?>
