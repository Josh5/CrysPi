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

sleep 3

clear
echo "-------------------------! Please Wait !-------------------------"
echo "|            Downloading CrysPi installation files:              "
echo "|                                                               |"
echo "            Instillation will begin in just a moment            |"
echo "-----------------------------------------------------------------"
echo
sleep 2
wget --output-document=cryspi.zip https://github.com/Josh5/CrysPi/archive/master.zip
unzip ./cryspi.zip
cd CrysPi*/setup
sudo chmod +x ./*
sudo ./setup.sh

exit

##### <--- End Script ---> #####
