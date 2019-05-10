source .env
TODAY_DATE=$(date "+%Y-%m-%d")
BACKUP_DIRECTORY="./db_backup"

[ -d ${BACKUP_DIRECTORY} ] || mkdir -p ${BACKUP_DIRECTORY}
[ -f ${BACKUP_DIRECTORY}//all-database_${TODAY_DATE}.sql ] && rm -vrf ${BACKUP_DIRECTORY}/all-database_${TODAY_DATE}.sql

docker exec jumpserver-docker-compose_mysql_1 sh -c "exec mysqldump --all-databases -uroot -p${MYSQL_ROOT_PASSWORD}" > ${BACKUP_DIRECTORY}/all-database_${TODAY_DATE}.sql
