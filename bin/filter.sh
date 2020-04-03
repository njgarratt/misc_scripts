#!/bin/bash
cat $1 \
| sed -n '/CORE SKU:/,/\(^--$\)\|\(^Link\)/p; s/^Link.*$/-----/p; /\(Hostname:\)\|\(Device:\)\|\(Platform:\)\|\(Type:\)\|\(OS Version:\)\|\(PrimaryIP:\)\|\(Interface\)\|\(^Switch\)\|\(^Port:\)/p;'
