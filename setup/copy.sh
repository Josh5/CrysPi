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
clear

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


echo
echo '--->All done! Install complete.'
echo
echo "-------------------------!IMPORTANT!-----------------------------"
echo "|            SETTINGS WILL TAKE EFFECT ON NEXT BOOT.            "
echo "|                                                               |"
echo "                 Update the settings before use.                |"
echo "-----------------------------------------------------------------"
echo
echo '   Thank you for using this installer script.'

echo


while true
do
	read -p "Would you like to restart your system now? (y:n)" CHOICE
	case "$CHOICE" in 
  y|Y ) echo "Restarting now."; sudo reboot; break;;
  n|N ) echo; echo "------------------------------------------"; echo "   Remember to restart your before use.   "; echo "------------------------------------------"; echo; break;;
  * ) echo "Please answer 'Y' or 'n'.";;
esac
done


exit

##### <--- End Script ---> #####
