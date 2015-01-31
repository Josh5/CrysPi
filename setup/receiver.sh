#!/bin/bash

###INFORMATION:
#
#   Author: Josh Sunnex
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
###END INFORMATION

##### <--- Start Script ---> #####
if [ "$(id -u)" != "0" ]; then
  echo
  echo "  ----------------------------- !! NOTE !! ------------------------------"
  echo "        You don't have sufficient privileges to run this script.         "  
  echo "        Ensure you type 'sudo' first!                                    "  
  echo '        Execute the script using the command: "sudo ./setup.sh"                                ' 
  echo "  -----------------------------------------------------------------------"
  echo
  exit 1
fi

clear

echo '
##############################################################################
#
#   Author: Josh Sunnex
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
##############################################################################
 '
echo "  -------------------------------------------------------------------------  "
echo "                        Installation will start soon.                        "
echo "            Please take a moment to read the following carefully:            "
echo "  -------------------------------------------------------------------------  "
echo
echo ' #1:  This installation is confirmed to work on Raspbian and Ubuntu is intended 
      for use following instructions distributed with this release.'
echo
echo ' #2:  While several testing runs identified no known issues, the author cannot 
      be held accountable for any problems that might occur due to the script.'
echo
echo ' #3:  By running this script you agree that the author is not liable for any problems that you occur.'
echo
echo ' #4:  A number of packages will be installed automatically on your system.
      These packages are required in order for this system to run.'
echo
echo
echo
echo ' You must AGREE with the above conditions in order to continue with the installation.'
read -p ' Do you agree (y/n): '
RESP=${REPLY,,}
if [ "$RESP" != "y" ]
then
  echo
  echo "  -----------------------------------------------------------------------"
  echo "     Script Aborted. I can not let you run my script without agreeing!   "
  echo "  -----------------------------------------------------------------------"
  echo
	exit 0
fi
clear
CWD=$PWD

#<--- Update Packages:
echo "------------------------"
echo "---> Updating Packages:"
echo "------------------------"
sudo apt-get update
sudo apt-get install -y --reinstall bash-completion
echo

echo "--------------------------------------------"
echo "---> Setting up CrysPi Audio receiver share:"
echo "--------------------------------------------"
echo
sleep 2
echo "[+]   Installing Netcat:"
sudo apt-get install -y netcat
echo
if [ ! -f ./listen ]; then
echo "[+]   Installing listen script:"
sudo tee -a ./listen <<"EOF"
#!/bin/bash
pipeDIR="/var/www/cryspi/"
pipe=$pipeDIR"stream.mp3"
streamIP="192.168.1.1"

if [[ ! -p $pipe ]]; then
    mkdir -p $pipeDIR
    mkfifo $pipe
fi

while true
do
    echo "Press and hold [CTRL+C] to stop.."

    netcat -v $streamIP 5000 > $pipe # Save stream to local pipe
    # netcat -v $streamIP 5000 >> $pipe $pipe2 # Attempt to pipe stream twice
    # netcat -v $streamIP 5000 | aplay # Stream
done
EOF
fi

mkdir -p /opt/cryspi
sudo cp ./listen /opt/cryspi/listen
sudo chmod +x /opt/cryspi/listen


if [ ! -f /etc/init.d/listencryspi ]; then
echo "[+]   Start listen script on boot:"
sudo tee -a /etc/init.d/listencryspi <<"EOF"
#!/bin/sh
### BEGIN INIT INFO
# Provides:          listencryspi
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $network $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Netcat to pipe
# Description:       Pipe netcat stream to temp pipe.
### END INIT INFO

# Author: Josh.5

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Netcat pipe"
NAME=listencryspi
DAEMON=/opt/cryspi/listen
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

[ -x $DAEMON ] || exit 0

. /lib/init/vars.sh
. /lib/lsb/init-functions



case $1 in
	start)
		log_daemon_msg "Starting $DESC " "$NAME"
		start-stop-daemon --start --background --quiet --pidfile $PIDFILE --make-pidfile --exec $DAEMON
		status=$?
		log_end_msg $status
		;;
	stop)
		log_daemon_msg "Stopping $DESC" "$NAME"
		start-stop-daemon --stop --quiet --pidfile $PIDFILE
		status=$?
		log_end_msg $status
		rm -f $PIDFILE
		;;
	restart|force-reload)
		$0 stop && sleep 2 && $0 start
		;;
	status)
		status_of_proc "$DAEMON" "$NAME"
		;;
	*)
		echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload|status}"
		exit 2
		;;
esac
EOF
fi


if [ ! -f /etc/init.d/playaudio ]; then
echo "[+]   Start listen script on boot:"
sudo tee -a /etc/init.d/playaudio <<"EOF"
#!/bin/sh
### BEGIN INIT INFO
# Provides:          playaudio
# Required-Start:    $network $local_fs $remote_fs listencryspi
# Required-Stop:     $network $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Play Stream
# Description:       Output netcat stream to default playback device via aplay.
### END INIT INFO

# Author: Josh.5

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Play Stream"
NAME=playaudio
DAEMON=aplay /var/www/cryspi/stream.mp3
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

[ -x $DAEMON ] || exit 0

. /lib/init/vars.sh
. /lib/lsb/init-functions



case $1 in
	start)
		log_daemon_msg "Starting $DESC " "$NAME"
		start-stop-daemon --start --background --quiet --pidfile $PIDFILE --make-pidfile --exec $DAEMON
		status=$?
		log_end_msg $status
		;;
	stop)
		log_daemon_msg "Stopping $DESC" "$NAME"
		start-stop-daemon --stop --quiet --pidfile $PIDFILE
		status=$?
		log_end_msg $status
		rm -f $PIDFILE
		;;
	restart|force-reload)
		$0 stop && sleep 2 && $0 start
		;;
	status)
		status_of_proc "$DAEMON" "$NAME"
		;;
	*)
		echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload|status}"
		exit 2
		;;
esac
EOF
  sudo chmod +x /opt/cryspi/listen
  sudo chmod +x /etc/init.d/listencryspi
  sudo chmod +x /etc/init.d/playaudio
  sudo update-rc.d listencryspi defaults
  sudo update-rc.d playaudio defaults
fi


echo
echo "---------------------------------"
echo '---> All done! Install complete.'
echo "---------------------------------"
echo
echo "-------------------------!IMPORTANT!-----------------------------"
echo "|            SETTINGS WILL TAKE EFFECT ON NEXT BOOT.            "
echo "|                                                               |"
echo "                 Update the settings before use.                |"
echo "-----------------------------------------------------------------"
echo
echo '  Thank you for using this installer script.'
sleep 2
echo


while true
do
	read -p "  Would you like to restart your system now? (y:n)" CHOICE
	case "$CHOICE" in 
  y|Y ) echo "  Restarting now..."; sudo reboot; break;;
  n|N ) echo; echo "------------------------------------------"; echo "   Remember to restart your before use.   "; echo "------------------------------------------"; echo; break;;
  * ) echo "Please answer 'Y' or 'n'.";;
esac
done


exit

##### <--- End Script ---> #####
