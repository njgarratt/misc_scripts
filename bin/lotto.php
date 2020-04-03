#!/usr/bin/php -q
<?php

switch ($argv[1])
{
	case "-e": 
		$mcount	= 5;
		$ecount	= 2;
		$mupper	= 50;
		break;
	case "-l":
		$mcount	= 6;
		$ecount	= 0;
		$mupper	= 49;
		break;
	default:
		usage();
		break;
}

function usage()
{
	echo "usage:\n -l (lotto) or \n -e (euro)\n";
	exit(1);
}

echo "Main:\n";
for ($i = 1; $i <= $mcount; $i++) {echo mt_rand(1,$mupper) ."\n";}; 

echo "\nExtra:\n";
for ($i = 1; $i <= $ecount; $i++) {echo mt_rand(1,11) ."\n";};

?>
