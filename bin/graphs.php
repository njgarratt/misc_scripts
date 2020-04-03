#!/usr/bin/php
<?php
$sDB		='Genworth_Net';
$sDBUser	= 'genuser';
$sDBHost	= 'localhost';
$sDBPass	= 'S@ND@t@';
$sRRDBase	= '/home/nick/Documents/Customers/Genworth/Reporting/RRDB';

$aRRDopt		= array('--start', '1000000000', '--step', '8100',
			'DS:Response_ms:GAUGE:10000:0:10000',
			'DS:Read_IOPS:GAUGE:10000:0:2000',
			'DS:Write_IOPS:GAUGE:10000:0:2000',
			'DS:Utilization:GAUGE:10000:0:100',
			'RRA:AVERAGE:0.9:1:700',
			'RRA:MAX:0.9:10:365'
			);

$aLUNs		= array();

if (!$rDB = mysql_connect($sDBHost, $sDBUser, $sDBPass))
{
	echo 'Unable to connect to the DB: '. mysql_error();
	exit(1);
}

if (!mysql_select_db($sDB, $rDB))
{
	echo 'Unable to select DB: '. mysql_error();
}

$sSQL = 'select LUNno, LUN_name from LUNs where status = 1';
if (!$rLUNs = mysql_query($sSQL, $rDB))
{
	echo 'No LUNs to speak of: '. mysql_error();
	exit(1);
}

while ($aLUN = mysql_fetch_array($rLUNs, MYSQL_ASSOC))
{
	$aLUNs[$aLUN['LUNno']] = $aLUN['LUN_name'];
}

mysql_free_result($rLUNs);

while (list($iLUN, $sLUN) = each($aLUNs))
{
	$sRRDB	= $sRRDBase .'/'. $sLUN;
	if (file_exists($sRRDB))
	{
		unlink($sRRDB);
	}

	if (!$eRRD = rrd_create($sRRDB, $aRRDopt, count($aRRDopt)))
	{
		echo 'Unable to create RRDB '. $sRRDB .': '. rrd_error();
	}

	$aCounters	=	array();
	$sSQL = 'select unix_timestamp(tstamp) as utstamp, counter, value from LUN_counters where LUNno = '. $iLUN .' order by tstamp';

	if (!$rCNT = mysql_query($sSQL, $rDB))
	{
		echo 'Unable to query DB: '. mysql_error();
	}

	while ($aCNT = mysql_fetch_array($rCNT, MYSQL_ASSOC))
	{
		$aCounters[$aCNT['utstamp']][$aCNT['counter']]	= $aCNT['value'];
	}

	while (list($iTstamp, $aCNT) = each($aCounters))
	{
		$sLINE	= $iTstamp .':'. $aCNT['Response_ms'] .':'. $aCNT['Read_IOPS'] .':'. $aCNT['Write_IOPS'] .':'. $aCNT['Utilization'];
		if (!rrd_update($sRRDB, $sLINE))
		{
			echo 'Unable to insert:'. $sLINE .': '. rrd_error() ."\n";
		}
	}

	mysql_free_result($rCNT);
	$aGraphOpts = array( 
		"--start", "-3m", "--end", "-1m", "--vertical-label=Read/Write IO/s",
		'-w', '800', '-h', '300',
		'-t', $sLUN,
		'--right-axis', '1:0', '--right-axis-label', 'Response milliseconds',
		"DEF:read_iops=$sRRDB:Read_IOPS:AVERAGE",
		"DEF:write_iops=$sRRDB:Write_IOPS:AVERAGE",
		"DEF:response=$sRRDB:Response_ms:AVERAGE",
		"LINE1:read_iops#00FF00:Read IO/s",
		"LINE1:write_iops#0000FF:Write IO/s",
		"LINE1:response#00FFFF:Response ms\\r",
		"COMMENT:\\n",
		"GPRINT:read_iops:AVERAGE:Avg Read \: %6.3lf IO/s",
		"COMMENT:  ",
		"GPRINT:read_iops:MAX:Max Read \: %6.3lf IO/s\\r",
		"GPRINT:write_iops:AVERAGE:Avg Write \: %6.3lf IO/s",
		"COMMENT: ",
		"GPRINT:write_iops:MAX:Max Write \: %6.3lf IO/s\\r",
		"GPRINT:response:AVERAGE:Avg Response \: %6.3lf ms",
		"COMMENT: ",
		"GPRINT:response:MAX:Max Response \: %6.3lf ms\\r"
	);
	  if (!rrd_graph("$sRRDB.png", $aGraphOpts, count($aGraphOpts)))
	  {
	  	echo 'Unable to generate graph: '. rrd_error() ."\n";
	  };

}

?>
