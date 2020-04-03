#!/bin/bash

#+--------------+------------+------+-----+---------+----------------+
#| Field        | Type       | Null | Key | Default | Extra          |
#+--------------+------------+------+-----+---------+----------------+
#| serial       | int(11)    | NO   | PRI | NULL    | auto_increment |
#| devno        | int(11)    | YES  | MUL | NULL    |                |
#| pubIP        | char(15)   | YES  |     | NULL    |                |
#| pubNet       | char(18)   | YES  |     | NULL    |                |
#| privIP       | char(15)   | YES  |     | NULL    |                |
#| pivNet       | char(18)   | YES  |     | NULL    |                |
#| current      | tinyint(1) | NO   |     | 0       |                |
#| interface_no | tinyint(3) | NO   |     | 0       |                |
#+--------------+------------+------+-----+---------+----------------+

#config name,,,Private/Public,IP Address,NAT,Local
#436879-vmtms,spsseu,ipsos,Public ,5.79.13.193*,10.160.216.193,10.160.216.0/24
#438305-sqlc1n1,cortex,ipsos,Public ,5.79.32.160*,10.160.232.160,10.160.232.0/24
#438308-sqlc1n2,cortex,ipsos,Public ,5.79.32.161*,10.160.232.161,10.160.232.0/24
#438830-sqlc1i1,cortex,ipsos,Public ,5.79.32.162*,10.160.232.162,10.160.232.0/24

cat IPs_pubpriv.csv | awk -F ',' '
/^[0-9]/ {
	REGION=$3; 
	PUB=$5; 
	PRIV=$6;
	PRIVNET=$7
	split($1, aTMP, "-"); 
	GROUP=$2; 
	GROUPNO=gensub("[A-Za-z-]", "", "g", $2); 
	if (GROUPNO == "") {GROUPNO=0}; 
	print "INSERT INTO IP values (##," aTMP[1] ",#" PUB "#, ##,#" PRIV "#, #" PRIVNET "#,1,0);"
};' 

