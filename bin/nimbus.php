#!/usr/bin/php -q
<?php
/*
	Flatten the Nimbus config XML into a CSV
*/

$file	= $_SERVER['argv'][1];
$oXML	= new SimpleXMLElement($file, NULL, TRUE);


function iterateXML(&$oParent, $sName="")
{

	static $aName = array();
	array_push($aName, $sName);
	$sNamePath	= implode(',', $aName);

	foreach ($oParent->attributes() as $sIndex => $sValue)
	{
		echo "$sNamePath : $sValue\n";
	}

	foreach ($oParent->children() as $sName => $oChild)
	{
		if (is_object($oChild))
		{
			iterateXML($oChild, $sName);
		} else 
		{
			echo typeof($oChild);
			while (list($sIndex, $sValue) = each($oChild))
			{
				echo "$sIndex -> $sValue\n";
			}
		}
	}
	$sName	= array_pop($aName);
}

/*
$oXpath	= $oXML->xpath('//cpu');
$oXpath	= $oXML->xpath('//memory');
$oXpath	= $oXML->xpath('//disk');

while (list(,$node) = each($oXpath))
{
	print_r($node);
}
*/
//print_r($oXML);

iterateXML($oXML, $file);

?>
