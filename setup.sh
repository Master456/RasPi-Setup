input () {
  echo "Getting settings ..."
  read -p "Do You want to disable IPv6 globaly? (y/n) " ipv6
  read -p "What IP-adress should be assigned to this Raspberry Pi? " ip
  read -p "What IP-adress should be set as gateway? " gateway
  read -p "What SSID should be assigned to the hotspot? " ssid
  read -p "Do You want to disable the SSID-broadcast? (y/n) " broadcast
  read -p "Insert the passwort you want to use for the hotspot: " passwort
  read -p "Wich channel should be used? (1-9) " channel
  read -p "What name should be assigned to the Spotify-Connect server? " name
  read -p "Do You want to set an USB-soundcard as output? (y/n) " audio
  read -p "Do you want to set an initial volume? (y/n)" volumeyn
}

run () {
  step1
  step2
  step3
  step4
  step5
  #finalize
}

step1 () {
  echo "Step 1 of 5: Installing updates ..."
  if [ "$ipv6" = "y" ]
    then sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf && sudo sysctl -p
  fi
  sudo apt update
  sudo apt -y full-upgrade
}

step2 () {
  echo "Step 2 of 5: Installing the needed programms..."
  sudo apt -y install hostapd bridge-utils git
  echo "Getting additional files ..."
  git clone https://github.com/Master456/RasPi-Einrichtung.git /home/pi/RasPi-Einrichtung
}

step3 () {
  echo "Step 3 of 5: Setting up: network ..."
  sudo systemctl stop dhcpcd
  sudo systemctl disable dhcpcd
  sudo rm /etc/network/interfaces
  sudo rm /etc/wpa_supplicant/wpa_supplicant.conf
  sudo cp /home/pi/RasPi-Einrichtung/interfaces /etc/network/interfaces
  sudo cp /home/pi/RasPi-Einrichtung/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
  sudo echo "address $ip" >> /etc/network/interfaces
  sudo echo "gateway $gateway" >> /etc/network/interfaces
  sudo echo " ssid=$rep_ssid" >> /etc/wpa_supplicant/wpa_supplicant.conf
  sudo echo " psk=$rep_pw" >> /etc/wpa_supplicant/wpa_supplicant.conf
}

step4 () {
  echo "Step 4 of 5: Setting up: hotspot ..."
  sudo echo "DAEMON_CONF="/etc/hostapd/hostapd.conf"" >> /etc/default/hostapd
  sudo cp /home/pi/RasPi-Einrichtung/hostapd.conf /etc/hostapd/hostapd.conf
  sudo echo "ssid=$ssid" >> /etc/hostapd/hostapd.conf
  sudo echo "wpa_passphrase=$password" >> /etc/hostapd/hostapd.conf
  sudo echo "channel=$channel" >> /etc/hostapd/hostapd.conf
  case $broadcast in
    "y") sudo echo "ignore_broadcast_ssid=1" >> /etc/hostapd/hostapd.conf ;;
    "n") sudo echo "ignore_broadcast_ssid=0" >> /etc/hostapd/hostapd.conf ;;
  esac
}

step5 () {
  echo "Step 5 of 5: Setting up: Spotify-Connect server ..."
  sudo curl -sL https://dtcooper.github.io/raspotify/install.sh | sh
  sudo rm /etc/default/raspotify
  sudo cp /home/pi/RasPi-Einrichtung/raspotify /etc/default/raspotify
  sudo echo -e "DEVICE_NAME="$name"\n " >> /etc/default/raspotify
  if [ "$audio" = "y" ]
    then sudo echo "OPTIONS="--device hw:1,0"" >> /etc/default/raspotify
  fi
  if [ "$volumeyn" = "y" ]
    then {
      read -p "How high should the initial volume be? (0-100) " volume
      sudo echo "VOLUME_ARGS="--enable-volume-normalisation --initial-volume "$volume""" >> /etc/default/raspotify
    }
  fi
}

finalize () {
  echo "Finalizing setup ..."
  sudo raspi-config
}

input
run
exit
