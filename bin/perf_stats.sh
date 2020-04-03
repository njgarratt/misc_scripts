#!/bin/bash

cat | awk -F',' '
/^[0-9]+/ {print "INSERT INTO perf_counters values (#", $1 "#,#" $3 "-" $4 "#, str_to_date(#" $6 "#,#%Y-%m-%d %T#), #" $2 "#, #" $5 "#);" >> "perf_counters.sql"; print "REPLACE INTO perf_objects (objectname, countername) VALUES (#" $3 "#,#" $4 "#);" >> "perf_objects.sql"};' 

#select h.hostname, c.tstamp, o.objectname, o.countername, hour(c.tstamp) as ToD, c.value, (100-(c.value/(i.RAM*1024)*100)) as perc from host as h join perf_counters as c on (h.devno = c.devno) join perf_objects as o on (c.counterno = o.counterno) join hinv as i on (i.devno = h.devno) where o.counterno = 2

# select h.hostname, o.objectname, o.countername, hour(c.tstamp) as ToD, avg((c.value/(i.RAM*1024)*100)) as average, std((c.value/(i.RAM*1024)*100)) as std_deviation, max((c.value/(i.RAM*1024)*100)) as max from host as h join perf_counters as c on (h.devno = c.devno) join perf_objects as o on (c.counterno = o.counterno) join hinv as i on (i.devno = h.devno) where o.counterno = 2 group by h.hostname, o.countername, ToD;

#select h.hostname, o.objectname, o.countername, hour(c.tstamp) as ToD, avg(c.value) as average, std(c.value) as std_deviation, max(c.value) as max from host as h join perf_counters as c on (h.devno = c.devno) join perf_objects as o on (c.counterno = o.counterno) where c.counterno !=3 group by h.devno, o.counterno,ToD;
