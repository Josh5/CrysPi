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
CWD=$PWD
sudo chmod +x ./*

echo "--------------------------------------------"
echo "---> Setting up CrysPi Audio recorder:"
echo "--------------------------------------------"
echo
echo
echo
sleep 2

if [ "$1" = "pair" ]; then

  echo "[+]   Installing Netcat:"
  sudo apt-get install -y netcat
  mkdir -p /opt/cryspi
  if [ ! -f /opt/cryspi/cryspi_audio ]; then
  echo "[+]   Installing listen script:"
sudo tee -a /opt/cryspi/cryspi_audio <<"EOF"
#!/bin/bash
DEVICE="plughw:1,0"
PORT=5000
echo "starting netcat for $DEVICE Port $PORT"
while true
do
    echo "Press and hold [CTRL+C] to stop.."
    echo ""
    exec arecord -f cd -D $DEVICE | netcat -v -l -p $PORT
done
EOF
  fi
  sudo chmod +x /opt/cryspi/cryspi_audio
  sudo cp data/streamcryspi /etc/init.d/streamcryspi
  sudo chmod +x /etc/init.d/streamcryspi
  sudo update-rc.d streamcryspi defaults

else

  mkdir -p src
  cd src
  echo "[+]   Build fdk-aac:"
  wget http://sourceforge.net/projects/opencore-amr/files/fdk-aac/fdk-aac-0.1.3.tar.gz
  tar zxvf fdk-aac-0.1.3.tar.gz
  cd fdk-aac-0.1.3
  ./configure
  make
  sudo make install
  cd ..

  echo "[+]   Build faac:"
  wget http://downloads.sourceforge.net/project/faac/faac-src/faac-1.28/faac-1.28.tar.gz
  tar xzf faac-1.28.tar.gz
  cd faac-1.28
  ./configure
  make
  sudo make install
  cd ..

  echo "[+]   Build ffmpeg:"
  sudo apt-get install -y libasound2-dev alsa-utils libvorbis-dev
  git clone git://source.ffmpeg.org/ffmpeg.git
  cd ffmpeg
  ./configure --enable-libvorbis --enable-shared --enable-gpl --prefix=/usr --enable-nonfree --enable-libmp3lame --enable-version3 --disable-mmx
  make
  sudo make install
  cd ..

  echo "[+]   Start ffserver on boot:"
  sudo cp data/ffserver.conf /etc/ffserver.conf
  sudo cp data/ffserver /etc/init.d/ffserver
  sudo chmod +x /etc/init.d/ffserver

  echo "[+]   Record audio on boot:"
  mkdir -p /opt/cryspi
  sudo cp data/cryspi_audio /opt/cryspi/cryspi_audio
  sudo chmod +x /opt/cryspi/cryspi_audio
  sudo cp data/streamcryspi /etc/init.d/streamcryspi
  sudo chmod +x /etc/init.d/streamcryspi
  sudo update-rc.d streamcryspi defaults

fi

exit

##### <--- End Script ---> #####
