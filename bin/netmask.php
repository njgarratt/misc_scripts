#!/usr/bin/php -q
<?php
#print_r($argv);
$sSuper		= $argv[1];
$iSubMask	= $argv[2];
#$aTmp		= split("/", $sSuper);
$aTmp		= explode("/", $sSuper);
$sNet		= $aTmp[0];
$iSuperMask	= $aTmp[1];

$sSubMaskBits		= '';
$sNotSubMaskBits	= '';
$sSuperMaskBits 	= '';
$sNotSuperMaskBits 	= '';

for ($i = 0; $i < 32; $i++) 
{
	if ($i <  $iSubMask)
	{
		$sSubMaskBits .= "1";
	} else
	{
		$sSubMaskBits .= "0";
		$sNotSubMaskBits	.= "1";
	};

	if ($i <  $iSuperMask)
	{
		$sSuperMaskBits .= "1";
	} else
	{
		$sSuperMaskBits .= "0";
		$sNotSuperMaskBits .= "1";
	};
}

$iSuperNet = IP2long($sNet) & bindec($sSuperMaskBits);
$iSubNet = IP2long($sNet) & bindec($sSubMaskBits);
$iIncrement	= bindec($sNotSubMaskBits);

echo "SuperNet: ". long2IP($iSuperNet) ."\n";
echo "SuperNet bits: $sSuperMaskBits Host: $sNotSuperMaskBits \n";
echo "SubNet bits: $sSubMaskBits Host: $sNotSubMaskBits \n";
echo "Subnet Hosts: ". (bindec($sNotSubMaskBits) - 1) ."\n";


for ($iBlock = bindec($sNotSuperMaskBits); $iBlock > 0; $iBlock -= ($iIncrement+1))
{
	#echo ">> $iBlock  - $iIncrement<<";
	$sSubNet	= long2IP($iSubNet & bindec($sSubMaskBits));
	$sBroadcast	= long2IP($iSubNet + $iIncrement);
	$sNetMask	= long2IP(bindec($sSubMaskBits));
	echo "$sSubNet,$sNetMask,$sBroadcast \n";
	$iSubNet	+= $iIncrement +1;
}
?>
