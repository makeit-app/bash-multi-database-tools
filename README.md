# DEV DB TOOLS

bash scripts for dump and restore multiple database sources (PostgreSQL ONLY!)

### DUMP

```bash
./dump_db_from.sh [single|tables] [config_source]
```
Where:
- single: single dump file, ! Attention, ONLY this file will be used on automatic restoration!
- tables: one table -- one file, seems it is detailed dump =)
- config_source: which config with connection params to use, - determines where to dump from.

### RESTORE
```bash
cd ./PGDUMP
./restore_db_to.sh [filname.sql.gz] [config_source]
```
Where:
- filname.sql.gz : GZIPPED (!) file with database dump
- config_source: which config with connection params to use, - determines where to restore the database.

## LICENSE MIT

## CONTRIBUTING
Summon me =)
