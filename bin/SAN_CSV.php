#!/usr/bin/php -q
<?php

$oNAR = simplexml_load_file('./example.xml', 'SimpleXMLElement',  LIBXML_DTDLOAD |  LIBXML_DTDATTR |  LIBXML_XINCLUDE );
print_r($oNAR);

?>
