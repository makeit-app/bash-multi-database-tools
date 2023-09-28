#!/bin/bash

clear

RED="\033[1;31m"
GREEN="\033[1;32m"
NC="\033[0m" # No Color

if [ $# -eq 0 ]; then
    echo
    printf "${RED}USAGE: ${0}  [single|tables]  [config_source]${NC}\n\n"
    echo "where:\n"
    echo "  single: dump into single file, restoreable via restore script"
    echo "  tables: dump into directory with per table file.\n"
    echo "  config_source : use configuration file with speciefic params"
    printf "                  in example '${RED}bk${NC}' will use ${GREEN}config_from_${RED}bk${NC}${GREEN}.cfg${NC} variables\n\n"
    exit 0
fi

if [ $# -eq 1 ]; then
    echo
    printf "    ${GREEN}USAGE: ${0}  [single|tables]${NC}  ${RED}[config_source]${NC}\n\n"
    echo "where:\n"
    echo "  single: dump into single file, restoreable via restore script"
    echo "  tables: dump into directory with per table file.\n"
    echo "  config_source : use configuration file with speciefic params"
    printf "                  in example '${RED}bk${NC}' will use ${GREEN}config_from_${RED}bk${NC}${GREEN}.cfg${NC} variables\n\n"
    exit 0
fi


MODE="single"
if [ "$1" = "tables" ]; then
    MODE="tables"
fi

if [ "$2" ]; then
    source config_from_${2}.cfg
else
    printf "${RED}NO SOURCE SPECIFIED${NC}\n"
    exit 0
fi

printf "CHECKING FOR ${GREEN}${HOST}${NC} PRESENCE:"
if ping -c 1 -W 1 "$HOST" > /dev/null; then
  printf " ${GREEN}ALIVE${NC}\n"
else
  printf " ${RED}NOT AVAILABLE${NC}\n"
  exit 1
fi

DIRECTORY_ROOT=./PGDUMP
DIRECTORY_DUMP=`date +%Y-%m-%d_%H%M`
DIRECTORY="${DIRECTORY_ROOT}/${BASE}-${DIRECTORY_DUMP}"
START=`date +%s`

printf "STARTED AT: ${GREEN}`date +%H:%M:%S`${NC}\nDumping database ${GREEN}${BASE}${NC} from ${GREEN}${HOST}${NC}\n"
if [ "$1" = "tables" ]; then
    echo "MODE: table files"
else
    echo "MODE: single file"
fi

if [ "$MODE" = "tables" ]; then
    echo "PLEASE WAIT ..."
    mkdir -p -m 2770 ${DIRECTORY}
    for table in $(PGPASSWORD=${PASS} psql -h ${HOST} -U ${USER} -d ${BASE} -t -c "${TABLES}"); do
        T1=`date +%s`
        printf "${GREEN}[`date +%H:%M:%S`]${NC} DUMPING ${table} ..."
        PGPASSWORD=${PASS} pg_dump -h ${HOST} -t ${table} -U ${USER} -Z 9 --inserts --no-owner  ${BASE} > ${DIRECTORY}/${table}.sql.gz;
        T2=`date +%s`
        printf " ${GREEN}`expr ${T2} - ${T1}` seconds.${NC}\n"
    done;
else
    mkdir -p -m 2770 ${DIRECTORY_ROOT}
    T1=`date +%s`
    printf "${GREEN}[`date +%H:%M:%S`]${NC} DUMPING, PLEASE WAIT ..."
    PGPASSWORD=${PASS} pg_dump -h ${HOST} -U ${USER} -Z 9 --inserts --no-owner --no-comments --no-privileges ${BASE} > ${DIRECTORY_ROOT}/${BASE}_${DIRECTORY_DUMP}.sql.gz;
    T2=`date +%s`
    printf " ${GREEN}`expr ${T2} - ${T1}` seconds.${NC}"
fi

printf "\n${GREEN}ALL DONE AT: `date +%H:%M:%S`\n"
STOP=`date +%s`
SPENT=`expr ${STOP} - ${START}`
if [ ${SPENT} -gt 59 ]; then
    MINUTES=`expr ${SPENT} / 60`
    echo "Spent ${MINUTES} minutes!"
else
    echo "Spent ${SPENT} seconds!"
fi;
printf "${NC}\n"

rm -f ${DIRECTORY_ROOT}/restore_db_to.sh
ln -frs ./restore_db_to.stub ${DIRECTORY_ROOT}/restore_db_to.sh
chmod 0770 ${DIRECTORY_ROOT}/restore_db_to.sh

echo
