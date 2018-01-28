#!bin/bash
abfragen () {
  echo "Einstellungsmöglichkeiten werden abgefragt ..."
  read -p "Welche IP-Adresse soll dem Raspberry Pi zugewiesen werden? " ip
  read -p "Welche IP-Adresse soll als Gateway konfiguriert werden? " gateway
  read -p "Geben Sie die SSID, welche dem Hotspot zugewiesen werden soll: " ssid
  read -p "Soll der SSID-Broadcast deaktiviert werden? (y/n) " broadcast
  read -p "Geben sie das Passwort für den Hotspot ein: " passwort
  read -p "Auf welchem Kanal soll gesendet werden? (1-9) " channel
  read -p "Wie soll der Spotify-Connect Server Heißen? " name
  read -p "Wollen Sie eine USB-Audio Karte als Standartausgabe Festlegen? (y/n) " audio
}

pruefen () {
  if [[ "$ipv6" = "y" -o "$ipv6" = "n" ]]; then
    echo "Eingabe 1 Korrekt!"
  else echo "Ungültige Eingabe für Frage 1! Starten Sie das Programm neu." && exit
  fi
  if [[ "$broadcast" = "y" -o "$broadcast" = "n" ]]; then
    echo "Eingabe 5 Korrekt!"
  else echo "Ungültige Eingabe für Frage 5! Starten Sie das Programm neu." && exit
  fi
  if [[ "$audio" = "y" -o "$audio" = "n" ]]; then
    echo "Eingabe 9 Korrekt!"
  else echo "Ungültige Eingabe für Frage 9! Starten Sie das Programm neu." && exit
  fi
}

ausfuehren () {
  schritt4
  schritt5
  schritt6
  abschluss
}

schritt4 () {
  echo "Schritt 3 von 4: Netzwerk wird eingerichtet ..."
  sudo systemctl stop hostapd
  sudo echo -e "denyinterfaces wlan0\n\tdenyinterfaces eth0\n\t \n\tinterface br0" >> /etc/dhcpcd.conf
  sudo echo "static ip_address=$ip/24" >> /etc/dhcpcd.conf
  sudo echo "static routers=$gateway" >> /etc/dhcpcd.conf
  sudo rm /etc/network/interfaces
  sudo cp /home/pi/RasPi-Einrichtung/interfaces /etc/network/interfaces
}

schritt5 () {
  echo "Schritt 4 von 4: Hotspot wird eingerichtet ..."
  sudo echo "DAEMON_CONF="/etc/hostapd/hostapd.conf"" >> /etc/default/hostapd
  sudo cp /home/pi/RasPi-Einrichtung/hostapd.conf /etc/hostapd/hostapd.conf
  sudo echo "ssid=$ssid" >> /etc/hostapd/hostapd.conf
  sudo echo "wpa_passphrase=$passwort" >> /etc/hostapd/hostapd.conf
  sudo echo "channel=$channel" >> /etc/hostapd/hostapd.conf
  case $broadcast in
    "y") sudo echo "ignore_broadcast_ssid=1" >> /etc/hostapd/hostapd.conf ;;
    "n") sudo echo "ignore_broadcast_ssid=0" >> /etc/hostapd/hostapd.conf ;;
  esac
  sudo brctl addbr br0
  sudo brctl addif br0 eth0 wlan0
}

schritt6 () {
  echo "Schritt 6 von 6: Spotify-Connect Server wird eingerichtet ..."
  sudo curl -sL https://dtcooper.github.io/raspotify/install.sh | sh
  sudo rm /etc/default/raspotify
  sudo cp /home/pi/RasPi-Einrichtung/raspotify /etc/default/raspotify
  sudo echo "DEVICE_NAME="$name"" >> /etc/default/raspotify
  if [ "$audio" = "y" ]
    then sudo echo "OPTIONS="--device hw:1,0"" >> /etc/default/raspotify
  fi
}

abschluss () {
  echo "Einrichtung wird abgeschlossen ..."
  sudo raspi-config
  read -p "Soll der Raspberry Pi neu gestartet werden? (y/n) " reboot
  if [[ "$reboot" = "y" ]]; then
    sudo reboot
  fi
}

abfragen
#pruefen
ausfuehren
exit
