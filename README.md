This is a management script I use for backups and map creation on my Minecraft game server

You'll need to run minecraft from a named screen session eg: screen -S minecraft

Your server will need to be running in a named window. You name a window by pressing: ^a,a (ctrl-a followed by a capitol A)

Your crontab should look like this:

@monthly /path/to/mcManage.sh full

@monthly /path/to/mcManage.sh clean

00 */2 * * * /path/to/mcManage.sh incremental
