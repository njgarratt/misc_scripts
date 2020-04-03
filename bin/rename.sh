#!/bin/bash
cat 26836.csv | cut --output-delimiter=" " -d',' -f1,2  | while read DEVNO DEVNAME;  do DEVNAME=`echo  $DEVNAME | sed 's/"//g' `; cat Genworth-LON-cab-layout.xml | sed "/#26836-/s/#26836-${DEVNO}/${DEVNAME} (#26836)/" > Genworth-LON-cab-layout.xml.SED;  mv Genworth-LON-cab-layout.xml.SED Genworth-LON-cab-layout.xml; done
