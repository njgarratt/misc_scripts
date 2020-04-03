#!/usr/bin/php
<?php
require_once './FileArgs.inc';
require_once './FileParser.inc';
require_once './CounterDBtwo.inc';

$DEBUG		= FALSE;
$aFiles		= array();
$aDirs		= array();
$aOpts		= array();

if ($argv <= 1)
{
	echo "Error: directory or file path required\n";
	usage();
	exit(1);
}

function usage()
{
	echo "Usage: ". $argv[0] ." [-v] [-f .csv] file/dir file/dir ...\n";
}

function parseArgv(&$aArgv)
{
	global $DEBUG, $aFiles, $aDirs, $sFilter; 
	for ($i = 1; $i < count($aArgv); $i++)
	{
		$sArg	= $aArgv[$i];

		switch ($sArg)
		{
			case '-v': $DEBUG	= TRUE;
				break;
			case '-f':
				if (preg_match('/^\.[a-z0-9]+$/', $aArgv[++$i], $aRes))
				{
					$sFilter	= $aRes[0];
					echo "Filter: $sFilter\n";
				}
				break;
			default:
				if (is_dir($sArg))
				{
					$aDirs[]		= $sArg;
				} else if (is_file($sArg))
				{
					$aFiles[]		= $sArg;
				}
				break;
		}
	}
	if (!count($aFiles) && !count($aDirs))
	{
		// we have nothing to process
		return FALSE;
	} else 
	{
		return TRUE;
	}
}

if (parseArgv($argv))
{
	$oFArgs	= new FileArgs($aFiles, $aDirs, $sFilter);
	$oCounterDB	= new CounterDB();
	
	foreach ($oFArgs as $iFileNo => $sFile)
	{
		fwrite(STDOUT, "processing file ". $sFile ."\n");
		
		$oFile	= FileParser::factory($sFile, 'csv', $aOpts);
		foreach ($oFile as $iLine => $aRecord)
		{
			//fwrite(STDOUT, $iLine ."\n");
			//print_r($aRecord);
			$oCounterDB->insertCounterRec($aRecord);
		}
		
	}
} else 
{
	usage();
}

?>
