for %%f in (*.shp) do shp2pgsql -I -s 26918 %%f %%~nf > %%~nf.sql
for %%f in (*.sql) do psql -d nyc -f %%f
