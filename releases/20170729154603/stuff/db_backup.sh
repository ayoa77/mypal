NOW=$(date +"%F")
DBFILE="db-$NOW.sql"
find ~/db-backups/* -mtime +30 -exec rm {} \;
cd ~/db-backups && mysqldump -u blnkk -ppassword blnkk > $DBFILE && rm -f last.sql && cp $DBFILE last.sql