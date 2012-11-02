#!/bin/bash
# Minecraft AutoBackup
NOW=$(date +"%Y%m%d%H%M")
#Minecraft Home Directory
HOME='/home/user/mc/'
#Backup Directory
BACKUPDIR='/home/user/backups/mc/'
#Tectonicus needs this. Gets first active X Display. I use dynmap now
export DISPLAY=:`ls /tmp/.X11-unix/X* | cut -b17`

do_bihourly() {
if [ -e ${HOME}server.log.lck ] #check if server is running
then #Inform players that backup started
   screen -S minecraft -p smp -X stuff "say ###Backup - Started###"`echo -ne '\015'`
   screen -S minecraft -p smp -X stuff "save-off"`echo -ne '\015'`
   screen -S minecraft -p smp -X stuff "save-all"`echo -ne '\015'`
   sleep 5
   tar -cjf ${BACKUPDIR}${NOW}.tgz --listed-incremental=${BACKUPDIR}`date +%Y%m`.snp -C ${HOME} .
   screen -S minecraft -p smp -X stuff "save-on"`echo -ne '\015'`
   screen -S minecraft -p smp -X stuff "say ###Backup - Complete###"`echo -ne '\015'`
   return 0
else
   return 1
fi

}

do_map() {
   screen -S minecraft -p smp -X stuff "say ###Map - Generating###"`echo -ne '\015'`
   screen -S minecraft -p smp -X stuff "save-off"`echo -ne '\015'`
   screen -S minecraft -p smp -X stuff "save-all"`echo -ne '\015'`
   rm -rf /var/www/map/*
   #/usr/bin/python2.7 ~/Minecraft-Overviewer/overviewer.py ~/mc/Durance /var/www/map
   java -Xmx4096M -jar /home/user/tectonicus/Tectonicus_v2.14.jar config=/home/user/tectonicus/config.xml
   screen -S minecraft -p smp -X stuff "save-on"`echo -ne '\015'`
   screen -S minecraft -p smp -X stuff "say ###Map - Complete###"`echo -ne '\015'`
}

do_monthly() {
if [ -e ${HOME}server.log.lck ] #check if server is running
then #Inform players that backup started
   screen -S minecraft -p smp -X stuff "say ###Backup - Started###"`echo -ne '\015'`
   screen -S minecraft -p smp -X stuff "save-off"`echo -ne '\015'`
   screen -S minecraft -p smp -X stuff "save-all"`echo -ne '\015'`
   sleep 5
   tar -cjf ${BACKUPDIR}`date +%Y%m`-level0.tgz --listed-incremental=${BACKUPDIR}`date +%Y%m`.snp --level=0 -C ${HOME} .
   screen -S minecraft -p smp -X stuff "save-on"`echo -ne '\015'`
   screen -S minecraft -p smp -X stuff "say ###Backup - Complete###"`echo -ne '\015'`
   return 0
else
   return 1
fi
return 1
}

#clean ()
#{
   #find /home/user/backups/mc -mmin +2880 -exec rm {} \; #remove backups older than 2days
#}

case $1 in
	"monthly")
	do_monthly
	;;
	"bihourly")
	DOM=`date +"%d"`
	HOUR=`date +"%H"`
	if (( ("$DOM" == "01") && ("$HOUR" == "00") )); then
		exit 0
	else
		do_bihourly
	fi
	;;
	"map")
	do_map
	;;
esac
