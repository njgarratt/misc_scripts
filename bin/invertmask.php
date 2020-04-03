#!/usr/bin/php -q

<?php

$invmask = long2ip(~ip2long($argv[2]));
echo $argv[1] .'	'. $invmask ."\n";

?>
