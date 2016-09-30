#!/bin/bash

for f in *.shp
do
    shp2pgsql -I -s 26918 $f `basename $f .shp` > `basename $f .shp`.sql
done

for f in *.sql
do
    psql -d nyc -f $f
done
