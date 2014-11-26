#!/bin/bash
#incase error, run: sed -i 's/\r//' filename
#Make executable: sudo chmod +x filename

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

# ------> DO NOT EDIT ANYTHING UNLESS YOU KNOW WHAT YOU ARE DOING. <------ #

##### ---> MANUAL CONFIGURATIONS <--- #####
#
#-------------------------------------
#echo "CONFIGURE SAMBA SHARE:"
#echo
#sudo tee -a /etc/samba/smb.conf <<EOF
#[ROOT]
#    comment = ROOT
#    path = /
#    browsable = yes
#    guest ok = yes
#    read only = no
#    force user = root
#    create mask = 0755
#EOF
#sudo service samba restart
#
##### <--- END MANUAL CONFIGURATIOS ---> #####

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

if [ -d "./www" ]
then
    echo
else
  echo
  echo "  ----------------------------- !! NOTE !! ------------------------------"
  echo "     This script needs to be run from within the setup directory.        "
  echo "     Change directory to the one containing the scrip and try again      "
  echo '     using the command: "sudo ./setup.sh"                                '
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

while :
do
  clear
  echo 
  echo "=================================================================="
  echo " Are you using CrysPi with 2 Raspberry Pis (Transmitter/Receiver) "
  echo "=================================================================="
  echo 
  echo "> Please select build option below:"
  echo
  echo "  1 - Set up CrysPi for use with 2 linux devices - Transmitter / Receiver"
  echo "  2 - Create CrysPi server on LAN with audio embedded into audio server. (Not reliable)"
  echo
  echo 
  echo -n "Enter option: "
  read opt
  
  if [ "$?" != "1" ]
  then
    case $opt in
      1) BUILDTYPE="pair"; break;;
      2) BUILDTYPE="solo"; break;;
      *) echo "Invalid option"; continue;;
    esac
  fi
done

clear

CWD=$PWD
sudo chmod +x ./*

#<--- Update Packages:
echo "------------------------"
echo "---> Updating Packages:"
echo "------------------------"
echo
echo
echo
sudo apt-get update
sudo apt-get install -y --reinstall bash-completion
echo

#<--- Download and install any packages upgrades:
#echo "-------------------------------------------------------"
#echo "---> Downloading and installing any packages upgrades:"
#echo "-------------------------------------------------------"
#sudo apt-get upgrade (this broke my pi!)
echo

clear
echo "-----------------------------"
echo "---> Setting up Samba share:"
echo "-----------------------------"
echo
echo
echo
sudo apt-get install -y samba openssh-server
echo
if ! grep 'Pi Server Share' /etc/samba/smb.conf; then
echo "[+]   CONFIGURE SAMBA SHARE:"
echo
sudo tee -a /etc/samba/smb.conf <<EOF
[ROOT]
    comment = Pi Server Share
    path = /
    browsable = yes
    guest ok = yes
    read only = no
    force user = root
    create mask = 0755

EOF
sudo tee -a /etc/samba/smb.conf <<EOF
[Home]
    comment = Pi Server Share
    path = /home/pi/
    browsable = yes
    guest ok = yes
    read only = no
    force user = pi
    create mask = 0755

EOF
sudo tee -a /etc/samba/smb.conf <<EOF
[Media]
    comment = Pi Server Share
    path = /media
    browsable = yes
    guest ok = yes
    read only = no
    force user = root
    create mask = 0755

EOF
echo
fi
sudo service samba restart
echo

clear
echo "--------------------------------"
echo "---> Installing required tools:"
echo "--------------------------------"
echo
echo
echo
sudo apt-get install -y git-core
echo

clear
echo "-------------------------------"
echo "---> Setting up Web Interface:"
echo "-------------------------------"
echo
echo
echo
sleep 2
echo "[+]   Installing Web server:"
sudo apt-get install -y lighttpd curl
sudo apt-get install -y php5-common php5-cgi php5
sudo lighty-enable-mod fastcgi-php
sudo service lighttpd force-reload
sudo apt-get install -y php5-curl
sudo service lighttpd force-reload

#<--- Copy Web UI to /var/www (replace with GIT in final)
echo "[+]   Copy Web UI files:"
echo
if [ -d "./www" ]
then
    sudo rm -frv /var/www/*
    cp -Rfv ./www/ /var
    sudo chmod 777 /var/www/ -Rv
    echo
else
    echo "Error: Could not locate Web UI files."
    echo "Ensure you ran this script from inside the setup dir."
fi

echo "[+]   Changing permissions of folders:"
echo
#Change the directory owner and group
sudo chown ${SUDO_USER}:${SUDO_USER} /var/www
#Allow the group to write to the directory
sudo chmod 775 /var/www
#Add user to the www-data group
sudo usermod -a -G www-data ${SUDO_USER}
#Add sudo permissions to server
echo "[+]   Adding www-data as Sudoer:"
cd $CWD
sudo ./addsudo.sh
echo

clear
echo "---------------------------------------"
echo "---> Setting up Webcam motion capture:"
echo "---------------------------------------"
echo
echo
echo
sleep 2
echo "[+]   Installing motion:"
sudo apt-get install -y  motion
echo "[+]   Configure motion:"
sudo sed -i 's/start_motion_daemon=[ofnsye]*/start_motion_daemon=yes/g' /etc/default/motion

while true
do
  read -p '  Default image size is 352x288, do you wish to adjust the image size? (y/n): ' ADJIMG
  case "$ADJIMG" in 
    y|Y ) echo "Enter new resolution:"; read -p 'WIDTH: ' WIDTH; read -p 'HEIGHT: ' HEIGHT; echo; echo "Image resolution set to: "${WIDTH}"x"${HEIGHT}; break;;
    n|N )  WIDTH="352"; HEIGHT="288"; echo; echo "Image resolution set to: 352x288"; break;;
    * ) echo "Do you wish to adjust the image size? (y/n):";;
esac
done

sed -i "s/width [0-9][0-9]*/width ${WIDTH}/g" /etc/motion/motion.conf
sed -i "s/height [0-9][0-9]*/height ${HEIGHT}/g" /etc/motion/motion.conf
sed -i 's/daemon o[fn]*/daemon on/g' /etc/motion/motion.conf
sed -i 's/webcam_quality [0-9]*/webcam_quality 70/g' /etc/motion/motion.conf
sed -i 's/webcam_motion o[fn]*/webcam_motion on/g' /etc/motion/motion.conf
sed -i 's/webcam_localhost o[fn]*/webcam_localhost off/g' /etc/motion/motion.conf

if ! sudo crontab -l | grep motion; then
  (sudo crontab -u root -l; echo "*/5 * * * * rm /tmp/motion/*" ) | sudo crontab -u root -
fi

clear
echo "----------------------"
echo "---> Renaming device:"
echo "----------------------"
echo
echo
echo
sleep 2
echo "[+]   Updating hostname:"
cd $CWD
sudo ./changehost crysPi

clear
echo "------------------------------"
echo "---> Setting up CrysPi Audio: "
echo "------------------------------"
echo
echo
echo
sleep 2
echo "[+]   Installing Web server:"
cd $CWD
sudo ./audio.sh $BUILDTYPE

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
