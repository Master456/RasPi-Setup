#!bin/bash
abfragen () {
  echo "Einstellungsmöglichkeiten werden abgefragt ..."
  read -p "Soll IPv6 global deaktiviert werden? (y/n) " ipv6
}

ausfuehren () {
  schritt1
  schritt2
}

schritt1 () {
  echo "Schritt 1 von 4: Installiere Updates ..."
  if [ "$ipv6" = "y" ]
    then sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf && sudo sysctl -p
  fi
  sudo apt update
  sudo apt -y full-upgrade
}

schritt2 () {
  echo "Schritt 2 von 4: Benötigte Programme werden installiert ..."
  sudo apt -y install hostapd bridge-utils git
  echo "Lade benötigte Dateien herunter ..."
  git clone https://github.com/Master456/RasPi-Einrichtung.git /home/pi/RasPi-Einrichtung
}

abfragen
ausfuehren
<<<<<<< HEAD
echo "run: sudo sh /home/pi/RasPi-Einrichtung/setup_part2.sh"
=======
<<<<<<< HEAD
sudo sh /home/pi/RasPi-Einrichtung/setup_part2.sh
=======
sh /home/pi/RasPi-Einrichtung/setup_part2.sh
>>>>>>> 9583ca4f4c3cd90ee2e4f72e789f272d3b738ee2
>>>>>>> d722461754aa12152aa6ae3cb348e2a914221e51
exit
