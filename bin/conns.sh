#!/bin/bash
grep -v icmp  conns | sed '/^1\?[0-9]   /d'  | sort -k2,2 -k7,8 -k3,3 | awk 'BEGIN {OACL=""; OPROTO=""; ODIP=""; ODPT=""; IPS=""}; /^[0-9]/ {ACL=$2; PROTO=$3; DIP=$8; DPT=$9; if (PROTO != OPROTO || DIP != ODIP || ODPT != DPT) {print "ACL " OACL " permit: \n" IPS "\ndestination: " ODIP " " OPROTO " " ODPT; OACL=ACL; OPROTO=PROTO; ODIP=DIP; ODPT=DPT; IPS=$5   } else { IPS = IPS "\n" $5}};' 