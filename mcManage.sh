#!/bin/bash
# Minecraft AutoBackup
NOW=$(date +"%Y%m%d%H%M")

#Minecraft Home Directory
HOME='/home/user/mc/'

#Backup Directory
BACKUPDIR='/home/user/backups/mc/'

#Screen session name
SCREENSESSION='minecraft'

#Window name in screen
SCREENWINDOW='smp'

####
# Uncomment the following line if you use Tectonicus.
# This gets first active X Display. If you don't have X,
# uncommenting this will cause problem.
####
#export DISPLAY=:`ls /tmp/.X11-unix/X* | cut -b17`

do_incremental() {
if [ -e ${HOME}server.log.lck ] #check if server is running
then #Inform players that backup started
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "say ###Backup - Started###"`echo -ne '\015'`
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "save-off"`echo -ne '\015'`
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "save-all"`echo -ne '\015'`
   sleep 5
   tar -cjf ${BACKUPDIR}${NOW}.tgz --listed-incremental=${BACKUPDIR}`date +%Y%m`.snp -C ${HOME} .
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "save-on"`echo -ne '\015'`
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "say ###Backup - Complete###"`echo -ne '\015'`
   return 0
else
   return 1
fi

}

do_map() {
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "say ###Map - Generating###"`echo -ne '\015'`
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "save-off"`echo -ne '\015'`
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "save-all"`echo -ne '\015'`
   rm -rf /var/www/map/*
   #/usr/bin/python2.7 ~/Minecraft-Overviewer/overviewer.py ~/mc/Durance /var/www/map
   java -Xmx4096M -jar /home/user/tectonicus/Tectonicus_v2.14.jar config=/home/user/tectonicus/config.xml
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "save-on"`echo -ne '\015'`
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "say ###Map - Complete###"`echo -ne '\015'`
}

do_full() {
if [ -e ${HOME}server.log.lck ] #check if server is running
then #Inform players that backup started
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "say ###Backup - Started###"`echo -ne '\015'`
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "save-off"`echo -ne '\015'`
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "save-all"`echo -ne '\015'`
   sleep 5
   tar -cjf ${BACKUPDIR}`date +%Y%m`-level0.tgz --listed-incremental=${BACKUPDIR}`date +%Y%m`.snp --level=0 -C ${HOME} .
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "save-on"`echo -ne '\015'`
   screen -S ${SCREENSESSION} -p ${SCREENWINDOW} -X stuff "say ###Backup - Complete###"`echo -ne '\015'`
   return 0
else
   return 1
fi
return 1
}

do_clean ()
{
   #find /home/user/backups/mc -mmin +2880 -exec rm {} \; #remove backups older than 2days
   /bin/rm ${BACKUPDIR}`date --date="3 months ago" +"%Y%m"`*
}

case $1 in
	"full")
	do_full
	;;
	"incremental")
	DOM=`date +"%d"`
	HOUR=`date +"%H"`
	if [ $DOM -eq 01 ] && [ $HOUR -eq 00 ]; then
		exit 0
	else
		do_incremental
	fi
	;;
	"map")
	do_map
	;;
	"clean")
	do_clean
	;;
esac
